require recipes-core/images/image-lcm-container-minimal.bb

SUMMARY = "An extremely minimal lcm container image with amx"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

IMAGE_INSTALL += "\
    packagegroup-amx-core \
"

OCI_IMAGE_ENTRYPOINT ?= "/sbin/init"
OCI_IMAGE_ENTRYPOINT_ARGS ?= "/bin/sh"
