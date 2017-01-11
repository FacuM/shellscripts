#!/bin/bash
function showhelp {
 printf "%s" "Usage: bash $0 filename password"
 printf "\n"
 printf "%s" "-----------------"
 printf "\n"
 printf "%s" "This script helps you recover corrupted TrueCrypt containers."
 printf "\n"
 printf "\n"
}
if [ -z $1 ]
then
 showhelp
else
 if [ -z $2 ]
 then
  showhelp
 else
  if [ -f $1 ]
  then
   truecrypt -d
   truecrypt --non-interactive -t --filesystem=none "$1" --password="$2"
   sudo testdisk /tmp/.truecrypt_aux_mnt1/volume
   truecrypt -d
  else
   echo "$1: No such file or directory."
  fi
 fi
fi
