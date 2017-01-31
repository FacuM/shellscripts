#!/bin/bash
# This is "compile", a shell script wich will help you build your kernel sources.
# ---------------------------
# Facundo Montero (facumo.fm@gmail.com)
# ---------------------------
#
# Functions definition
function prepare {
# EDIT "ARCH" AS NEEDED
 ARCH="arm"
 export ARCH
# EDIT "CROSS_COMPILE" AS NEEDED
 CROSS_COMPILE='~/arm-cortex_a7-linux-gnueabihf-linaro_4.9.4-2015.06/bin/arm-eabi-'
 export CROSS_COMPILE
 echo "Ready..."
}
function mk {
 if [ "$2" == "clean" ]
 then
  make clean
 else
  make -j4
 fi
}
function res {
 make mrproper
}
function tk {
 adb reboot botloader;fastboot boot arch/$ARCH/boot/zImage
}
function cfg {
 make menuconfig
}

# Script begins here
if [ "$1" == "mk" ] || [ "$1" == "res" ] || [ "$1" == "tk" ] || [ "$1" == "prepare" ] || [ "$1" == "cfg" ]
then
 prepare
 $1
else
 printf "Incorrect option: $1 $2 $3. \n\nUsage: \n\n$0 mk: make everything.\n$0 res: reset your sources. Removes .config and prepares for a new clean compilation (make mrproper).\n$0 tk: reboot your device to bootloader and boot the last compiled kernel.\n$0 cfg: run menuconfig utility.\n"
fi
