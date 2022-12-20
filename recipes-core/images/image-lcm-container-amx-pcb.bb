require recipes-core/images/image-lcm-container-amx.bb

SUMMARY = "An extremely minimal lcm container image with amx and pcb"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

IMAGE_INSTALL += "\
    libpcb \
    libmtk \
    pcb-bus \
    pcb-cli \
    pcb-ser-odl \
    pcb-ser-ddw \
    pcb-ser-http \
    mod-amxb-pcb \
    pcb-app \
"

OCI_IMAGE_ENTRYPOINT ?= "/sbin/init"
OCI_IMAGE_ENTRYPOINT_ARGS ?= "/bin/sh"
