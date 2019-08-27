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

    <xsl:template match="changeSet[createIndex and (addUniqueConstraint or addPrimaryKey)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*[not(self::addUniqueConstraint) and not(self::addPrimaryKey)]"/>
            <xsl:element name="rollback"/>
        </xsl:copy>
        <xsl:if test="addUniqueConstraint">
            <xsl:element name="changeSet">
                <xsl:attribute name="author">system</xsl:attribute>
                <xsl:attribute name="id" select="uuid:new-uuid()"/>
                <xsl:element name="addUniqueConstraint">
                    <xsl:copy-of select="addUniqueConstraint/@*[not(name()='forIndexName')]"/>
                </xsl:element>
                <xsl:element name="modifySql">
                    <xsl:attribute name="dbms" select="'oracle'"/>
                    <xsl:element name="append">
                        <xsl:attribute name="value" select="' USING INDEX '"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="modifySql">
                    <xsl:attribute name="dbms">postgresql</xsl:attribute>
                    <xsl:element name="regExpReplace">
                        <xsl:attribute name="replace" select="'(\(.*\))'"/>
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
        <xsl:if test="addPrimaryKey">
            <xsl:element name="changeSet">
                <xsl:attribute name="author" select="'system'"/>
                <xsl:attribute name="id" select="uuid:new-uuid()"/>
                <xsl:element name="addPrimaryKey">
                    <xsl:copy-of select="addPrimaryKey/@*[not(name()='forIndexName')]"/>
                </xsl:element>
                <xsl:element name="modifySql">
                    <xsl:attribute name="dbms" select="'oracle'"/>
                    <xsl:element name="append">
                        <xsl:attribute name="value" select="' USING INDEX '"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="rollback">
                    <xsl:element name="dropPrimaryKey">
                        <xsl:attribute name="tableName">
                            <xsl:value-of select="addPrimaryKey/@tableName"/>
                        </xsl:attribute>
                        <xsl:attribute name="constraintName">
                            <xsl:value-of select="addPrimaryKey/@constraintName"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="modifySql">
                    <xsl:attribute name="dbms">postgresql</xsl:attribute>
                    <xsl:element name="regExpReplace">
                        <xsl:attribute name="replace" select="'(\(.*\))'"/>
                        <xsl:attribute name="with"/>
                    </xsl:element>
                    <xsl:element name="append">
                        <xsl:attribute name="value">
                            <xsl:value-of select="' USING INDEX '"/>
                            <xsl:value-of select="addPrimaryKey/@forIndexName"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
</xsl:transform>
