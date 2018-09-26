# Copyright (C) 2016 Seco srl 
DESCRIPTION = "Wlink8 firmware."
PROVIDES = "wlink8_fw"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://LICENCE;md5=4977a0fe767ee17765ae63c435a32a9e"

SCMVERSION = "n"
SRC_URI = "git://git.ti.com/wilink8-wlan/wl18xx_fw.git;protocol=git \
           file://TIInit_11.8.32.bts "

SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

do_install () {
    install -d ${D}/lib/firmware/ti-connectivity
    install -m 644 *.bin ${D}/lib/firmware/ti-connectivity/
    install -m 0644 ${WORKDIR}/TIInit_11.8.32.bts ${D}/lib/firmware/ti-connectivity/
}

FILES_${PN} = "/lib/firmware/* /lib/firmware/ti-connectivity/*"

LOCALVERSION ?= "-${SRCBRANCH}"

