#!/bin/bash
####################################################################
## ===> Script author: Facundo Montero (facumo.fm@gmail.com) <=== ##
####################################################################
COLUMNS=`tput cols`
COLSFOREND=$(($COLUMNS - 15))
LINES=`tput lines`
LINESLIST=$(($LINES - 17))
URISCRIPT="$1/stats/"
URIDLLIST="$1/downloads/listKeys.txt"
STATCOUNT=0
trap ctrl_c INT
function ctrl_c() {
 echo "Performing safe cleanup for 'downloadstemp'..."
 DLSIZE=`du -b "downloadstemp" | cut -f1`
 dd if=/dev/zero of=./downloadstemp bs=1 count=$DLSIZE status=none
 STATCOUNT=$(($STATCOUNT + $?))
 rm downloadstemp
 STATCOUNT=$(($STATCOUNT + $?))
 if [ $STATCOUNT -eq 0 ]
 then
  clear
  nicedraw
  echo "Cleanup completed!"
  nicedraw
  exit 0
 else
  clear
  nicedraw
  echo "Something went wrong (permissions problem?). You should try deleting the file 'downloadstemp' by yourself, for safety reasons."
  nicedraw
  exit 1
 fi
}
function nicedraw {
 COLUMNS=`tput cols`
 CHARAM=0
 while [ $CHARAM -lt $COLUMNS ]
 do
  printf "="
  CHARAM=$(($CHARAM + 1))
 done
 CHARAM=0
}
function printbottom {
 LINES=`tput lines`
 CHARAM=0
 while [ $CHARAM -lt $LINES ]
 do
  printf "\n"
  CHARAM=$(($CHARAM + 1))
 done
 CHARAM=0
}
function updatestats {
 printf "\n\nInput rate: \n\n"
 wget -qO - $URISCRIPT | grep "Input Rate" | sed 's/&nbsp;/ /g' | sed 's/.*Rate: //' | sed 's/s).*/s)/'
 printf "\n"
 nicedraw
 printf "\n\nOutput rate: \n\n"
 wget -qO - $URISCRIPT | grep "Output Rate" | sed 's/&nbsp;/ /g' | sed 's/.*Rate: //' | sed 's/s).*/s)/'
 printf "\n"
 nicedraw
}
function getprints {
 PRINTS=`cat $0 | grep "\n" | wc -l`
}
function processdllist {
 wget -qO - $URIDLLIST | sed 's-.*/--g' | sed 's/%20/ /g' > downloadstemp
 CURLINE=`cat downloadstemp | wc -l`
 CURLINES=$CURLINE
}
function script {
 clear
 nicedraw
 updatestats
}
function scriptactive {
 DSTOREINF=`wget -qO - $URISCRIPT | grep Datastore | sed 's/.*running//' | sed 's/in progress: //' | sed 's/. Fre.*//' | sed 's/Datastore//' | sed 's/\t//g' | sed ':a;N;$!ba;s/\n//g'`
 if [ -z  "$DSTOREINF" ]
 then
  :
 else
  nicedraw
  printf "\nDatastore maintenance running: $DSTOREINF\n"
  nicedraw
 fi
 CURLINE=$(($CURLINE - 1))
 LINES=`tput lines`
 LINESLIST=$(($LINES - 17))
 cat downloadstemp | head -$CURLINE | tail -$LINESLIST
 if [ $CURLINE = 0 ]
 then
  CURLINE=$CURLINES
 fi
}
getprints
LINES=$(($LINES - $PRINTS))
if [ -z $1 ]
then
 printf "Usage: \n\n$0 ip:port [repeats/active] [interval]\n\nrepeats: type an amount to repeat the script.\n   $0 127.0.0.1:8888 5 - repeats five times\nactive: keep updating every one second or add interval.\n   $0 active - update every one second.\n   $0 active 5 - update every five seconds.\n"
else
 if [ -z $2 ]
 then
  script
  printbottom;nicedraw
 else
  if [ "$2" != "active" ]
  then
   COUNTSCRIPTFNET=$2
   while [ $COUNTSCRIPTFNET -gt 0 ]
   do
    COUNTSCRIPTFNET=$(($COUNTSCRIPTFNET - 1))
    script
    printbottom;nicedraw
    sleep 1
   done
  else
   processdllist
   while true
   do
    script
    printf "\n"
    printf "\n"
    scriptactive
    COLUMNS=`tput cols`
    COLSFOREND=$(($COLUMNS - 15))
    CURCOLS=0
    while [ $CURCOLS -lt $COLSFOREND ]
    do
     printf " "
     CURCOLS=$(($CURCOLS + 1))
    done
    CURLINEPRINT=$(($CURLINES - $CURLINE))
    printf "($CURLINEPRINT / $CURLINES)"
    printf "\n"
    nicedraw
    if [ -z $3 ]
    then
     sleep 1
    else
     sleep $3
    fi
   done
  fi
 fi
fi
