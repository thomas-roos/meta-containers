FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://init-chain-script.sh"
SRC_URI += "file://sbininit.sh"


do_install:append () {
    # install the script neccesary to make tini somewhat multiprocess
    # we've chosen for compatibility with update-rc.d, implement this in your background services
    install -D -m 0555 ${WORKDIR}/init-chain-script.sh ${D}/etc/init-chain-script.sh
    install -D -m 0555 ${WORKDIR}/sbininit.sh ${D}/sbin/init
}
