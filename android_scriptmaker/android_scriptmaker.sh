#!/bin/sh
####################################################################
## ===> Script author: Facundo Montero (facumo.fm@gmail.com) <=== ##
####################################################################
# Workaround for find listing format.
CURFILE=2
# Reset (if setted) RUNSCRIPT variable.
RUNSCRIPT=0
# Delete existing file (if any) and suppress output (if not existing).
rm -f /sdcard/add-this-updater-script
rm -f /sdcard/tempflist
echo "##############"
echo "Welcome, this script will make a appendeable file for your already installed ROM (used for modding)"
echo "##############"
echo "Please type 'yes' (without quotes) to continue: "
read RUNSCRIPT
if [ $RUNSCRIPT == 'yes' ]
then
 echo "Okay! We're going to do some test, just to make sure your device supports: head, tail, tee, grep, wc and cat."
 echo "##############"
 echo "Testing 'tee'"
 echo "##############"
 echo "test" | head -1
 if [ $? -eq 0 ]
 then
  echo "'head' is working :-)"
 else
  echo "Nope, no 'head'. Please install it and try again."
  exit 1
 fi
 echo "test" | tail -1
 if [ $? -eq 0 ]
 then
  echo "'tail' is working :-)"
 else
  echo "Nope, no 'tail'. Please install it and try again."
  exit 1
 fi
 echo "test" | tee /sdcard/testtee
 if [ $? -eq 0 ]
 then
  echo "'tee' is working :-)"
 else
  echo "Nope, no 'tee'. Please install it and try again."
  rm -f /sdcard/testee
  exit 1
 fi
 echo "test" | grep "test"
 if [ $? -eq 0 ]
 then
  echo "'grep' is working :-)"
 else
  echo "Nope, no 'grep'. Please install it and try again."
  exit 1
 fi
 echo "test" | wc
 if [ $? -eq 0 ]
 then
  echo "'wc' is working :-)"
 else
  echo "Nope, no 'wc'. Please install it and try again."
  exit 1
 fi
 cat /sdcard/testtee
 if [ $? -eq 0 ]
 then
  echo "'cat' is working :-)"
 else
  echo "Nope, no 'cat'. Please install it and try again."
  rm -f /sdcard/testtee
  exit 1
 fi
 echo "test" | sed 's/test//'
 if [ $? -eq 0 ]
 then
  echo "'sed' is working :-)"
 else
  echo "Nope, no 'sed'. Please install it and try again."
  exit 1
 fi
fi
if [ $RUNSCRIPT == 'yes' ]
then
find ./system/ -exec echo {} \; | tee /sdcard/tempflist
FILEAM=`cat /sdcard/tempflist | wc -l`
 while [ $CURFILE -lt $FILEAM ]
 do
  ISFILE=`cat /sdcard/tempflist | head -$CURFILE | tail -1 | grep -q .;printf "$?"`
  if [ $ISFILE -eq 0 ]
  then
   FILERAW=`cat /sdcard/tempflist | head -$CURFILE | tail -1`
   FILE=`cat /sdcard/tempflist | head -$CURFILE | tail -1 | sed 's-\.--g'`
   PERMS=`stat -c '%A %a %n' $FILERAW | cut -d " " -f2`
   printf "set_perm (1000, 1000, 0$PERMS, \"$FILE\");\n" >> /sdcard/add-this-updater-script
  fi
  CURFILE=$(($CURFILE + 1))
 echo $FILEAM
 done
else
 echo "Okie! See you ;)"
 exit 0
fi
