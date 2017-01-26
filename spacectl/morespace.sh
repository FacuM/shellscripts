#!/bin/bash
# #---------------------------------------------------------#
# #   Bash presence is completely mandatory for this script #
# #---------------------------------------------------------#
# -----------------------------------------
# Facundo Montero ( facumo.fm@gmail.com )
# -----------------------------------------
# This script moves files from a folder until the desired space is free in the main disk or there aren't more files to move from the chosen folder.
# -----------------------------------------
# Thanks to the regex processing of disk space from:
# http://stackoverflow.com/questions/8110530/check-free-disk-space-for-current-partition-in-bash
#
# Do you want to run the script as service? Add this line to your /etc/rc.local
#
# sudo --user=yourusername screen -d -m -U bash /path/to/script/startcuberite.sh
#
#
# USE THE FULL PATH!!! DO NOT BLAME ME FOR DATA LOSS IF YOU USE WORKING DIR-LIKE PATHS!!!
#
#
# Functions definition
#
# "getdata" gets the user input and sends it to their respective files.
function getdata {
echo "Type the origin folder: "
read ORIGIN
echo $ORIGIN > origin
echo "Type the destination folder: "
read DESTINATION
echo $DESTINATION > destination
echo "Type the check interval (5 or more, in seconds): "
read INTERVAL
echo $INTERVAL > interval
echo "How many space should be keep freed? (in bytes)"
read MINSPACE
echo $MINSPACE > minspace
clear
echo "All done, if you have to change something, please stop the script and edit the files 'origin' and 'destination' in the script's working dir"
}
# "loadsettings" loads the saved settings.
function loadsettings {
ORIGIN=`cat origin`
DESTINATION=`cat destination`
INTERVAL=`cat interval`
MINSPACE=`cat minspace`
}
# Check if there are saved settings
firstusetest=(`ls -1  | grep destination`)
if [[ -z "${firstusetest// }" ]]
then
 getdata
else
 loadsettings
fi
while true
do
 SPACE=`df -k $ORIGIN | awk '/[0-9]%/{print $(NF-2)}'`
 echo $SPACE > test
 tr -d ' \t\n\r\f' <test >testfix
 SPACE=`cat testfix`
 SPACE=$(($SPACE * 1024))
 DATETIME=`date`
 if [ $SPACE -gt $MINSPACE ]
 then
  echo "$DATETIME: No cleanup needed. SPC: $SPACE" >> logfile
 else
  while [ $SPACE -lt $MINSPACE ]
  do
   SPACE=`df -k $ORIGIN | awk '/[0-9]%/{print $(NF-2)}'`
   echo $SPACE > test
   tr -d ' \t\n\r\f' <test >testfix
   SPACE=`cat testfix`
   SPACE=$(($SPACE * 1024))
   DATETIME=`date`
   CURFILE=`ls -t1 $ORIGIN | tail -1`
   rm "$DESTINATION/$CURFILE"
   cp "$ORIGIN/$CURFILE" "$DESTINATION/"
   TEST1=`stat --printf="%s" "$ORIGIN/$CURFILE"`
   TEST2=`stat --printf="%s" "$DESTINATION/$CURFILE"`
   if [ "$TEST1" = "$TEST2" ]
   then
    echo "$DATETIME: File $CURFILE moved. SPC: $SPACE of $MINSPACE" >> logfile
    rm "$ORIGIN/$CURFILE"
   else
    echo "$DATETIME: Something went wrong while copying the file. Please check the destination disk free space." >> logfile
   fi
  done
 fi
sleep $INTERVAL
done
