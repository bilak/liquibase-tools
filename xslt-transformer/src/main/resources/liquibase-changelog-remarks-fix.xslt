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

    <xsl:template match="changeSet[createTable]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="createTable"/>
            <xsl:copy-of select="*[not(self::createTable)]"/>
        </xsl:copy>
        <xsl:if test="createTable/@remarks">
            <xsl:element name="changeSet">
                <xsl:attribute name="id" select="uuid:new-uuid()"/>
                <xsl:attribute name="author">system</xsl:attribute>
                <xsl:element name="setTableRemarks">
                    <xsl:copy-of select="createTable/(@tableName, @remarks)"/>
                </xsl:element>
                <xsl:for-each select="createTable/column[@remarks]">
                    <xsl:element name="setColumnRemarks">
                        <xsl:copy-of select="../@tableName"/>
                        <xsl:attribute name="columnName" select="@name"/>
                        <xsl:copy-of select="@remarks"/>

                    </xsl:element>
                </xsl:for-each>
                <xsl:element name="rollback"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="createTable/@remarks"/>
    <xsl:template match="createTable/column/@remarks"/>

</xsl:transform>