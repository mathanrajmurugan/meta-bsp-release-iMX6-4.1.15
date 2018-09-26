#!/bin/bash

type_Qseven="QSEVEN"
type_uQseven="UQSEVEN"
type_uSBC="uSBC"
type_A62="A62"
type_B08="B08"
type_A62_HMI="A62HMI"

type_cpu_q="QUAD"
type_cpu_dl="DUAL_LITE"
type_cpu_s="SOLO"
type_cpu_sx="SOLOX"

CONFIG_FILE=".yocto-seco-config"

env_MMC="MMC"
env_SATA="SATA"
env_SPI="SPI"

BACKTITLE='Yocto SECO config'

PATH_MACHINE="sources/meta-seco-bsp-release-2-0-rel/conf/machine/"

SELECTION=""
SEL_ITEM=1
SELECTION_COMP=""
SUBSEL=""
EXIT_RESPONCE=0
EXIT=0

# Default values
MEM_SIZE=3
BOARD=${type_Qseven}
CPU_TYPE=${type_cpu_q}
ENV_DEV=${env_MMC}
CLEAN="CLEAN"
EXTRA_UART=""
DEBUG_UART5=""
RTC_LOW_POWER=""
COMPILER_PATH="/opt/arm-fsl-linux-gnueabi/bin/arm-fsl-linux-gnueabi-"
UBOOT_BOARD_CONF="mx6q_quadmo747_928_config"
DTB_CONF="imx6q-seco_quadmo747_928.dtb"
SOC_FAMILY="mx6:mx6q"

# uBoot defconfig configuration options #
PATH_UBOOT_CONFIG_PATCH="sources/meta-seco-bsp-release-2-0-rel/recipes-bsp/u-boot/u-boot-seco/0002-patch-config.patch"
UBOOT_BOARD_CONF="mx6q_quadmo747_928_256MBx4_defconfig"
CONFIG_BOARD="CONFIG_TARGET_MX6SECO_Q7_928=y"
CONFIG_RAM="CONFIG_SECOMX6_1GB_4x256=y"
CONFIG_CPU="CONFIG_SECOMX6Q=y"


# Yocto variable
# BACKEND
BACKEND_X11="fsl-imx-x11"
BACKEND_FB="fsl-imx-fb"
BACKEND_XWAYLAND="fsl-imx-xwayland"
BACKEND_WAYLAND="fsl-imx-wayland"

# COMPILATION IMAGE 
IMAGE_CORE_IMAGE_MINIMAL="core-image-minimal"
IMAGE_CORE_IMAGE_BASE="core-image-base"
IMAGE_CORE_IMAGE_SATO="core-image-sato"
IMAGE_FSL_IMAGE_MACHINE_TEST="fsl-image-machine-test"
IMAGE_FSL_IMAGE_GUI="fsl-image-gui"
IMAGE_FSL_IMAGE_QT5="fsl-image-qt5"

BUILD_DIR="build_seco"
EXTRA_PACKETS=""
FLAGS_CHROMIUM=off

SUFFIX=""

#################################################################
#																#
#					CONFIG FILE FUNCTION						#
#																#
#################################################################

set_ConfFile() {
	echo "MEMORY_SIZE $MEM_SIZE" > $CONFIG_FILE
	echo "BOARD_TYPE $BOARD" >> $CONFIG_FILE
	echo "CPU_TYPE $CPU_TYPE" >> $CONFIG_FILE
	echo "ENV_DEVICE $ENV_DEV" >> $CONFIG_FILE
	echo "CLEAN_OP $CLEAN" >> $CONFIG_FILE
	echo "EXTRA_UART $EXTRA_UART" >> $CONFIG_FILE
	echo "DEBUG_UART5 $DEBUG_UART5" >> $CONFIG_FILE
	echo "RTC_LOW_POWER $RTC_LOW_POWER" >> $CONFIG_FILE
	echo "RTC_EXT $RTC_EXT" >> $CONFIG_FILE
	echo "BACKEND $BACKEND" >> $CONFIG_FILE
	echo "IMAGE_TYPE $IMAGE_TYPE" >> $CONFIG_FILE
	echo "BUILD_DIR $BUILD_DIR" >> $CONFIG_FILE
	echo "EXTRA_PACKETS $EXTRA_PACKETS" >> $CONFIG_FILE
	echo "FLAGS_CHROMIUM $FLAGS_CHROMIUM" >> $CONFIG_FILE
}

set_from_ConfFile() {

	if [[ -e $CONFIG_FILE ]]; then
		VAR=$(cat $CONFIG_FILE | grep "MEMORY_SIZE" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			MEM_SIZE=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "BOARD_TYPE" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			BOARD=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "CPU_TYPE" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			CPU_TYPE=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "ENV_DEVICE" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			ENV_DEV=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "CLEAN_OP" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			CLEAN=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "EXTRA_UART" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			EXTRA_UART=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "DEBUG_UART5" | awk '{print $2}')
                if [[ "${VAR}" != "" ]]; then
                        DEBUG_UART5=$VAR
                fi
		VAR=$(cat $CONFIG_FILE | grep "RTC_LOW_POWER" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			RTC_LOW_POWER=$VAR

		fi
		VAR=$(cat $CONFIG_FILE | grep "RTC_EXT" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
		RTC_EXT=$VAR

		fi
		VAR=$(cat $CONFIG_FILE | grep "BACKEND" | awk '{print $2}')
                if [[ "${VAR}" != "" ]]; then
                        BACKEND=$VAR
                fi
		 VAR=$(cat $CONFIG_FILE | grep "IMAGE_TYPE" | awk '{print $2}')
                if [[ "${VAR}" != "" ]]; then
                        IMAGE_TYPE=$VAR
                fi
		VAR=$(cat $CONFIG_FILE | grep "BUILD_DIR" | awk '{print $2}')
                if [[ "${VAR}" != "" ]]; then
                        BUILD_DIR=$VAR
                fi
		VAR=$(cat $CONFIG_FILE | grep "EXTRA_PACKETS" | colrm 1 14 )
                if [[ "${VAR}" != "" ]]; then
                        EXTRA_PACKETS=$VAR
                fi
		VAR=$(cat $CONFIG_FILE | grep "FLAGS_CHROMIUM" | awk '{print $2}')
                if [[ "${VAR}" != "" ]]; then
                        FLAGS_CHROMIUM=$VAR
                fi
	else
		echo "WARNING: Configuration file not found!"
		set_ConfFile
	fi
}


#################################################################
#																#
#						GRAPHIC FUNCTION						#
#																#
#################################################################


main_view() {
	# open fd
	exec 3>&1
	 
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "Seco Yocto Main Menu" \
			--backtitle "$BACKTITLE" \
			--ok-label "Select" \
			--default-item $SEL_ITEM \
			--cancel-label "Exit" \
			--menu "Please choose an operation:" 25 60 10 \
			1 "DDR Size -->" \
			2 "Board Type -->" \
			3 "CPU type -->" \
			4 "Environment device -->" \
			5 "Extra options -->" \
			6 "yocto build directory -->" \
			7 "yocto backend options -->" \
			8 "yocto image type -->" \
			9 "yocto extra packets -->" \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	
	if [[ "${SELECTION}" == "" ]]; then
		EXIT=1
 	fi
	# display values just entered
#	echo "$SELECTION"
	
}

ddr_size_view() {
	# open fd
	exec 3>&1
	VAL=(off off off off off)
	VAL[$MEM_SIZE]=on
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "DDR configuration" \
			--backtitle "$BACKTITLE" \
			--ok-label "Select" \
			--cancel-label "Exit" \
			--default-item $MEM_SIZE \
			--radiolist "Select DDR type:" 20 80 10 \
			0 "512M,  bus size 32, active CS = 1 (256Mx2)" ${VAL[0]} \
 			1 "1Giga, bus size 32, active CS = 1 (512Mx2)" ${VAL[1]} \
			2 "1Giga, bus size 64, active CS = 1 (256Mx4)" ${VAL[2]} \
			3 "2Giga, bus size 64, active CS = 1 (512Mx4)" ${VAL[3]} \
 			4 "4Giga, bus size 64, active CS = 2 (512Mx8) - for QSEVEN only" ${VAL[4]} \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
	else
		MEM_SIZE=$SELECTION
	fi	
}

board_type_view() {
	# open fd
	exec 3>&1
	VAL=(off off off off off off)
	case "$BOARD" in
			"$type_Qseven") VAL[0]=on;;
		   	"$type_uQseven") VAL[1]=on;;
			"$type_A62") VAL[2]=on;;
			"$type_uSBC") VAL[3]=on;;
			"$type_B08") VAL[4]=on;;
			"$type_A62_HMI") VAL[5]=on;;
	esac
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "Board type" \
			--backtitle "$BACKTITLE" \
			--ok-label "Ok" \
			--cancel-label "Exit" \
			--default-item $BOARD \
			--radiolist "Select Board type:" 20 60 10 \
			$type_Qseven "Qseven RevB board" ${VAL[0]} \
			$type_uQseven "Micro Qseven board" ${VAL[1]} \
			$type_A62 "A62 Single board" ${VAL[2]} \
			$type_uSBC "984 Single board" ${VAL[3]} \
			$type_B08 "B08 Single board" ${VAL[4]} \
			$type_A62_HMI "A62-HMI-10 Single board" ${VAL[5]}\
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	 
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
	else
		BOARD=$SELECTION
	fi	
}

cpu_type_view() {
	# open fd
	exec 3>&1
	VAL=(off off off off)
	case "$CPU_TYPE" in
			"$type_cpu_q") VAL[0]=on;;
			"$type_cpu_dl") VAL[1]=on;;
			"$type_cpu_s") VAL[2]=on;;
			"$type_cpu_sx") VAL[3]=on;;
	esac
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "CPU type" \
			--backtitle "$BACKTITLE" \
			--ok-label "Ok" \
			--cancel-label "Exit" \
			--radiolist "Select CPU type:" 20 60 10 \
			$type_cpu_q "iMX6 QUAD" ${VAL[0]} \
			$type_cpu_dl "iMX6 DUAL LITE" ${VAL[1]} \
 			$type_cpu_s "iMX6 SOLO" ${VAL[2]} \
 			$type_cpu_sx "iMX6 SOLOX" ${VAL[3]} \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	 
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
	else
		CPU_TYPE=$SELECTION
	fi	
}

env_dev_view() {
	# open fd
	exec 3>&1
	VAL=(off off off)
	case "$ENV_DEV" in
		 "${env_MMC}") VAL[0]=on;; 
		"${env_SATA}") VAL[1]=on;;
		 "${env_SPI}") VAL[2]=on;;
	esac
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "Environment device" \
			--backtitle "$BACKTITLE" \
			--ok-label "Ok" \
			--cancel-label "Exit" \
			--default-item $ENV_DEV \
			--radiolist "Select device for environmnet storing:" 20 60 10 \
			$env_MMC "SD/MMC as environment device"  ${VAL[0]} \
 			$env_SATA "SATA as environment device"  ${VAL[1]} \
			$env_SPI "SPI as enviroment device"  ${VAL[2]} \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
	else
		ENV_DEV=$SELECTION
	fi	
}

yocto_backend_view() {
	# open fd
        exec 3>&1
        VAL=(off off off off)
        case "$BACKEND" in
                 "${BACKEND_X11}") VAL[0]=on;;
                "${BACKEND_FB}") VAL[1]=on;;
                 "${BACKEND_XWAYLAND}") VAL[2]=on;;
		"${BACKEND_WAYLAND}") VAL[3]=on;;
        esac
        # Store data to $VALUES variable
        SELECTION=$(dialog --title "Backend Yocto Support" \
                        --backtitle "$BACKTITLE" \
                        --ok-label "Ok" \
                        --cancel-label "Exit" \
                        --default-item $ENV_DEV \
                        --radiolist "Select backend for graphics:" 20 60 10 \
                        $BACKEND_X11 "Xorg X11 as backend"  ${VAL[0]} \
                        $BACKEND_FB "Framebuffer as backend"  ${VAL[1]} \
                        $BACKEND_XWAYLAND "X and Wayland as backend"  ${VAL[2]} \
			$BACKEND_WAYLAND "Wayland as backend"  ${VAL[3]} \
                        2>&1 1>&3)

        # close fd
        exec 3>&-

        if [[ "${SELECTION}" == "" ]]; then
                echo "not select"
        else
                BACKEND=$SELECTION
        fi


}

yocto_image_type_view() {
        # open fd
        exec 3>&1
        VAL=(off off off off off off)
        case "$IMAGE_TYPE" in
                 "${IMAGE_CORE_IMAGE_MINIMAL}") VAL[0]=on;;
                "${IMAGE_CORE_IMAGE_BASE}") VAL[1]=on;;
                 "${IMAGE_CORE_IMAGE_SATO}") VAL[2]=on;;
                "${IMAGE_FSL_IMAGE_MACHINE_TEST}") VAL[3]=on;;
		 "${IMAGE_FSL_IMAGE_GUI}") VAL[4]=on;;
		 "${IMAGE_FSL_IMAGE_QT5}") VAL[5]=on;;
        esac
        # Store data to $VALUES variable
        SELECTION=$(dialog --title "Backend Yocto Support" \
                        --backtitle "$BACKTITLE" \
                        --ok-label "Ok" \
                        --cancel-label "Exit" \
                        --default-item $ENV_DEV \
                        --radiolist "Select backend for graphics:" 20 100 40 \
                        $IMAGE_CORE_IMAGE_MINIMAL "only allows a device to boot."  ${VAL[0]} \
                        $IMAGE_CORE_IMAGE_BASE "A console-only image"  ${VAL[1]} \
                        $IMAGE_CORE_IMAGE_SATO "This image supports X11 with a Sato theme, Pimlico applications"  ${VAL[2]} \
			$IMAGE_FSL_IMAGE_MACHINE_TEST "An FSL Community i.MX core image with console environment, no GUI"  ${VAL[3]} \
                        $IMAGE_FSL_IMAGE_GUI "This image is for X11, DirectFB, Frame Buffer and Wayland"  ${VAL[4]} \
			$IMAGE_FSL_IMAGE_QT5 "Builds a QT5 image for X11, Frame Buffer and Wayland backends"  ${VAL[5]} \
                        2>&1 1>&3)

        # close fd
        exec 3>&-

        if [[ "${SELECTION}" == "" ]]; then
                echo "not select"
        else
                IMAGE_TYPE=$SELECTION
        fi


}

extra_view() {
	# open fd
	exec 4>&1
	VAL=(off off off off off)
	if [[ "${CLEAN}" == "CLEAN" ]]; then
		VAL[0]=on   
	fi
	if [[ "${EXTRA_UART}" == "EXTRA_UART" ]]; then
		VAL[1]=on
	fi
	if [[ "${DEBUG_UART5}" == "DEBUG_UART5" ]]; then
                VAL[2]=on
    fi
	if [[ "${RTC_LOW_POWER}" == "RTC_LOW_POWER" ]]; then
                VAL[3]=on
        fi
	if [[ "${RTC_EXT}" == "RTC_EXT" ]]; then
                VAL[4]=on
        fi
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "Extra option" \
			--backtitle "$BACKTITLE" \
			--ok-label "Ok" \
			--cancel-label "Exit" \
			--checklist "General settings:" 20 60 10 \
			CLEAN "Clear befor compile" ${VAL[0]} \
			EXTRA_UART "Use an addition UART for a basic comunication" ${VAL[1]} \
			DEBUG_UART5 "Use UART5 as Serial Debug (only for 984 RevC Board)" ${VAL[2]} \
			RTC_LOW_POWER "Use low power RTC" ${VAL[3]} \
			RTC_EXT "Use external low power RTC" ${VAL[4]} \
			2>&1 1>&4)
	 
	# close fd
	exec 4>&-
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
		CLEAN="NOCLEAN"
	else
	        EXTRA_UART=""
		DEBUG_UART5=""
		RTC_LOW_POWER=""
		RTC_EXT=""
		str=${SELECTION//\"/""}
		IFS=' ' read -a array <<< "$str"
		for i in ${array[*]}; do
			if [[ "$i" == "CLEAN" ]]; then
				CLEAN="${i}"	
			fi
			if [[ "$i" == "EXTRA_UART" ]]; then
				EXTRA_UART="${i}"
			fi
			if [[ "$i" == "DEBUG_UART5" ]]; then
                                DEBUG_UART5="${i}"
                        fi
			if [[ "$i" == "RTC_LOW_POWER" ]]; then
                                RTC_LOW_POWER="${i}"
                        fi
			if [[ "$i" == "RTC_EXT" ]]; then
                                RTC_EXT="${i}"
                        fi
		done	
	fi	
}

compile_view() {
	EXIT_COMP=0
		# open fd
		exec 3>&1
		
		SELECTION_BUILD_DIRECTORY=$(dialog --title "yocto build directory:" \
				--backtitle "$BACKTITLE" \
				--nocancel \
                                        --inputbox "Enter build directory name here" 8 60 "$BUILD_DIR" \
                                        2>&1 1>&3)
		if [[ "${SELECTION_BUILD_DIRECTORY}" != "" ]]; then
                	BUILD_DIR=$SELECTION_BUILD_DIRECTORY
                fi
		# close fd
		exec 3>&-	

}

yocto_extra_packets() {
        EXIT_COMP=0
        while [[ $EXIT_COMP -ne 1 ]]; do
                # open fd
                exec 3>&1

                SELECTION_COMP=$(dialog --title "yocto packets options" \
                                --backtitle "$BACKTITLE" \
                                --ok-label "Ok" \
                                --cancel-label "Cancel" \
                                --backtitle "$BACKTITLE" \
                                --ok-label "Select" \
                                --cancel-label "Exit" \
                                --menu "Please choose an operation:" 25 60 10 \
                                1 "chromium browser" \
                                2 "extra packets" \
                                2>&1 1>&3)

                case "$SELECTION_COMP" in
                        "1") SUBSEL=$(dialog --title "Browser Support" \
	                        --backtitle "$BACKTITLE" \
        	                --ok-label "Ok" \
                	        --cancel-label "Exit" \
        	                --checklist "Select if you want to compile Chromium:" 20 60 10 \
                	        Browser "Chromium browser support" ${FLAGS_CHROMIUM} \
	                        2>&1 1>&3)
				echo "$SUBSEL $SUBSEL"
				if [[ "${SUBSEL}" == "" ]]; then
          				echo "not select"
					FLAGS_CHROMIUM=off
			        else
				        FLAGS_CHROMIUM=on
        			fi;;

                        "2") SUBSEL=$(dialog --title "" \
                                        --backtitle "$BACKTITLE" \
                                        --nocancel \
                                        --inputbox "Enter extra packets here" 8 60 "$EXTRA_PACKETS" \
                                        2>&1 1>&3)
                                        if [[ "${SUBSEL}" != "" ]]; then
                                                EXTRA_PACKETS=$SUBSEL
                                        fi;;
                          *) EXIT_COMP=1
                esac

                # close fd
                exec 3>&-

        done
}

function exit_view () {
	dialog --title "" \
			--backtitle "$BACKTITLE" \
			--extra-button \
			--extra-label "Yes, with Compile" \
			--cancel-label "No" \
			--yesno "Want to save before exiting?" 5 70
	EXIT_RESPONCE=$?
}

#function exit_view () {
#       dialog --title "" \
#                       --backtitle "$BACKTITLE" \
#                       --cancel-label "No" \
#                       --yesno "Want to save before exiting?" 5 70
#       EXIT_RESPONCE=$?
#clear
#}

#################################################################
#																#
#						COMPILE FUNCTION						#
#																#
#################################################################

function check_mem_size () {
	echo ""
	if [ "${BOARD}" == "${type_B08}" ]; then
		SUFFIX=-b08
		return
	fi
	if [ "${MEM_SIZE}" == "0" ]; then
		echo "RAM size selected: 512M,  bus size 32, active CS = 1 (256Mx2)"
		SUFFIX=${SUFFIX}-512MB
		CONFIG_RAM="CONFIG_SECOMX6_512MB_2x256=y"
	elif [ "${MEM_SIZE}" == "1" ]; then
		echo "RAM size selected: 1Giga, bus size 32, active CS = 1 (512Mx2)"
		SUFFIX=${SUFFIX}-512MBx2
		CONFIG_RAM="CONFIG_SECOMX6_1GB_2x512=y"
	elif [ "${MEM_SIZE}" == "2" ]; then
		echo "RAM size selected: 1Giga, bus size 64, active CS = 1 (256Mx4)"
		SUFFIX=${SUFFIX}-256MBx4
		CONFIG_RAM="CONFIG_SECOMX6_1GB_4x256=y"
	elif [ "${MEM_SIZE}" == "3" ]; then
		echo "RAM size selected: 2Giga, bus size 64, active CS = 1 (512Mx4)"
		SUFFIX=${SUFFIX}-2GB
		CONFIG_RAM="CONFIG_SECOMX6_2GB_4x512=y"
	elif [ "${MEM_SIZE}" == "4" ]; then
		echo "RAM size selected: 4Giga, bus size 64, active CS = 2 (512Mx8) - for QSEVEN only"
		SUFFIX=${SUFFIX}-4GB
		CONFIG_RAM="CONFIG_SECOMX6_4GB_8x512=y"
	else
		echo "ERROR: wrong DDR size selected"
		exit 0
	fi
}

function check_board_type () {
	echo ""
	if [ "${BOARD}" == "${type_Qseven}" ]; then
		echo "Board type selected: Qseven module"
		SUFFIX=${SUFFIX}-Q7
		CONFIG_BOARD="CONFIG_TARGET_MX6SECO_Q7_928=y"
	elif [ "${BOARD}" == "${type_uQseven}" ]; then
		echo "Board type selected: micro Qseven module"
		SUFFIX=${SUFFIX}-uQ7
		CONFIG_BOARD="CONFIG_TARGET_MX6SECO_UQ7_962=y"
	elif [ "${BOARD}" == "${type_uSBC}" ]; then
                echo "Board type selected: Micro Single Board"
                SUFFIX=${SUFFIX}-uSBC
		CONFIG_BOARD="CONFIG_TARGET_MX6SECO_USBC_A62=y"
	elif [ "${BOARD}" == "${type_A62}" ]; then
                echo "Board type selected: A62 Single Board"
                SUFFIX=${SUFFIX}-a62
		CONFIG_BOARD="CONFIG_TARGET_MX6SECO_USBC_A62=y"
	elif [ "${BOARD}" == "${type_A62_HMI}" ]; then
                echo "Board type selected: A62-HMI-10 Single Board"
                SUFFIX=${SUFFIX}-a62hmi
		CONFIG_BOARD="CONFIG_TARGET_MX6SECO_USBC_A62_10=y"
	elif [ "${BOARD}" == "${type_B08}" ]; then
                echo "Board type selected: B08 Single Board"
                SUFFIX=-b08
		CONFIG_BOARD="CONFIG_TARGET_MX6SECO_USBC_B08=y"
	else
		echo "ERROR: wrong board type selected"
		exit 0
	fi
}

function check_cpu_type () {
	echo ""
    if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
        #echo "make mx6q_seco_config"
		SUFFIX=${SUFFIX}-QD
		SOC_FAMILY="mx6:mx6q"
		CONFIG_CPU="CONFIG_SECOMX6Q=y"
    elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
        #echo "make mx6dl_seco_config"
		SUFFIX=${SUFFIX}-DL
		SOC_FAMILY="mx6:mx6dl"
		CONFIG_CPU="CONFIG_SECOMX6DL=y"
    elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
        #echo "make mx6solo_seco_config"
		SUFFIX=${SUFFIX}-S
		SOC_FAMILY="mx6:mx6dl"
		CONFIG_CPU="CONFIG_SECOMX6S=y"
    elif [ "${CPU_TYPE}" == "${type_cpu_sx}" ]; then
        #echo "make mx6solo_seco_config"
		# SUFFIX=${SUFFIX}-SX
		SOC_FAMILY="mx6:mx6sx"
		CONFIG_CPU="CONFIG_SECOMX6SX=y"
    else
		echo "ERROR: No CPU Type selected "
    fi
}
		
function check_env_device_type () {
	echo ""
	if [ "${ENV_DEV}" == "${env_MMC}" ]; then
		echo "Environment selected: MMC"
	elif [ "${ENV_DEV}" == "${env_SATA}" ]; then
		echo "Environment selected: SATA"
	elif [ "${ENV_DEV}" == "${env_SPI}" ]; then
		echo "Environment selected: SPI"
	else
		echo "ERROR: wrong environment selected"
		exit 0
	fi
}

function conf_cpu_and_ram_type () {
	echo ""
        if [ "${BOARD}" == "${type_Qseven}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
			UBOOT_BOARD_CONF="mx6q_quadmo747_928_512MB_defconfig"
		elif [ "${MEM_SIZE}" == "1" ] ; then
			UBOOT_BOARD_CONF="mx6q_quadmo747_928_512MBx2_defconfig"
		elif [ "${MEM_SIZE}" == "2" ] ; then
			UBOOT_BOARD_CONF="mx6q_quadmo747_928_256MBx4_defconfig"
		elif [ "${MEM_SIZE}" == "3" ] ; then
			UBOOT_BOARD_CONF="mx6q_quadmo747_928_2GB_defconfig"
		elif [ "${MEM_SIZE}" == "4" ] ; then
			UBOOT_BOARD_CONF="mx6q_quadmo747_928_4GB_defconfig"
		fi
            elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
            	if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_quadmo747_928_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_quadmo747_928_512MBx2_defconfig"
                elif [ "${MEM_SIZE}" == "2" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_quadmo747_928_256MBx4_defconfig"
                elif [ "${MEM_SIZE}" == "3" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_quadmo747_928_2GB_defconfig"
                elif [ "${MEM_SIZE}" == "4" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_quadmo747_928_4GB_defconfig"
                fi

            elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6s_quadmo747_928_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6s_quadmo747_928_512MBx2_defconfig"
		fi
            fi
        elif [ "${BOARD}" == "${type_uQseven}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6q_uq7_962_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6q_uq7_962_512MBx2_defconfig"
                elif [ "${MEM_SIZE}" == "2" ] ; then
                        UBOOT_BOARD_CONF="mx6q_uq7_962_256MBx4_defconfig"
                elif [ "${MEM_SIZE}" == "3" ] ; then
                        UBOOT_BOARD_CONF="mx6q_uq7_962_2GB_defconfig"
                fi
            elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_uq7_962_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_uq7_962_512MBx2_defconfig"
                elif [ "${MEM_SIZE}" == "2" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_uq7_962_256MBx4_defconfig"
                elif [ "${MEM_SIZE}" == "3" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_uq7_962_2GB_defconfig"
                fi
            elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6s_uq7_962_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6s_uq7_962_512MBx2_defconfig"
		fi
            fi
        elif [ "${BOARD}" == "${type_A62}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6q_SBC_A62_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6q_SBC_A62_512MBx2_defconfig"
                elif [ "${MEM_SIZE}" == "2" ] ; then
                        UBOOT_BOARD_CONF="mx6q_SBC_A62_256MBx4_defconfig"
                elif [ "${MEM_SIZE}" == "3" ] ; then
                        UBOOT_BOARD_CONF="mx6q_SBC_A62_2GB_defconfig"
                elif [ "${MEM_SIZE}" == "4" ] ; then
                        UBOOT_BOARD_CONF="mx6q_SBC_A62_4GB_defconfig"
                fi
            elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_SBC_A62_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_SBC_A62_512MBx2_defconfig"
                elif [ "${MEM_SIZE}" == "2" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_SBC_A62_256MBx4_defconfig"
                elif [ "${MEM_SIZE}" == "3" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_SBC_A62_2GB_defconfig"
                elif [ "${MEM_SIZE}" == "4" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_SBC_A62_4GB_defconfig"
                fi
            elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6s_SBC_A62_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6s_SBC_A62_512MBx2_defconfig"
		fi
            fi
	elif [ "${BOARD}" == "${type_A62_HMI}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6q_SBC_A62_10_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6q_SBC_A62_10_512MBx2_defconfig"
                elif [ "${MEM_SIZE}" == "2" ] ; then
                        UBOOT_BOARD_CONF="mx6q_SBC_A62_10_256MBx4_defconfig"
                elif [ "${MEM_SIZE}" == "3" ] ; then
                        UBOOT_BOARD_CONF="mx6q_SBC_A62_10_2GB_defconfig"
                elif [ "${MEM_SIZE}" == "4" ] ; then
                        UBOOT_BOARD_CONF="mx6q_SBC_A62_10_4GB_defconfig"
                fi
            elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_SBC_A62_10_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_SBC_A62_10_512MBx2_defconfig"
                elif [ "${MEM_SIZE}" == "2" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_SBC_A62_10_256MBx4_defconfig"
                elif [ "${MEM_SIZE}" == "3" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_SBC_A62_10_2GB_defconfig"
                elif [ "${MEM_SIZE}" == "4" ] ; then
                        UBOOT_BOARD_CONF="mx6dl_SBC_A62_10_4GB_defconfig"
                fi
            elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
		if [ "${MEM_SIZE}" == "0" ] ; then
                        UBOOT_BOARD_CONF="mx6s_SBC_A62_10_512MB_defconfig"
                elif [ "${MEM_SIZE}" == "1" ] ; then
                        UBOOT_BOARD_CONF="mx6s_SBC_A62_10_512MBx2_defconfig"
		fi
            fi
        elif [ "${BOARD}" == "${type_B08}" ]; then
		UBOOT_BOARD_CONF="seco_b08_defconfig"
        fi
}

function check_dtb () {

	echo ""
        if [ "${BOARD}" == "${type_Qseven}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
                  DTB_CONF="imx6q-seco_quadmo747_928.dtb"
            elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
                  DTB_CONF="imx6dl-seco_quadmo747_928.dtb"
            elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
                  DTB_CONF="imx6dl-seco_quadmo747_928.dtb"
            fi
        elif [ "${BOARD}" == "${type_uQseven}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
                DTB_CONF="imx6q-seco_uq7_962.dtb"
            elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
                DTB_CONF="imx6dl-seco_uq7_962.dtb"
            elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
                DTB_CONF="imx6dl-seco_uq7_962.dtb"
            fi
        elif [ "${BOARD}" == "${type_A62}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
                DTB_CONF="imx6q-seco_SBC_A62.dtb"
            elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
                DTB_CONF="imx6dl-seco_SBC_A62.dtb"
            elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
                DTB_CONF="imx6dl-seco_SBC_A62.dtb"
            fi
	elif [ "${BOARD}" == "${type_A62_HMI}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
                DTB_CONF="imx6q-seco_SBC_A62-10.dtb"
            elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
                DTB_CONF="imx6dl-seco_SBC_A62-10.dtb"
            elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
                DTB_CONF="imx6dl-seco_SBC_A62-10.dtb"
            fi
        elif [ "${BOARD}" == "${type_B08}" ]; then
                DTB_CONF="imx6sx-seco-b08-basic-lvds7.dtb imx6sx-seco-b08-full-lvds7.dtb imx6sx-seco-b08-full-rgb7.dtb imx6sx-seco-b08-basic-rgb7.dtb"
        fi





}

function create_machine() {

 export ARCH=arm
        export CROSS_COMPILE=$COMPILER_PATH

        SUFFIX=""
        #N.B. don't change this calling order
        check_board_type
        check_cpu_type
	conf_cpu_and_ram_type
        check_mem_size
        check_env_device_type
	check_dtb

        if [ "${EXTRA_UART}" == "EXTRA_UART" ]; then
                echo ""
                echo "Select the use of the EXTRA_UART"
                echo ""
        fi

        if [ "${DEBUG_UART5}" == "DEBUG_UART5" ]; then
                echo ""
                echo "Select the use of the DEBUG_UART5"
                echo ""
        fi


        if [ "${RTC_LOW_POWER}" == "RTC_LOW_POWER" ]; then
                echo ""
                echo "Select the use of the Low Power RTC"
                echo ""
        fi
        if [ "${RTC_EXT}" == "RTC_EXT" ]; then
                echo ""
                echo "Select the use of the external Low Power RTC"
                echo ""
        fi

MACHINE_CONF_NAME=`echo "seco${SUFFIX}.conf" | tr '[:upper:]' '[:lower:]'`
MACHINE_NAME=`echo "seco${SUFFIX}" | tr '[:upper:]' '[:lower:]'`

mkdir -p $PATH_MACHINE
#echo $MACHINE_NAME
echo ""
echo "#@TYPE: Machine" > $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#@NAME: SECO ${BOARD} board" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#@SOC: i.MX6 ${CPU_TYPE}" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#@DESCRIPTION: Machine configuration for SECO $BOARD board"  >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "require conf/machine/include/imx-base.inc" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "require conf/machine/include/tune-cortexa9.inc" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "SOC_FAMILY = \"${SOC_FAMILY}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#SCMVERSION = \"n\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME

if [ "${BOARD}" == "${type_B08}" ]; then
  echo "PREFERRED_PROVIDER_u-boot_mx6 ??= \"u-boot-seco-solox\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_PROVIDER_u-boot_${SOC_FAMILY:4:8} ??= \"u-boot-seco-solox\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_PROVIDER_virtual/bootloader_mx6 ??=\"u-boot-seco-solox\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_VERSION_u-boot-seco-solox = \"2015.04\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  #echo "#IMAGE_BOOTLOADER ?= \"u-boot\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
else
  echo "PREFERRED_PROVIDER_u-boot_mx6 ??= \"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_PROVIDER_u-boot_${SOC_FAMILY:4:8} ??= \"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_PROVIDER_virtual/bootloader_mx6 ??=\"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_VERSION_u-boot-seco = \"2015.04\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  #echo "#IMAGE_BOOTLOADER ?= \"u-boot\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
fi

echo "UBOOT_CONFIG ??= \"sd\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "UBOOT_CONFIG[sd] = \"${UBOOT_BOARD_CONF}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "UBOOT_MAKE_TARGET = \"\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME

if [ "${BOARD}" == "${type_A62_HMI}" ]; then
  echo "do_rootfs[depends] += \"sbc-bootscript-sdupdate:do_deploy\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "BOOT_SCRIPTS = \"bootscript-update\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
else
  echo "do_rootfs[depends] += \"sbc-bootscript-sd:do_deploy\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "BOOT_SCRIPTS = \"bootscript\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
fi

echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
if [ "${BOARD}" == "${type_B08}" ]; then
  echo "IMAGE_INSTALL_append = \" wilink8-fw \"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "IMAGE_INSTALL_append = \" bluetoothstart \"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "IMAGE_INSTALL_append = \" fix-xorg-conf \"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "IMAGE_INSTALL_append = \" installscript \"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "IMAGE_INSTALL_append = \" uimsys \"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo ""  >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "USER_CLASSES += \" fiximage \"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "IMAGE_POSTPROCESS_COMMAND += \" fix_boot_image \"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
fi
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
if [ "${BOARD}" == "${type_B08}" ]; then
  echo "PREFERRED_PROVIDER_virtual/kernel_$MACHINE_NAME = \"linux-seco-solox\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_PROVIDER_virtual/kernel_mx6 = \"linux-seco-solox\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_PROVIDER_virtual/kernel_${SOC_FAMILY:4:8} = \"linux-seco-solox\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_PROVIDER_virtual/kernel = \"linux-seco-solox\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_VERSION_linux-seco-solox = \"4.1.15\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "KERNEL_DEVICETREE = \"${DTB_CONF}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "SERIAL_CONSOLE = \"115200 ttymxc1\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "KERNEL_IMAGETYPE = \"zImage\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
else
  echo "PREFERRED_PROVIDER_virtual/kernel_$MACHINE_NAME = \"linux-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_PROVIDER_virtual/kernel_mx6 = \"linux-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_PROVIDER_virtual/kernel_${SOC_FAMILY:4:8} = \"linux-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_PROVIDER_virtual/kernel = \"linux-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "PREFERRED_VERSION_linux-seco = \"4.1.15\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "KERNEL_DEVICETREE = \"${DTB_CONF}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "SERIAL_CONSOLE = \"115200 ttymxc1\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
  echo "KERNEL_IMAGETYPE = \"zImage\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
fi

echo "MACHINE_FEATURES += \"wifi\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME

echo "MACHINE_EXTRA_RRECOMMENDS += \"$EXTRA_PACKETS\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
if [ $FLAGS_CHROMIUM == on  ]; then
echo "CORE_IMAGE_EXTRA_INSTALL += \"chromium\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "LICENSE_FLAGS_WHITELIST=\"commercial\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
fi
echo "PREFERRED_PROVIDER_virtual/mesa = \"\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME

# Create u-Boot board defconfig #
echo "" > $PATH_UBOOT_CONFIG_PATCH
if [ "${BOARD}" == "${type_B08}" ]; then 
  echo "diff --git a/configs/${UBOOT_BOARD_CONF}_no b/configs/${UBOOT_BOARD_CONF}_no" >> $PATH_UBOOT_CONFIG_PATCH
  echo "new file mode 100644" >> $PATH_UBOOT_CONFIG_PATCH
  echo "--- /dev/null" >> $PATH_UBOOT_CONFIG_PATCH
  echo "+++ b/configs/${UBOOT_BOARD_CONF}_no" >> $PATH_UBOOT_CONFIG_PATCH
else
  echo "diff --git a/configs/$UBOOT_BOARD_CONF b/configs/$UBOOT_BOARD_CONF" >> $PATH_UBOOT_CONFIG_PATCH
  echo "new file mode 100644" >> $PATH_UBOOT_CONFIG_PATCH
  echo "--- /dev/null" >> $PATH_UBOOT_CONFIG_PATCH
  echo "+++ b/configs/$UBOOT_BOARD_CONF" >> $PATH_UBOOT_CONFIG_PATCH
fi
echo "@@ -0,0 +1,7 @@" >> $PATH_UBOOT_CONFIG_PATCH
echo "+CONFIG_ARM=y" >> $PATH_UBOOT_CONFIG_PATCH
echo "+$CONFIG_CPU" >> $PATH_UBOOT_CONFIG_PATCH
echo "+$CONFIG_BOARD" >> $PATH_UBOOT_CONFIG_PATCH
echo "+$CONFIG_RAM" >> $PATH_UBOOT_CONFIG_PATCH
echo "+CONFIG_DM=y" >> $PATH_UBOOT_CONFIG_PATCH
echo "+CONFIG_DM_THERMAL=y" >> $PATH_UBOOT_CONFIG_PATCH
echo "+CONFIG_CMD_SECO_CONFIG=y" >> $PATH_UBOOT_CONFIG_PATCH

echo "To begin yocto building launch :"
echo "$ DISTRO=$BACKEND MACHINE=$MACHINE_NAME source seco-setup-release.sh -b <build dir>"
echo ""
echo ""
echo "and then launch (for example):"
echo "$ bitbake fsl-image-qt5"





}

function compile () {

	create_machine
	DISTRO=$BACKEND MACHINE=$MACHINE_NAME source seco-setup-release.sh -b $BUILD_DIR
	bitbake $IMAGE_TYPE
}

#################################################################
#																#
#																#
#################################################################

function help_view () {
	echo "SECO Yocto Configurator"
	echo "Usage: $0 [-c for configuration option]"
	echo
}

set_from_ConfFile
while getopts ":m:b:p:dch" optname; do
	case "$optname" in
		"c") while [[ $EXIT -ne 1 ]]; do
			main_view
			SEL_ITEM=$SELECTION
			case "$SELECTION" in
				"1") ddr_size_view;;
				"2") board_type_view;;
				"3") cpu_type_view;;
				"4") env_dev_view;;
				"5") extra_view;;
				"6") compile_view;;
				"7") yocto_backend_view;;
				"8") yocto_image_type_view;;
				"9") yocto_extra_packets;;
				  *) echo "" ;;
			esac
		done
		exit_view
		case "${EXIT_RESPONCE}" in
			  "0") set_ConfFile; clear; echo "Configuration saved!"; create_machine;;
			  "1") clear; echo "Configuration not saved!";;
			  "3") set_ConfFile; clear; echo "Configuration saved!"; compile;;
			"255") clear;  echo "Configuration not saved!";;
			*) clear;
		esac
		exit 0;;

		h) help_view
			 exit 0;;	
		*) echo "ERROR: option not valid!"
                         help_view
                         exit 1;;
	esac
done

#if no any option is present, the compilation start directly
compile

