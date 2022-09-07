require recipes-core/images/lcm-container-minimal-image.bb

SUMMARY = "IOT container image (orange split poc)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

IMAGE_INSTALL += "\
    packagegroup-amx-core \
    amx-greeter-app \
    amxb-inspect \
    amx-fcgi \
    lighttpd \
    amx-cli \
    libimtp \
    libusp \
    libuspprotobuf \
    mod-amxb-usp \
    usp-endpoint \
"
