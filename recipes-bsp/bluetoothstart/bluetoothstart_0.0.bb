DESCRIPTION = "Bluetooth daemon start/stop script"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://bluetooth;md5=433ff2a2f11e811791a2b346cc71b302"

INITSCRIPT_NAME = "bluetooth"
INITSCRIPT_PARAMS = "defaults 04"

inherit update-rc.d

SRC_URI = "file://bluetooth "

S = "${WORKDIR}"

do_install() {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/bluetooth ${D}${sysconfdir}/init.d
}
