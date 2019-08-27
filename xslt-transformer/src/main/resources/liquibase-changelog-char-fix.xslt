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

    <xsl:template match="column/@type[matches(.,'^.*CHAR.*\((\d*) BYTE\)')]">
        <xsl:analyze-string select="." regex="(^.*CHAR.*\()(\d*) BYTE\)">
            <xsl:matching-substring>
                <xsl:attribute name="type">
                    <xsl:value-of select="regex-group(1)"/>
                    <xsl:value-of select="regex-group(2)"/>
                    <xsl:value-of select="'${byteVarcharType})'"/>
                </xsl:attribute>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template match="column/@type[matches(.,'^.*CHAR.*\(\d* CHAR\)')]">
        <xsl:analyze-string select="." regex="(^.*CHAR.*\()(\d*) CHAR\)">
            <xsl:matching-substring>
                <xsl:attribute name="type">
                    <xsl:value-of select="regex-group(1)"/>
                    <xsl:value-of select="regex-group(2)"/>
                    <xsl:value-of select="'${charVarcharType})'"/>
                </xsl:attribute>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
</xsl:transform>