require recipes-bsp/u-boot/u-boot.inc

# This revision corresponds to the tag "v2015.04"
# We use the revision in order to avoid having to fetch it from the repo during parse

PV = "2015.04"

#FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

# Copyright (C) 2016 Seco srl 
DESCRIPTION = "U-Boot provided by SECO for secoboards."
PROVIDES = "u-boot"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=c7383a594871c03da76b3707929d2919"

SCMVERSION = "n"
SRC_URI = "git://secogit.seco.com/imx6_release/u-boot-2015-04-secoboards-imx6-rel.git;user=betauser:betauser;protocol=https \
file://0002-patch-config.patch \ 
file://0001-bootscriptload-6aa8d4a4f6374b0709ba331ae5b902319871b65b.patch"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"


do_compile_prepend() {
        if [ "${MACHINE}" = "seco-b08" ]
          then
	    ./compile_b08.sh
 	    install -d ${DEPLOYDIR}
	    install -m 644 u-boot.imx   ${DEPLOYDIR}/
	    install -m 644 u-boot.spi   ${DEPLOYDIR}/
	    install -m 644 uEnv_b08.txt ${DEPLOYDIR}/
	fi
}

inherit fsl-u-boot-localversion

LOCALVERSION ?= "-${SRCBRANCH}"

PACKAGE_ARCH = "${MACHINE_ARCH}"
#COMPATIBLE_MACHINE = "(seco_928_quad_1gb)"

#UBOOT_MACHINE = "mx6dl_seco_config"
#UBOOT_MAKE_TARGET = "DDR_SIZE=2 DDR_TYPE=1 BOARD_TYPE=A62 CPU_TYPE=DUAL_LITE ENV_DEVICE=ENV_MMC "

