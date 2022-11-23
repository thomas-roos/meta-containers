FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://syslog-ng.conf"
SRC_URI += "file://initscript"


do_install:append () {
    install -D -m 0644 ${WORKDIR}/syslog-ng.conf ${D}/etc/syslog-ng/syslog-ng.conf
}

INITSCRIPT_PARAMS = "start 01 2 3 4 5 . stop 99 0 1 6 ."
