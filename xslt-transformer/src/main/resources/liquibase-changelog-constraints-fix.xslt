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

    <!-- move primary key from table definition to separate changeSet-->
    <xsl:template match="changeSet[createTable and not(modifySql)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="createTable"/>
            <xsl:copy-of select="*[not(self::createTable)]"/>
        </xsl:copy>
        <xsl:if test="createTable/column/constraints/@primaryKey='true'">
            <xsl:variable name="indexColumns">
                <xsl:for-each select="createTable/column[constraints/@primaryKey='true']">
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:value-of select="@name"/>
                        </xsl:when>
                        <xsl:otherwise>,<xsl:value-of select="@name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:element name="changeSet">
                <xsl:attribute name="id" select="uuid:new-uuid()"/>
                <xsl:attribute name="author">system</xsl:attribute>
                <xsl:element name="addPrimaryKey">
                    <xsl:attribute name="columnNames" select="$indexColumns"/>
                    <!-- maybe there exists more elegant way how to get unique constraintName but this is ok - just get first-->
                    <xsl:attribute name="constraintName"
                                   select="createTable/column[constraints/@primaryKey='true'][1]/constraints/@primaryKeyName"/>
                    <xsl:copy-of select="createTable/@tableName"/>
                    <xsl:attribute name="tablespace">${indexTablespace}</xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- replace constraints primary key attributes with nullable=false -->
    <xsl:template match="changeSet[createTable and not(modifySql)]/createTable/column[constraints/@primaryKey='true']/constraints">
        <xsl:element name="constraints">
            <xsl:attribute name="nullable">false</xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="createIndex">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="tablespace">${indexTablespace}</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:transform>