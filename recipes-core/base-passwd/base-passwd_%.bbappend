FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://group.master \
            file://passwd.master"


do_install:append(){
    install -m 0644 ${WORKDIR}/group.master ${D}/usr/share/base-passwd/group.master
    install -m 0644  ${WORKDIR}/passwd.master ${D}/usr/share/base-passwd/passwd.master
}