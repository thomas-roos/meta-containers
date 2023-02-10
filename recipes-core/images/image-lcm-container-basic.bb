require conf/lcm/lcm_oci.conf

SUMMARY = "An extremely minimal lcm container image"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

IMAGE_FSTYPES += "container tar.bz2 oci"
IMAGE_CMD ?= "/bin/sh"

inherit image
inherit lcm-image
inherit image-oci

IMAGE_FEATURES += "lcm-core"

IMAGE_LINGUAS = ""

NO_RECOMMENDATIONS = "1"

PREFERRED_PROVIDER_virtual/kernel = "linux-dummy"

IMAGE_INSTALL:append:develop += "\
     strace procps gdb valgrind tcpdump binutils nano \
"

IMAGE_INSTALL:append:release += "\
"

OCI_IMAGE_ENTRYPOINT ?= "/sbin/init"
OCI_IMAGE_ENTRYPOINT_ARGS ?= "/bin/sh"

