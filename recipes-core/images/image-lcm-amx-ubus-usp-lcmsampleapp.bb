require recipes-core/images/image-lcm-container-minimal.bb

SUMMARY = "LCM Container image for lcmsampleapp with ubus and usp"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

IMAGE_FSTYPES = "container tar.bz2 oci"

IMAGE_INSTALL += "\
    lcmsampleapp \
"

# IMAGE_INSTALL:append:develop += "\
#     strace procps gdb valgrind tcpdump binutils nano sshserver \
# "

# IMAGE_INSTALL:append:release += "\
#     ssh \
# "

# IMAGE_INSTALL:<MACHINE> += "\
#     <...> \
# " (not related to LCM from the lcm minimal image)


# Application to install

#OCI configuration
## application to run
OCI_IMAGE_ENTRYPOINT ?= "/${sbindir}/init"
