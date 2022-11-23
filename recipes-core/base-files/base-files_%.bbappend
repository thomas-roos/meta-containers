FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

hostname:pn-base-files ??= "sahhgw"

ROOT_HOME ?= "/root"

dirs755:remove = "/home /media /usr/games ${datadir}/dict ${infodir} \
                 ${mandir} ${datadir}/misc ${localstatedir}/backups \
                 ${localstatedir}/lib/misc ${localstatedir}/spool ${ROOT_HOME}"

do_install:append(){
	install -d ${D}/etc/defaults
	install -d ${D}/mnt
	install -d ${D}/cfg

# SOP legacy
#    ln -sf /cfg/common/config ${D}/etc/config
#    ln -sf /cfg/system/home ${D}/home
#    ln -sf /cfg/system/root ${D}/root
#    ln -sf /var/run/resolv.conf ${D}/etc/resolv.conf

#    ln -sf volatile/dev ${D}/var/dev
#    ln -sf volatile/etc ${D}/var/etc
#    ln -sf volatile/ntp ${D}/var/ntp
#    ln -sf volatile/dect ${D}/var/dect

}
