# IMAGE_FEATURES control content of the lcm image type
# 
# By default we install amx and usp endpoint packages;
# to enable integration of LCM images inside prpl host environment
#
# Available IMAGE_FEATURES:



FEATURE_PACKAGES_pcb-bus = "packagegroup-pcb" 
FEATURE_PACKAGES_usp-endpoint = "packagegroup-usp-endpoint" 
FEATURE_PACKAGES_usp-base = "packagegroup-usp-base"
FEATURE_PACKAGES_amx = "packagegroup-amx-core" 
FEATURE_PACKAGES_ubus = "packagegroup-ubus" 
FEATURE_PACKAGES_lcm-core = "packagegroup-lcm-core"

FEATURE_PACKAGES_lua-amx += "\
    lua \
    lua-amx \
    mod-lua-amx \
"

FEATURE_PACKAGES_python-amx += "\
    python-amx \
    python3 \
    python3-pip \
    python3-async \
"

python do_notification() {
    sysbus = d.getVar('LCM_SYSBUS')
    if sysbus :
        bb.warn("Sysbus selected : {}".format(sysbus))
}
do_notification[nostamp] = "1"
addtask do_notification before do_image
