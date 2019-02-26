package com.github.bilak.liquibase.tools.ddl.oracle;

/**
 * Exception thrown when some error occurs in oracle ddl export.
 *
 * @author Lukáš Vasek
 */
public class OracleDDLExporterException extends RuntimeException {

    /**
     * Constructor with message parameter.
     *
     * @param message detail message
     */
    public OracleDDLExporterException(String message) {
        super(message);
    }

    /**
     * Constructor with message and cause of exception.
     *
     * @param message detail message
     * @param cause cause of exception
     */
    public OracleDDLExporterException(String message, Throwable cause) {
        super(message, cause);
    }
}
