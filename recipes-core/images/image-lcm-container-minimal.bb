# Compare  from basic image, this image will add the tools to communicate between host and the container

require recipes-core/images/image-lcm-container-basic.bb

# Value to define
LCM_SYSBUS ??= "ubus"
# You should set the sysbus feature : Choice : pcb-bus | ubus
# if PCB sys selected, other configuration exist:
# Change startup script to 11 (from default 01)
# CONFIG_PCB_SYSBUS_LVL ?= "11"
# PCB_USERID
# PCB_GROUPID
# PCB_USERMNGT_GROUPID
# You should think to override the default values defined in the pcb-defaut conf


# Default feature to provide a LCM container image type: AMX and USP base package
IMAGE_FEATURES += " \
                   amx \
                   usp-base \
                   "

# Automatically determine the bus to include according the DISTRO_Feature variable
IMAGE_FEATURES += "${@bb.utils.contains('LCM_SYSBUS','ubus','ubus','',d)}"
IMAGE_FEATURES += "${@bb.utils.contains('LCM_SYSBUS','pcb-bus','pcb-bus','',d)}"


OCI_IMAGE_ENTRYPOINT ?= "/sbin/init"
OCI_IMAGE_ANNOTATION_MOUNTS += "/var/run/imtp/:/run/imtp/"
OCI_IMAGE_ENV_VARS = "INFINITESIMAL_BELOVED_PIDFILE=/var/run/ubus.pid"
