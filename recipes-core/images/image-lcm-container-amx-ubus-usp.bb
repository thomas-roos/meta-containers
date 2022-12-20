require recipes-core/images/image-lcm-container-amx-ubus.bb

SUMMARY = "An extremely minimal lcm container image with amx and ubus and usp"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

IMAGE_INSTALL += "\
    usp-endpoint \
    mod-amxb-usp \
    controller-container \
"

OCI_IMAGE_ENTRYPOINT ??= "/sbin/init"
OCI_IMAGE_ENTRYPOINT_ARGS ??= "/bin/sh"
OCI_IMAGE_ANNOTATION_MOUNTS += "/var/run/imtp/:/run/imtp/"
