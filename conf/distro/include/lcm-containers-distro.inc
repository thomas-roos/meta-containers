# import from meta-lcm-containers
require conf/lcm/lcm.conf

DISTRO_FEATURES ?= "sysvinit ipv4 ipv6 largefile ldconfig xattr argp ${DISTRO_FEATURES_LIBC}"

# RUST
#TODO RUST_VERSION ?= "1.66.0"
#TODO include conf/distro/include/rust_versions.inc

# By default built debugfs
IMAGE_GEN_DEBUGFS ?= "1"
IMAGE_FSTYPES_DEBUGFS ?= "tar.bz2"
PACKAGE_DEBUG_SPLIT_STYLE ?= "debug-without-src"

#
# Buildinfo
#
# Enabling generation of build info file in target rootfs
#
INHERIT += "image-buildinfo"
IMAGE_BUILDINFO_FILE = "/build.txt"
IMAGE_BUILDINFO_VARS:append = " DATETIME DISTRO_NAME IMAGE_BASENAME MACHINE"
IMAGE_BUILDINFO_VARS:append = " BUILD_ID IMAGE_NAME IMAGE_VERSION"
IMAGE_BUILDINFO_VARS:append = " DISTRO_FEATURES COMMON_FEATURES IMAGE_FEATURES"

# default values for OCI Image
OCI_IMAGE_AUTHOR ?= "prplfoundation"
OCI_IMAGE_AUTHOR_EMAIL ?= "info@prplfoundation.org"
OCI_IMAGE_ANNOTATION_VENDOR ?= "prplfoundation"
PATCH_GIT_USER_NAME ?= "prplfoundation"
PATCH_GIT_USER_EMAIL ?= "info@prplfoundation.org"
