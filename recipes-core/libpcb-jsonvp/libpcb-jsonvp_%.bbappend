# Include the /lib/libpcb_jsonvp.so symlink in the normal package
FILES:${PN}-dev = ""
FILES:${PN} = ""
FILES:${PN}-staticdev = ""

FILES:${PN} += "/lib/libpcb_jsonvp${SOLIBS}"
FILES:${PN}-dev += "${INCLUDEDIR}/pcb_jsonvp.h"
FILES:${PN}-dev += "${PKG_CONFIG_LIBDIR}/pcb_jsonvp.pc"

FILES:${PN} += "/lib/libpcb_jsonvp${SOLIBSDEV}"

FILES_SOLIBSDEV = ""
INSANE_SKIP:${PN} += "dev-so"
