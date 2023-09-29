FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://ubusd.sh"
SRC_URI += "file://LICENSE.BSD"

SUMMARY = "LCM init script for ubusd"
LICENSE += "BSD-2-Clause-Patent"

LIC_FILES_CHKSUM = " \
                    file://${WORKDIR}/LICENSE.BSD;md5=6985054d3f2d7dbde00e278406c8cda2 \
                    "

# Essentially just adding an init script to the ubusd component
inherit update-rc.d
INITSCRIPT_NAME = "ubusd"
INITSCRIPT_PARAMS = "start 11 2 3 4 5 . stop 98 0 1 6 ."

do_install:append () {
    install -D -m 0755 ${WORKDIR}/ubusd.sh ${D}/etc/init.d/ubusd
}

FILES:${PN} += "/etc/init.d/ubusd"
