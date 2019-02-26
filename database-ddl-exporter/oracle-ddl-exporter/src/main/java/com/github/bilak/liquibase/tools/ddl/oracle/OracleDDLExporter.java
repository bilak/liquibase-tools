package com.github.bilak.liquibase.tools.ddl.oracle;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.util.FileCopyUtils;

import com.github.bilak.liquibase.tools.ddl.oracle.configuration.DDLExporterConfigurationProperties;
import liquibase.change.core.RawSQLChange;
import liquibase.change.core.SQLFileChange;
import liquibase.changelog.ChangeSet;
import liquibase.changelog.DatabaseChangeLog;
import liquibase.serializer.core.xml.XMLChangeLogSerializer;


/**
 * Exports DDLs from Oracle database as {@link DatabaseChangeLog}.
 * <p>
 * Note: user under which is this operation executed should have access rights to execute oracle's procedure <b>DBMS_METADATA.GET_DDL</b>
 *
 * @author Lukáš Vasek
 */
public class OracleDDLExporter implements InitializingBean {

    private static final Logger logger = LoggerFactory.getLogger(OracleDDLExporter.class);

    private static final String QUERY_SELECT_OBJECT_TYPE = "SELECT OBJECT_NAME FROM ALL_OBJECTS WHERE OWNER = :OWNER AND OBJECT_TYPE = " +
            ":OBJECT_TYPE ORDER BY TIMESTAMP";

    private static final String QUERY_GET_DDL = "SELECT DBMS_METADATA.GET_DDL(:OBJECT_TYPE, :OBJECT_NAME) FROM DUAL";

    private static final String QUERY_COUNT_OBJECTS_FOR_OBJECT_TYPE = "SELECT COUNT(*) FROM ALL_OBJECTS WHERE OWNER = :OWNER AND OBJECT_TYPE ="
            + " :OBJECT_TYPE";

    private static final String OBJECT_TYPE_QUERY_PARAM = "OBJECT_TYPE";

    private static final String OBJECT_NAME_QUERY_PARAM = "OBJECT_NAME";

    private static final String OWNER_QUERY_PARAM = "OWNER";

    private static final String END_DELIMITER = "\\n/";

    private static final String TEMP_DIR = System.getProperty("java.io.tmpdir");

    private static final Path TEMP_PATH = Paths.get(TEMP_DIR, "liquibase-changelogs");

    private final NamedParameterJdbcTemplate jdbcTemplate;

    private final DDLExporterConfigurationProperties configurationProperties;

    public OracleDDLExporter(NamedParameterJdbcTemplate jdbcTemplate, DDLExporterConfigurationProperties configurationProperties) {
        this.jdbcTemplate = jdbcTemplate;
        this.configurationProperties = configurationProperties;
    }

    @Override
    public void afterPropertiesSet() {
        final XMLChangeLogSerializer serializer = new XMLChangeLogSerializer();
        for (final ObjectType objectType : OracleObjectTypeEnum.values()) {
            if (getObjectTypeCount(objectType, configurationProperties.getOwner()) <= 0) {
                logger.debug("No object found for type {}", objectType.getName());
            } else {
                final Path changeFolderPath = Paths.get(TEMP_PATH.toString(), objectType.getName().toLowerCase());
                logger.debug("Object type changeLog folder {}", changeFolderPath);
                createDirectory(changeFolderPath);
                final DatabaseChangeLog changeLog = createChangeLogForType(changeFolderPath, objectType, configurationProperties);
                try (OutputStream os = new FileOutputStream(Paths.get(changeFolderPath.toString(), "changelog.xml").toFile())) {
                    serializer.write(changeLog.getChangeSets(), os);
                } catch (IOException e) {
                    throw new OracleDDLExporterException("Error while exporting oracle ddl", e);
                }
            }
        }
    }

    private int getObjectTypeCount(final ObjectType objectType, final String owner) {
        return jdbcTemplate.queryForObject(QUERY_COUNT_OBJECTS_FOR_OBJECT_TYPE,
                new MapSqlParameterSource(OWNER_QUERY_PARAM, owner)
                        .addValue(OBJECT_TYPE_QUERY_PARAM, objectType.getName()),
                Integer.class);
    }

    private static void createDirectory(final Path path) {
        final File folder = path.toFile();
        if (!folder.exists()) {
            boolean folderCreated = folder.mkdirs();
            logger.debug("Was folder [{}] created ?= [{}] ", folder, folderCreated);
        }
    }

    private DatabaseChangeLog createChangeLogForType(final Path parentDir, final ObjectType objectType,
            final DDLExporterConfigurationProperties config) {
        final DatabaseChangeLog changeLog = new DatabaseChangeLog(Paths.get(parentDir.toString(), "changelog.xml").toString());
        final String idPrefix = "create " + objectType.getName().toLowerCase();

        getObjectTypeNames(objectType, config.getOwner())
                .forEach(name -> {
                    logger.info("Exporting [{}] [{}]", objectType.getName(), name);
                    try {
                        final String fileName = name.toLowerCase().concat(".sql");
                        final String id = idPrefix + " " + name.toLowerCase();

                        final String objectBody = jdbcTemplate.queryForObject(QUERY_GET_DDL,
                                new MapSqlParameterSource(OBJECT_TYPE_QUERY_PARAM, objectType.getGetDdlParamValue())
                                        .addValue(OBJECT_NAME_QUERY_PARAM, name),
                                String.class);

                        final File targetFile = Paths.get(parentDir.toString(), fileName).toFile();
                        writeObjectBody(objectBody, targetFile);

                        final ChangeSet changeSet = createEmptyChangeSet(changeLog, id, config);
                        changeSet.addChange(createSqlFileChange(fileName));
                        changeSet.addRollbackChange(createRollback(objectType, name));
                        changeLog.addChangeSet(changeSet);
                    } catch (RuntimeException e) {
                        logger.error("Unable to process [{}] with name [{}]", objectType, name, e);
                    }
                });

        return changeLog;
    }

    private static void writeObjectBody(final String objectBody, final File targetFile) {
        try (Writer writer = new OutputStreamWriter(new FileOutputStream(targetFile), StandardCharsets.UTF_8)) {
            FileCopyUtils.copy(objectBody, writer);
        } catch (IOException e) {
            throw new OracleDDLExporterException("Unable to write file", e);
        }
    }

    private RawSQLChange createRollback(final ObjectType objectType, final String objectName) {
        final RawSQLChange sql = new RawSQLChange(objectType.generateDropStatement(objectName));
        sql.setSplitStatements(Boolean.FALSE);
        sql.setStripComments(Boolean.FALSE);
        return sql;
    }

    private ChangeSet createEmptyChangeSet(final DatabaseChangeLog changeLog, final String id, final DDLExporterConfigurationProperties config) {
        return new ChangeSet(id,
                config.getAuthor(),
                Boolean.FALSE,
                Boolean.FALSE,
                null,
                config.getContextsList(),
                config.getDbmsList(),
                changeLog);
    }


    private SQLFileChange createSqlFileChange(final String path) {
        final SQLFileChange change = new SQLFileChange();
        change.setEndDelimiter(END_DELIMITER);
        change.setPath(path);
        change.setRelativeToChangelogFile(Boolean.TRUE);
        change.setSplitStatements(Boolean.TRUE);

        return change;
    }

    private List<String> getObjectTypeNames(final ObjectType objectType, final String owner) {
        return jdbcTemplate.queryForList(QUERY_SELECT_OBJECT_TYPE,
                new MapSqlParameterSource(OWNER_QUERY_PARAM, owner)
                        .addValue(OBJECT_TYPE_QUERY_PARAM, objectType.getDatabaseRepresentation()), String.class);
    }

    interface ObjectType {

        String getName();

        String getDatabaseRepresentation();

        String generateDropStatement(String objectName);

        String getGetDdlParamValue();
    }

    enum OracleObjectTypeEnum implements ObjectType {
        FUNCTION("FUNCTION"),
        JOB("JOB") {
            @Override
            public String generateDropStatement(final String objectName) {
                final StringBuilder sb = new StringBuilder();
                return sb.append("BEGIN ")
                        .append("dbms_scheduler.drop_job(job_name => '")
                        .append(objectName)
                        .append("');")
                        .append("END;")
                        .toString();
            }

            @Override
            public String getGetDdlParamValue() {
                return "PROCOBJ";
            }
        },
        JAVA_SOURCE("JAVA SOURCE"),
        PACKAGE("PACKAGE") {
            @Override
            public String getGetDdlParamValue() {
                return "PACKAGE_SPEC";
            }
        },
        PACKAGE_BODY("PACKAGE BODY"),
        PROCEDURE("PROCEDURE"),
        PROGRAM("PROGRAM") {
            @Override
            public String generateDropStatement(final String objectName) {
                final StringBuilder sb = new StringBuilder();
                return sb.append("BEGIN ")
                        .append("dbms_scheduler.drop_program(program_name => '")
                        .append(objectName)
                        .append("');")
                        .append("END;")
                        .toString();
            }

            @Override
            public String getGetDdlParamValue() {
                return "PROCOBJ";
            }
        },
        TRIGGER("TRIGGER");

        private final String databaseRepresentation;

        OracleObjectTypeEnum(final String databaseRepresentation) {
            this.databaseRepresentation = databaseRepresentation;
        }

        @Override
        public String getDatabaseRepresentation() {
            return databaseRepresentation;
        }

        @Override
        public String getName() {
            return name();
        }

        @Override
        public String generateDropStatement(final String objectName) {
            final StringBuilder sb = new StringBuilder();
            return sb.append("DROP ")
                    .append(getDatabaseRepresentation())
                    .append(' ')
                    .append(objectName)
                    .append(';')
                    .toString();
        }

        @Override
        public String getGetDdlParamValue() {
            return name();
        }
    }

}
