#!/usr/bin/env bash
########################################
#  Quickly patch sepolicies using audit2allow
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

if [ -z $1 ]
then
 printf "\nInvalid input.\n\nUsage: bash $0 path/to/audit2allowoutput\n"
 exit 1
else
 if [ ! -f "$1" ]
 then
  echo "While reading \"$1\": file not found."
  exit 1
 fi
fi
unset OUT
echo "- Patching sepolicies from \"$1\"..."
while read -r line
do
 printf "$line" | grep '#=============' 2>&1 > /dev/null
 if [ $? == 0 ]
 then
  OUT=$(printf "$line" | sed 's/#============= //' | sed 's/ ==============//')
  echo "> Patching file '"$OUT".te'..."
 else
  if [ ! -z $OUT ]
  then
   echo "$line"
   echo "$line" >> "sepolicy/$OUT"".te"
  fi
 fi
done < $1
echo "- Patch completed."
