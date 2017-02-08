#!/bin/sh
printf "Backing up boot...\n"
su -c "dd if=/dev/block/bootdevice/by-name/boot of=/sdcard/boot.img"
if [ $? -eq 0 ]
then
 printf "Complete, saved to /sdcard/boot.img\n"
 exit 0
else
 printf "Something went wrong. (permissions problem?)\n"
 exit 1
fi
