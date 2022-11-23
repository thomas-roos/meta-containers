SRC_URI += "git://${GIT_BASE_URL}/network/services_udev.git;nobranch=1;tag=gen_172;protocol=https;nobranch=1;;destsuffix=sahgit"

do_install:append(){
    install -d ${D}/lib/udev/rules.d/
    install -d ${D}/lib/udev/devices/net

    rm ${D}/lib/udev/rules.d/*
    install -m 0644 ${WORKDIR}/sahgit/rules/sah/*  ${D}/lib/udev/rules.d/
   
    mknod ${D}/lib/udev/devices/null -m 0600 c 1 3
    mknod ${D}/lib/udev/devices/console -m 0600 c 5 1
    mknod ${D}/lib/udev/devices/net/tun -m 0600 c 10 200

}