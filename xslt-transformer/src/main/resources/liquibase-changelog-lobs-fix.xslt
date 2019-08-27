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
            <xsl:choose>
                <xsl:when test="createTable/column/@type = ('LOB', 'CLOB', 'BLOB')">
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="*[not(modifySql)]"/>
                    <xsl:choose>
                        <xsl:when test="modifySql/@dbms='oracle'">
                            <xsl:element name="modifySql">
                                <xsl:copy-of select="modifySql/@*"/>
                                <xsl:copy-of select="*"/>
                                <xsl:call-template name="lobColumnAsSecureFile"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="modifySql">
                                <xsl:attribute name="dbms">
                                    <xsl:value-of select="'oracle'"/>
                                </xsl:attribute>
                                <xsl:call-template name="lobColumnAsSecureFile"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="node()|@*"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="lobColumnAsSecureFile">
        <xsl:for-each select="createTable/column">
            <xsl:if test="@type = ('LOB', 'CLOB', 'BLOB')">
                <xsl:element name="append">
                    <xsl:attribute name="value">
                        <xsl:value-of select="' LOB ('"/>
                        <xsl:value-of select="@name"/>
                        <xsl:value-of
                            select="') STORE AS SECUREFILE (TABLESPACE ${lobTablespace} NOCACHE LOGGING CHUNK 8192)'"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:transform>