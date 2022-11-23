FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://syslog-ng.conf"

do_install:append () {
    install -D -m 0644 ${WORKDIR}/syslog-ng.conf ${D}/etc/syslog-ng/syslog-ng.conf
}
