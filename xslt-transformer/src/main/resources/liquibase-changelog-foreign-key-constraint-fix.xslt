<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xpath-default-namespace="http://www.liquibase.org/xml/ns/dbchangelog"
               xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
               xmlns:uuid="http://uuid.util.java"
               exclude-result-prefixes="uuid">

    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="changeSet[addForeignKeyConstraint]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="addForeignKeyConstraint">
                <xsl:copy-of select="addForeignKeyConstraint/@*[not(name()='deferrable' or name()='initiallyDeferred')]"/>
            </xsl:element>
            <xsl:if test="addForeignKeyConstraint/(@deferrable = true() or @initiallyDeferred = true())">
                <xsl:element name="rollback">
                    <xsl:element name="dropForeignKeyConstraint">
                        <xsl:attribute name="baseTableName">
                            <xsl:value-of select="addForeignKeyConstraint/@baseTableName"/>
                        </xsl:attribute>
                        <xsl:attribute name="constraintName">
                            <xsl:value-of select="addForeignKeyConstraint/@constraintName"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="modifySql">
                    <xsl:attribute name="dbms">oracle</xsl:attribute>
                    <xsl:element name="append">
                        <xsl:attribute name="value">
                            <xsl:if test="addForeignKeyConstraint/@deferrable = true()">
                                <xsl:value-of select="' DEFERRABLE'"/>
                            </xsl:if>
                            <xsl:if test="addForeignKeyConstraint/@initiallyDeferred = true()">
                                <xsl:value-of select="' INITIALLY DEFERRED'"/>
                            </xsl:if>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:transform>