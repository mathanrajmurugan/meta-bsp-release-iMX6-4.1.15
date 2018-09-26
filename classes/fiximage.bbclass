
IMG_TMP_PATH = "/tmp/boot_tmp.img"

fix_boot_image () {
     dd    if=${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-seco-b08.sdcard of=${IMG_TMP_PATH} bs=512 skip=8192 count=16384
     mcopy -i ${IMG_TMP_PATH} ${DEPLOY_DIR_IMAGE}/u-boot.imx   ::/
     mcopy -i ${IMG_TMP_PATH} ${DEPLOY_DIR_IMAGE}/u-boot.spi   ::/
     mcopy -i ${IMG_TMP_PATH} ${DEPLOY_DIR_IMAGE}/uEnv_b08.txt ::/uEnv.txt
     mmd   -i ${IMG_TMP_PATH} ::/dts
     mdel  -i ${IMG_TMP_PATH} ::/bootscript
     mmove -i ${IMG_TMP_PATH} ::/*dtb      ::/dts/
     dd    if=${IMG_TMP_PATH} of=${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-seco-b08.sdcard bs=512 seek=8192 conv=notrunc
     rm    ${IMG_TMP_PATH}
}

