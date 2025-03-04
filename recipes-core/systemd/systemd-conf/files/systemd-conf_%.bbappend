FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://getty-override.conf"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}/console-getty.service.d
    install -m 0644 ${WORKDIR}/getty-override.conf ${D}${systemd_system_unitdir}/console-getty.service.d/override.conf
}
