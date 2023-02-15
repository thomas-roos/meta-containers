

S = "${WORKDIR}/git"

inherit pkgconfig

SUMMARY = "Init chain loader to load /etc/rc{3;6}/ scripts and a beloved child process"
LICENSE += "SAH & BSD-2-Clause-Patent"

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
    oe_runmake install
    mkdir -m 755 ${D}/sbin
    ln -sfr ${D}/${bindir}/${COMPONENT} ${D}/sbin/init
}

FILES:${PN} += "${BINDIR}/${COMPONENT}"
FILES:${PN} += "/sbin/init"
