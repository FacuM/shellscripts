#!/usr/bin/env bash
########################################
#  Quickly patch sepolicies using audit2allow
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

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
