#!/bin/bash
if [ "$1" == 'd' ] || [ "$1" == 'l' ]
then
 function err() { echo "Something went wrong, please check the errors above."; exit 1; }
 if [ "$1" == 'd' ]
 then
  curl "$2" > zImage || err
 fi
 adb reboot bootloader || echo "Couldn't reboot, already in fastboot?"
 fastboot boot zImage || err
 exit 0
else
 printf "\nUsage: \n\n\n\tbash testzImage.sh <d|l> <zImage URL>\n\n"
fi
