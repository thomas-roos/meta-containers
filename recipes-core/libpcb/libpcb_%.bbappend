# needed for pcb-sysbus serializers
CONFIG_PCB_HELP_SUPPORT = "y"

# Include the /lib/libpcb_%.so symlink in the normal package
FILES:${PN} += "/lib/libpcb_dm${SOLIBSDEV}"
FILES:${PN} += "/lib/libpcb_utils${SOLIBSDEV}"
FILES:${PN} += "/lib/libpcb_utils_sendfile${SOLIBSDEV}"
FILES:${PN} += "/lib/libpcb_ssl${SOLIBSDEV}"
FILES:${PN} += "/lib/libpcb_sl${SOLIBSDEV}"
FILES:${PN} += "/lib/libpcb_preload${SOLIBSDEV}"

FILES_SOLIBSDEV = ""
INSANE_SKIP:${PN} += "dev-so"
