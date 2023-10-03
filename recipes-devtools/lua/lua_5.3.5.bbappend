FILESEXTRAPATHS:prepend := "${FILE_DIRNAME}/${PN}:"

SRC_URI:append = "file://luaconf_patch_5.3.5.patch \
"

# Patch from LinuxFromScratch
SRC_URI:append = "file://lua_shared_object_5.3.5.patch \
"

do_install () {
    oe_runmake \
        'INSTALL_TOP=${D}${prefix}' \
        'INSTALL_BIN=${D}${bindir}' \
        'INSTALL_INC=${D}${includedir}/' \
        'INSTALL_MAN=${D}${mandir}/man1' \
        'INSTALL_SHARE=${D}${datadir}/lua' \
        'INSTALL_LIB=${D}${libdir}' \
        'INSTALL_CMOD=${D}${libdir}/lua/5.3' \
        'TO_LIB=liblua.so.5.3 liblua.so.5.3.4' \
        install
    install -d ${D}${libdir}/pkgconfig

    sed -e s/@VERSION@/${PV}/ ${WORKDIR}/lua.pc.in > ${WORKDIR}/lua.pc
    install -m 0644 ${WORKDIR}/lua.pc ${D}${libdir}/pkgconfig/
    rmdir ${D}${datadir}/lua/5.3
    rmdir ${D}${datadir}/lua
}

FILES:${PN} = "/usr/lib/liblua.so.5.3"
FILES:${PN} += "/usr/lib/lua/5.3/"
FILES:${PN} += "/usr/bin/luac"
FILES:${PN} += "/usr/bin/lua"

FILES:${PN}-dev = "/usr/lib/pkgconfig/lua.pc"
FILES:${PN}-dev += "/usr/lib/liblua.so.5.3.4"
FILES:${PN}-dev += "/usr/include/*"
