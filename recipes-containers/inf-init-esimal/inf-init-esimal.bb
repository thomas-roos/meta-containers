FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://inf-init-esimal/"

S = "${WORKDIR}/inf-init-esimal"

inherit pkgconfig

SUMMARY = "Init chain loader to load /etc/rc{3;6}/ scripts and a beloved child process"
LICENSE += "BSD-2-Clause-Patent"

LIC_FILES_CHKSUM = " \
                    file://LICENSE.BSD;md5=6985054d3f2d7dbde00e278406c8cda2 \
                    "

COMPONENT = "inf-init-esimal"

EXTRA_OEMAKE += "DEST=${D} \
                 PREFIX=${prefix} \
                 LIBDIR=${libdir} \
                 BINDIR=${bindir} \
                 INCLUDEDIR=${includedir} \
                 "

do_install () {
    # install the symlink to /sbin/init
    # we've chosen for compatibility with update-rc.d, implement this in your background services
    mkdir -m 755 ${D}/sbin
    install -D -p -m 0755 ./src/${COMPONENT} ${D}/${bindir}/${COMPONENT}
    ln -sfr ${D}/${bindir}/${COMPONENT} ${D}/sbin/init
}

FILES:${PN} += "${BINDIR}/${COMPONENT}"
FILES:${PN} += "/sbin/init"
