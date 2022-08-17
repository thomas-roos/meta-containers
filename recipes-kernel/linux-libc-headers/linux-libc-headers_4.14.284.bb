KORG_ARCHIVE_COMPRESSION = "xz"

require recipes-kernel/linux-libc-headers/linux-libc-headers.inc

SRC_URI[md5sum] = "12370a5b155c34c24ed9a8227885bd26"
SRC_URI[sha256sum] = "9852cca0a93111979ae5d372d2592d9224576d80c6d85781736419a5638bebb8"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

# Ugly fix for missing bpf_perf_event.h
do_install_armmultilib:prepend() {
    if [ ! -f ${D}${includedir}/asm/bpf_perf_event.h ]; then
        echo "!! ${D}${includedir}/asm/bpf_perf_event.h missing !! --> install empty file"
        touch ${D}${includedir}/asm/bpf_perf_event.h
    else
        echo "!! ${D}${includedir}/asm/bpf_perf_event.h present !!"
    fi
}
