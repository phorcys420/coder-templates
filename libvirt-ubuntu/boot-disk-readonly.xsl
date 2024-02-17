<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- Identity template to copy all nodes and attributes -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/domain/devices/disk[@type='volume' and @device='disk'][source/@volume='${disk_name}']">
        <xsl:copy>
            <!-- Copy existing attributes -->
            <xsl:apply-templates select="@*"/>

            <!-- Copy existing child elements -->
            <xsl:apply-templates select="node()"/>

            <!-- Add readonly child element -->
            <readonly/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>