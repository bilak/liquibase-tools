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
        <xsl:variable name="currentTableName" select="createTable/@tableName"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="../changeSet/addPrimaryKey[@tableName = $currentTableName]">
                    <xsl:variable name="columnsOfPrimaryKey"
                                  select="tokenize(../changeSet/addPrimaryKey[@tableName = $currentTableName]/@columnNames, ',')"/>
                    <xsl:copy-of select="@*"/>
                    <xsl:element name="createTable">
                        <xsl:copy-of select="createTable/@*"/>
                        <xsl:for-each select="createTable/column">
                            <xsl:element name="column">
                                <xsl:choose>
                                    <xsl:when test="@name = $columnsOfPrimaryKey">
                                        <xsl:copy-of select="@*"/>
                                        <xsl:element name="constraints">
                                            <xsl:choose>
                                                <xsl:when test="current()/constraints">
                                                    <xsl:copy-of select="current()/constraints/@*[not(name()='nullable')]"/>
                                                    <xsl:attribute name="nullable">
                                                        <xsl:value-of select="'false'"/>
                                                    </xsl:attribute>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:attribute name="nullable">
                                                        <xsl:value-of select="'false'"/>
                                                    </xsl:attribute>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="@*|node()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="node()|@*"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

</xsl:transform>