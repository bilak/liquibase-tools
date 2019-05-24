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

    <xsl:template match="changeSet[createIndex and addUniqueConstraint]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*[not(self::addUniqueConstraint)]"/>
        </xsl:copy>
        <xsl:if test="addUniqueConstraint">
            <xsl:element name="changeSet">
                <xsl:attribute name="author">system</xsl:attribute>
                <xsl:attribute name="id" select="uuid:new-uuid()"/>
                <xsl:element name="addUniqueConstraint">
                    <xsl:copy-of select="addUniqueConstraint/@*[not(name()='forIndexName')]"/>
                </xsl:element>
                <xsl:element name="modifySql">
                    <xsl:attribute name="dbms">oracle</xsl:attribute>
                    <xsl:element name="append">
                        <xsl:attribute name="value">
                            <xsl:value-of select="' USING INDEX '"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="modifySql">
                    <xsl:attribute name="dbms">postgresql</xsl:attribute>
                    <xsl:element name="regExpReplace">
                        <xsl:attribute name="replace">
                            <xsl:value-of select="'(\(.*\))'"/>
                        </xsl:attribute>
                        <xsl:attribute name="with"/>
                    </xsl:element>
                    <xsl:element name="append">
                        <xsl:attribute name="value">
                            <xsl:value-of select="' USING INDEX '"/>
                            <xsl:value-of select="addUniqueConstraint/@forIndexName"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
</xsl:transform>
