#!/bin/bash
#=====================================================#
#      Quickly set up a tested build environment      #
#=====================================================#
#             => facumo.fm@gmail.com <=               #
#=====================================================#
#
# Get installed RAM
MAXRAMAM=`cat /proc/meminfo | head -1 | sed 's/MemTotal:        //g' | sed 's/ kB//g'`
# If RAM is less than 8 GB, abort.
if [ $MAXRAMAM -lt 8000000 ]
then
 echo 'This script has been tested and made for computers with 8 GB of RAM or more.'
 exit 1
fi
# Set up the environment...
# Check if toolchain is present
if [ ! -d "$HOME/arm-eabi-7.0" ]
then
 echo "Error: arm-eabi-7.0 toolchain isn\'t present, please download it and make sure you did it in the right path."
 exit 1
fi
# Set variables
printf "export CROSS_COMPILE='$HOME/arm-eabi-7.0/bin/arm-eabi-'\nexport ARCH='arm'\n# Resize the Java Heap size\nexport _JAVA_OPTIONS="-Xmx5072m"\n# Resize the Jack Heap size\nexport ANDROID_JACK_VM_ARGS="-Xmx5072m -Dfile.encoding=UTF-8 -XX:+TieredCompilation"" >> ~/.bashrc
if [ $? -ne 0 ]
then
 echo 'Something went wrong, please check the errror(s) shown above.'
 exit 1
fi
exit 0
