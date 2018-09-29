#!/usr/bin/env bash
########################################
#  Simple string converter
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

# Functions
function replaces()
{
 M=$(printf "$1" | wc -m)
 C=0
 O=''
 while [ $C -lt $M ]
 do
  C=$(( $C + 1 ))
  O="$O""$2"
 done
 echo $O
}

# Main
if [ "$2" != 'A' ] && [ "$2" != 'K' ] && [ "$2" != 'a' ] && [ "$2" != 'k' ]
then
 printf 'Usage:\n\n\tbash aconverter.sh "string" a|k\n\n'
 exit 1
fi

if [ "$2" == 'a' ] || [ "$2" == 'A' ]
then
 replaces "$1", 'A'
else
 replaces "$1", 'K'
fi
exit 0
