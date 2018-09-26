PV = "1.0"

# Copyright (C) 2016 Seco srl 
DESCRIPTION = "Wlink8 firmware."
PROVIDES = "installscript"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://LICENCE;md5=fcd40f6cb09221b0782c1d09ba266911"

SCMVERSION = "n"
SRC_URI = "file://LICENCE \
	   file://yocto_install.sh"

SRCREV = "${AUTOREV}"

S = "${WORKDIR}"

do_install () {
    install -d ${D}/home/root/
    install -m 755 ${FILE_DIRNAME}/${PN}/yocto_install.sh ${D}/home/root/
}

FILES_${PN} = "/home/root/"

LOCALVERSION ?= "-${SRCBRANCH}"

