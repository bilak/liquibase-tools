package com.github.bilak.liquibase.tools.ddl.oracle;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;


/**
 * Main application launcher.
 *
 * @author Lukáš Vasek
 */
@SpringBootApplication
public class OracleDDLExporterApplication {

    public static void main(String[] args) {
        SpringApplication.run(OracleDDLExporterApplication.class, args);
    }
}
