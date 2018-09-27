# Copyright (C) 2012-2015 O.S. Systems Software LTDA.
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Seco kernel based on the FSL BSP Linux"
DESCRIPTION = "Seco kernel provided support for all Released Secoboards."

require recipes-kernel/linux/linux-imx.inc
require recipes-kernel/linux/linux-dtb.inc

PV = "4.1.15"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

SCMVERSION = "n"
SRC_URI = "git://github.com/mathanrajmurugan/b08-kernel-bsp6.git;protocol=https \
file://defconfig_original \
file://defconfig"

do_configure_prepend() {
        if [ "${MACHINE}" = "seco-b08" ]
          then
             cp -v ${S}/arch/arm/configs/imx_v7_seco_b08_defconfig ${WORKDIR}/defconfig
        else
             cp -v ${WORKDIR}/defconfig_original ${WORKDIR}/defconfig
        fi
}

do_deploy_append() {
        if test -n "${KERNEL_DEVICETREE}"; then
                for DTB in ${KERNEL_DEVICETREE}; do
                        if echo ${DTB} | grep -q '/dts/'; then
                                bbwarn "${DTB} contains the full path to the the dts file, but only the dtb name should be used."
                                DTB=`basename ${DTB} | sed 's,\.dts$,.dtb,g'`
                        fi
                        DTB_BASE_NAME=`basename ${DTB} .dtb`
                        DTB_NAME=`echo ${KERNEL_IMAGE_BASE_NAME} | sed "s/${MACHINE}/${DTB_BASE_NAME}/g"`
                        DTB_FULL_NAME=`echo ${KERNEL_IMAGE_SYMLINK_NAME} | sed "s/${MACHINE}/${DTB_BASE_NAME}/g"`
                        DTB_PATH="${B}/arch/${ARCH}/boot/dts/${DTB}"
                        if [ ! -e "${DTB_PATH}" ]; then
                                DTB_PATH="${B}/arch/${ARCH}/boot/${DTB}"
                        fi
                        install -d ${DEPLOYDIR}/dts
                        install -m 0644 ${DTB_PATH} ${DEPLOYDIR}/dts/${DTB_FULL_NAME}.dtb
                        install -m 0644 ${FILE_DIRNAME}/${PN}-${EXTENDPE}${PV}/uEnv.txt ${DEPLOYDIR}/uEnv_b08.txt
                done
        fi
}

SRCREV = "${AUTOREV}"

