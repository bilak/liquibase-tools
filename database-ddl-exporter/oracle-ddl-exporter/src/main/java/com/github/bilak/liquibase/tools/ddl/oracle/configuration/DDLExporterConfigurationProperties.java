package com.github.bilak.liquibase.tools.ddl.oracle.configuration;

import java.nio.file.Path;
import java.nio.file.Paths;

import org.springframework.lang.NonNull;


/**
 * Configuration properties used for {@link com.github.bilak.liquibase.tools.ddl.oracle.OracleDDLExporter}.
 *
 * @author Lukáš Vasek
 */
public class DDLExporterConfigurationProperties {

    private static final String TEMP_DIR = System.getProperty("java.io.tmpdir");

    private static final Path TEMP_PATH = Paths.get(TEMP_DIR, "liquibase-changelogs");

    /**
     * Schema owner.
     */
    @NonNull
    private String owner;

    /**
     * Author to be used in generated change logs.
     */
    private String author = "system (generated)";

    /**
     * Comma separated list of contexts to be used in generated change logs.
     */
    private String contextsList;

    /**
     * Comma separated list of database types to be used in generated change logs.
     */
    private String dbmsList;

    /**
     * Flag indicating if changes (files) are at relative path to their changeLog where they are included.
     */
    private boolean changePathRelativeToChangeLogPath;

    /**
     * Root directory where will be export placed.
     */
    private String changeLogRootDir = TEMP_PATH.toString();


    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getContextsList() {
        return contextsList;
    }

    public void setContextsList(String contextsList) {
        this.contextsList = contextsList;
    }

    public String getDbmsList() {
        return dbmsList;
    }

    public void setDbmsList(String dbmsList) {
        this.dbmsList = dbmsList;
    }

    public boolean isChangePathRelativeToChangeLogPath() {
        return changePathRelativeToChangeLogPath;
    }

    public void setChangePathRelativeToChangeLogPath(boolean changePathRelativeToChangeLogPath) {
        this.changePathRelativeToChangeLogPath = changePathRelativeToChangeLogPath;
    }

    public String getChangeLogRootDir() {
        return changeLogRootDir;
    }

    public void setChangeLogRootDir(String changeLogRootDir) {
        this.changeLogRootDir = changeLogRootDir;
    }
}
