FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
            file://sah_mount \
            file://sah_volatiles \
            file://sah_setup_lo \
           "

do_install:append() {
    install -D -m 644 ${WORKDIR}/sah_volatiles ${D}${sysconfdir}/default/volatiles/01_sah
    install -m 755 ${WORKDIR}/sah_mount ${D}${sysconfdir}/init.d
    install -m 755 ${WORKDIR}/sah_setup_lo ${D}${sysconfdir}/init.d

    update-rc.d -r ${D} sah_mount start 04 S .
    update-rc.d -r ${D} sah_setup_lo start 99 S .
}
