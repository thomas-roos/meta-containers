SRCREV = "a0ecdde0c042b9256170f2f8890dd9451a4240aa"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-add-pkgconfig-flags.patch"

BBCLASSEXTEND += "native"

