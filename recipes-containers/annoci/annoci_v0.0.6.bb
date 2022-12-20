inherit sah_base

SRC_URI = "git://${GIT_BASE_URL}/iot/lcm/tooling/annoci.git;protocol=https;nobranch=1;;nobranch=1;"
SRCREV = "v0.0.6"

S = "${WORKDIR}/git"
SUMMARY = "Annoci is a python script to add annotations to the oci image bundle"
LICENSE += "SAH & BSD-2-Clause-Patent"
LIC_FILES_CHKSUM = " \
                    file://LICENSE.SAH;md5=da1b9ff9606cbd748f6bc42ee064aa16 \
                    file://LICENSE.BSD;md5=a705237d3056b8a8c89eb03485d722ce \
                    "
RDEPENDS:${PN} += "python3"

COMPONENT = "annoci"
FILES:${PN} += "/usr/bin/${COMPONENT}"

BBCLASSEXTEND = "native nativesdk"
