package com.github.bilak.liquibase.tools.ddl.oracle.configuration;

import org.springframework.lang.NonNull;


/**
 * Configuration properties used for {@link com.github.bilak.liquibase.tools.ddl.oracle.OracleDDLExporter}.
 *
 * @author Lukáš Vasek
 */
public class DDLExporterConfigurationProperties {

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
}
