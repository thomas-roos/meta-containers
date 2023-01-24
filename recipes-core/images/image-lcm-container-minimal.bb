require conf/lcm/lcm_oci.conf

SUMMARY = "An extremely minimal lcm container image"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

IMAGE_FSTYPES ?= "container tar.bz2 oci"
IMAGE_CMD ?= "/bin/sh"

inherit image
inherit image-oci
inherit image-oci-annotations

IMAGE_FEATURES = ""

IMAGE_LINGUAS = ""

NO_RECOMMENDATIONS = "1"

PREFERRED_PROVIDER_virtual/kernel = "linux-dummy"

IMAGE_INSTALL = " \
    inf-init-esimal \
    base-files \
    base-passwd \
    busybox \
    syslog-ng \
    bash \
"

IMAGE_INSTALL:append:develop += "\
     strace procps gdb valgrind tcpdump binutils nano \
"

IMAGE_INSTALL:append:release += "\
"

OCI_IMAGE_ENTRYPOINT ?= "/sbin/init"
OCI_IMAGE_ENTRYPOINT_ARGS ?= "/bin/sh"

