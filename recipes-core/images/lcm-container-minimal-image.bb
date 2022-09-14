SUMMARY = "An extremely minimal lcm container image"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

IMAGE_FSTYPES ?= "container tar.bz2 oci"
IMAGE_CMD ?= "/sbin/init"

inherit image

IMAGE_FEATURES = ""

IMAGE_LINGUAS = ""

NO_RECOMMENDATIONS = "1"

PREFERRED_PROVIDER_virtual/kernel = "linux-dummy"

IMAGE_INSTALL = " \
    base-files \
    base-passwd \
    busybox \
"
