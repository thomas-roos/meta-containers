SRC_URI += "git://${GIT_BASE_URL}/network/packaging_gwrootfs.git;nobranch=1;tag=master;protocol=https;nobranch=1;;destsuffix=packaginggwrootfs"

do_install:append() {
    install -m 755 ${WORKDIR}/packaginggwrootfs/etc/network/if-pre-up.d/vlan ${D}${sysconfdir}/network/if-pre-up.d/vlan
    install -m 755 ${WORKDIR}/packaginggwrootfs/etc/network/if-post-down.d/vlan ${D}${sysconfdir}/network/if-post-down.d/vlan

    install -d ${D}/lib/bridge-utils/
    install -m 755 ${WORKDIR}/packaginggwrootfs/lib/bridge-utils/bridge-utils.sh ${D}/lib/bridge-utils/bridge-utils.sh
    install -m 755 ${WORKDIR}/packaginggwrootfs/lib/bridge-utils/ifupdown.sh ${D}/lib/bridge-utils/ifupdown.sh
    ln -sf /lib/bridge-utils/ifupdown.sh ${D}${sysconfdir}/network/if-pre-up.d/bridge
    ln -sf /lib/bridge-utils/ifupdown.sh ${D}${sysconfdir}/network/if-post-down.d/bridge

    install -d ${D}/etc/init.d/
    install -m 755 ${WORKDIR}/packaginggwrootfs/etc/init.d/networking ${D}/etc/init.d/
}

FILES:${PN} += "/lib/bridge-utils/*"

inherit sah_initscripts
INITSCRIPT_PARAM="networking:71:29"
