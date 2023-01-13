

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

FILES:${PN} += "${BINDIR}/${COMPONENT}"

