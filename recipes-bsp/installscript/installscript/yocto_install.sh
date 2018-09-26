#!/bin/bash

eMMC="/dev/mmcblk0"

umount /run/media/* > /dev/null 2>&1
rm -f /tmp/yocto_install.lock

partition_emmc () {
	dd if=/dev/zero of=${eMMC} bs=16M count=4 > /dev/null 2>&1 
	fdisk ${eMMC} > /dev/null 2>&1 <<EEOF
n
p
1
1
+50M
t
b
n
p
2


w
EEOF
}

format_emmc () {
	mkfs.vfat -n BOOT ${eMMC}p1  > /dev/null 2>&1 
	mkfs.ext4 -L yocto ${eMMC}p2 > /dev/null 2>&1 
	sync
}

install_boot () {
        umount /run/media/* > /dev/null 2>&1
	mount ${eMMC}p1 /mnt
	mount /dev/mmcblk1p1 /run/media/mmcblk1p1
	cp -r /run/media/mmcblk1p1/* /mnt/ > /dev/null 2>&1 
	# find . -xdev -print0 | cpio -pm -0 /mnt
	sync
	umount /run/media/mmcblk1p1
	umount /mnt
}

install_yocto () {
	exclude_list="./tmp/ ./dev/ ./proc/ ./mnt/ ./sys/ ./run/ ./var/volatile/"
	exclude_file="/tmp/exclude.list"
	:> $exclude_file
	for dir in $exclude_list
	  do
		  echo $dir >> $exclude_file
	done

	mount ${eMMC}p2 /mnt
	cd /
	touch /tmp/yocto_install.lock
	find . -xdev | tar cf - -X $exclude_file -T - | (cd /mnt && tar xf - && cd / && rm /tmp/yocto_install.lock) > /dev/null 2>&1 &
	a=0

	while [ -f /tmp/yocto_install.lock ]
          do
	   (( a++ ))
           echo -n "."
           sleep 2
           [ $a -gt 20 ] && echo ""
           [ $a -gt 20 ] && a=0
        done
        echo ""
	cd /mnt
	for dir in $exclude_list
	  do
		  mkdir $dir 
	done
	chmod 1777 ./run/ ./var/volatile/ > /dev/null 2>&1
	chmod 0555 ./proc ./sys > /dev/null 2>&1
	rm -f ./etc/dropbear/dropbear_rsa_host_key > /dev/null 2>&1

	# find . -xdev -print0 | cpio -pm -0 /mnt
	sync
	cd /
	umount /mnt
}

echo ""
echo ""
echo " Installing."
echo "   - Partitioning system.      [ Step 1/4 ] "
partition_emmc
echo "   - Formatting                [ Step 2/4 ] "
format_emmc
echo "   - Writing boot partition.   [ Step 3/4 ] "
install_boot
echo "   - Writing system partition. [ Step 4/4 ] "
install_yocto
echo "  . . . Done."

exit 0
