PV = "1.0"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=751419260aa954499f7abaabaa882bbe"
DESCRIPTION = "Support B08 800x480 Display"

SRC_URI = "file://COPYING \
           file://30-b08display.conf "

S = "${WORKDIR}"

do_install () {
    install -d ${D}/usr/share/X11/xorg.conf.d/
    install -m 644 ${FILE_DIRNAME}/${PN}-${PV}/30-b08display.conf ${D}/usr/share/X11/xorg.conf.d/
}

FILES_${PN} = "/usr/share/X11/xorg.conf.d/"

