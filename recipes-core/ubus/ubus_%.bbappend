FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://ubusd.sh"

# Essentially just adding an init script to the ubus component

inherit update-rc.d
INITSCRIPT_NAME = "ubusd"
INITSCRIPT_PARAMS = "start 11 2 3 4 5 . stop 98 0 1 6 ."

do_install:append () {
    install -D -m 0755 ${WORKDIR}/ubusd.sh ${D}/etc/init.d/ubusd
}

FILES:${PN} += "${INITDIR}/${COMPONENT}"
