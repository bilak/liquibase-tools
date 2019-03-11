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

    <xsl:template match="changeSet[createSequence]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="createSequence">
                <xsl:copy-of select="createSequence/[@*[not(name()='ordered')]]"/>
            </xsl:element>
            <xsl:if test="createSequence/@ordered = true()">
                <xsl:element name="modifySql">
                    <xsl:attribute name="dbms">oracle</xsl:attribute>
                    <xsl:element name="append">
                        <xsl:attribute name="value"> ORDER</xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:copy-of select="*[not(self::createSequence)]"/>
        </xsl:copy>



    </xsl:template>

</xsl:transform>