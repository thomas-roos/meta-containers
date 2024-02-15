# Packagegroups usp endpoint

SUMMARY = "Minimal requirement to build LCM container"
PR = "r1"
# Packagegroups to start up lcm container

inherit packagegroup

RDEPENDS:${PN} =" \
    ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', d.getVar('VIRTUAL-RUNTIME_initscripts', True), '', d)} \
    inf-init-esimal \
    base-files \
    base-passwd \
    busybox \
    bash \
"
