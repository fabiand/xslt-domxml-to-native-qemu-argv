<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text"/>

<xsl:template match="/">
<xsl:apply-templates select="domain"/> 
</xsl:template>

<xsl:template match="/domain[@type='kvm']">
<xsl:value-of select="devices/emulator"/> \
  -name <xsl:value-of select="name"/> \
  -uuid <xsl:value-of select="uuid"/> \
  -m <xsl:value-of select="memory div 1024"/><!-- FIXME needs to respect unit --> \
  -smp <xsl:value-of select="vcpu"/> \
  -machine <xsl:value-of select="os/type/@machine"/>,accel=kvm \
  <xsl:apply-templates select="cpu"/> \
  <xsl:apply-templates select="devices/interface"/> \
  <xsl:apply-templates select="devices/video"/> \
  <xsl:apply-templates select="devices/graphics"/> \
  <xsl:apply-templates select="devices/disk"/> \
  # End
</xsl:template>

<xsl:template match="cpu">\
<xsl:choose>
  <xsl:when test="model/text()">-cpu <xsl:value-of select="cpu/model"/></xsl:when>
  <xsl:when test="@mode='host-model'">-cpu host</xsl:when>
</xsl:choose>
</xsl:template>

<xsl:template match="devices/interface">\
  -netdev <xsl:value-of select="@type"/>,id=hostnet<xsl:value-of select="position()"/> \
  -device <xsl:value-of select="model/@type"/>,netdev=hostnet<xsl:value-of select="position()"/>,id=net<xsl:value-of select="position()"/>,mac=<xsl:value-of select="mac/@address"/> \
</xsl:template>

<xsl:template match="devices/video">\
  -device <xsl:value-of select="model/@type"/>,id=video<xsl:value-of select="position()"/>,ram_size=<xsl:value-of select="model/@ram * 1024"/>,vram_size=<xsl:value-of select="model/@vram * 1024"/>,vgamem_mb=<xsl:value-of select="model/@vgamem div 1024"/> \
</xsl:template>

<xsl:template match="devices/graphics[@type='spice']">\
-spice port=5942,addr=127.0.0.1,disable-ticketing,image-compression=off,seamless-migration=on \
</xsl:template>

<xsl:template match="devices/disk[@type='file']">\
  -drive file=<xsl:value-of select="source/@file"/>,format=<xsl:value-of select="driver/@type"/>,if=<xsl:value-of select="target/@bus"/>,id=drive<xsl:value-of select="position()"/>\
<xsl:if test="readonly">,readonly=on</xsl:if> \
</xsl:template>


</xsl:stylesheet>

