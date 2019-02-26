package com.github.bilak.liquibase.tools.ddl.oracle.configuration;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

import com.github.bilak.liquibase.tools.ddl.oracle.OracleDDLExporter;


/**
 * Configuration for oracle ddl exporter.
 *
 * @author Lukáš Vasek
 */
@Configuration
public class OracleDDLExporterConfiguration {

    @Bean
    @ConfigurationProperties(prefix = "ddl-exporter.oracle")
    DDLExporterConfigurationProperties configurationProperties() {
        return new DDLExporterConfigurationProperties();
    }

    @Bean
    OracleDDLExporter oracleDDLExporter(final NamedParameterJdbcTemplate jdbcTemplate) {
        return new OracleDDLExporter(jdbcTemplate, configurationProperties());
    }
}
