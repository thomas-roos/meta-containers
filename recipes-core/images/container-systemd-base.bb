SUMMARY = "Systemd system container for ${SYSTEMD_CONTAINER_APP}"
DESCRIPTION = "A small systemd system container which will run \
                ${SYSTEMD_CONTAINER_APP}."

SYSTEMD_CONTAINER_APP ?= ""

# Use local.conf to specify the application(s) to install
IMAGE_INSTALL += "${SYSTEMD_CONTAINER_APP}"

# Use local.conf to specify additional systemd services to disable. To overwrite
# the default list use SERVICES_TO_DISABLE:pn-systemd-container in local.conf
SERVICES_TO_DISABLE = "systemd-userdbd.service"
SERVICES_TO_DISABLE:append = " ${SYSTEMD_CONTAINER_DISABLE_SERVICES}"

# Use local.conf to enable systemd services
SERVICES_TO_ENABLE += "${SYSTEMD_CONTAINER_ENABLE_SERVICES}"

require container-systemd-base.inc


SYSTEMD_CONTAINER_DISABLE_SERVICES += " \
    systemd-resolved.service \
    var-volatile.mount \
"

IMAGE_FEATURES += "empty-root-password allow-empty-password allow-root-login serial-autologin-root"

IMAGE_INSTALL:append = " resolvconf systemd-serialgetty syslog-ng systemd-extra-utils systemd-conf"

OCI_IMAGE_ENTRYPOINT = "/sbin/init systemd.unified_cgroup_hierarchy=1"

DISTRO_FEATURES:remove = "sysvinit"