CONFIG_SAH_LUA_AMX_LUA_VERSION_OVERRIDE ?= "y"
CONFIG_SAH_LUA_AMX_LUA_VERSION ?= ""

do_install:append () {
    # Fix the recipe so it corresponds with lua in yocto
    mkdir -p ${D}/usr/lib/lua/5.3/
    ln -sfr ${D}/usr/local/lib/lua/lamx.so ${D}/usr/lib/lua/5.3/lamx.so
    mkdir -p ${D}/usr/share/lua/5.3/
    ln -sfr ${D}/usr/local/lib/lua/lamx/lamx_wait_for.lua ${D}/usr/share/lua/5.3/lamx_wait_for.lua
}

FILES:${PN} = "/usr/local/lib/lua/lamx.so"
FILES:${PN} += "/usr/local/lib/lua/lamx_wait_for.lua"
FILES:${PN} += "/usr/bin/amx_monitor_dm"
FILES:${PN} += "/usr/bin/amx_wait_for"
FILES:${PN} += "/usr/lib/lua/5.3/lamx.so"
FILES:${PN} += "/usr/share/lua/5.3/lamx_wait_for.lua"
FILES_SOLIBSDEV = ""
INSANE_SKIP:${PN} += "dev-so"
