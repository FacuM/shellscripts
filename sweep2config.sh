#!/system/xbin/bash
# ====================
# Sweep2Config:
#  easy S2S setup script for SomeFeaK.
# ====================
#  Facundo Montero (facumo.fm@gmail.com)
# ====================
#  Jun 12, 2017
# ====================
#
# Variable definition
NUM=1
# (1, default, from left to right)
# Function definition
function writenum {
if [ $NUM -gt -1 ] && [ $NUM -lt 4 ]
then
 su -c "echo $NUM > /sys/sweep2sleep/sweep2sleep"
 if [ $? -eq 0 ]
 then
  printf "\nSuccessful write for value $NUM to sweep2sleep driver.\n"
  exit 0
 fi
else
 printf "\nFor value $NUM: out of bounds, value must be between 0 and 3.\n"
 exit 1
fi
}
if [  -z "$1" ]
then
 printf '\nPick a number: \n\n1 (default): from left to right.\n2: from right to left.\n3: both (RTL and LTR).\n0: none (disable).\n'
 read NUM
 writenum
else
 printf '\nUsing non-interactive mode...\n'
 NUM=$1
 writenum
fi
