#!/bin/bash
#
# ------------------------------------------------------------------
# [Facundo Montero (facumo.fm@gmail.com) ]
# ------------------------------------------------------------------
#
# This script helps you process a website's links one by one
# Thanks to Michael Homer at StackExchange ( http://unix.stackexchange.com/questions/146942/how-can-i-test-if-a-variable-is-empty-or-contains-only-spaces ) for the main variable testing conditional.
# NOTE: At least now, it crawls just the first level of the website.
# ------------------------------------------------------------------
#
# Initialize variables
CURURL=0
#
#
# Clean the environment
rm -f web*
rm -f parse*
#
#
clear
echo "---------------------------"
echo "Website processor and links parser"
echo "---------------------------"
echo "Before continuiung, if the site has any blocks, don't forget to take a cookies.txt file and paste it in the root of this folder."
echo "Unsure about how to do it? Try this Chrome Extension: "
echo "https://chrome.google.com/extensions/detail/lopabhfecdfhgogdbojmaicoicjekelh"
echo "---------------------------"
firstusetest=(`ls | grep website`)
if [[ -z "${firstusetest// }" ]]
then
  echo "Type the website's URL and then press Enter."
  read WEBSITE
  echo $WEBSITE > website
  echo "Type the matching URL pattern and press Enter."
  read PATTERN
  echo $PATTERN > pattern
  echo "Load external cookies? [ Yy / Nn ]"
  read LOADCS
  echo $LOADCS > loadcs
  while [ $LOADCS != "Y"  -a  $LOADCS != "y" -a $LOADCS != "N" -a $LOADCS != "n" ]
  do
   echo "Load external cookies? [ Yy / Nn ]"
   read LOADCS
  done
else
  while [ -z $loadsettings ]
  do
   echo "Do you want to load the saved settings? [ Yy / Nn ]"
   read loadsettings
   if [ $loadsettings == "Y" -o $loadsettings == "y" ]
   then
    WEBSITE=(`cat website`)
    PATTERN=(`cat pattern`)
    LOADCS=(`cat loadcs`)
   else
    if [ $loadsettings != "Y" -a $loadsettings != "y" -a $loadsettings != "N" -a $loadsettings != "n" ]
    then
     unset loadsettings
    else
     echo "Type the website's URL and then press Enter."
     read WEBSITE
     echo $WEBSITE > website
     echo "Type the matching URL pattern and press Enter."
     read PATTERN
     echo $PATTERN > pattern
     echo "Load external cookies? [ Yy / Nn ]"
     read LOADCS
     echo $LOADCS > loadcs
     while [ $LOADCS != "Y"  -a  $LOADCS != "y" -a $LOADCS != "N" -a $LOADCS != "n" ]
     do
      echo "Load external cookies? [ Yy / Nn ]"
      read LOADCS
     done
    fi
   fi
  done
fi
echo "Downloading website..."
if [ $LOADCS == "Y" -o $LOADCS == "y" ]
then
 wget --no-check-certificate --load-cookies cookies.txt -qO website.html "$WEBSITE"
else
 wget --no-check-certificate -qO website.html "$WEBSITE"
fi
echo "Processing HTML tags and retrieving lines containing links..."
grep -a "<a href='" website.html > parsestep1q.html
grep -a '<a href="' website.html > parsestep1dq.html
echo "Searching for links matching the requested pattern..."
cut -d"'" -f2 parsestep1q.html > parsestep2q.html
cut -d'"' -f2 parsestep1dq.html > parsestep2dq.html
# Blogger workaround
sed -i '/item-title/d' parsestep2q.html
sed -i '/item-title/d' parsestep2dq.html
# Buggy processing workaround
sed -i '/a>/d' parsestep2q.html
sed -i '/a>/d' parsestep2dq.html
# Join files
cat parsestep2q.html > parsestep2.html
cat parsestep2dq.html >> parsestep2.html
# Count parsed lines
PARLINKS=(`wc -l parsestep2.html | sed 's/ parsestep2q.html//'`)
# Process the site
while [ $CURURL -lt $PARLINKS ]
do
 clear
 CURURL=(`expr $CURURL + 1`)
 CURRENTURL=(`cat parsestep2.html | tail -$CURURL | head -1`)
 echo "--------------"
 echo "Processing: ($CURURL / $PARLINKS) - $CURRENTURL"
 echo "--------------"
 if [ $LOADCS == "Y" -o $LOADCS == "y" ]
  then
   wget --no-check-certificate --load-cookies cookies.txt -qO websiteproc.html "$CURRENTURL"
  else
   wget --no-check-certificate -qO websiteproc.html "$CURRENTURL"
 fi
 grep -a "<a href='" websiteproc.html >> parsestep1procq.html
 grep -a '<a href="' websiteproc.html >> parsestep1procdq.html
 cut -d"'" -f2 parsestep1.html > parsestep2procq.html
 cut -d'"' -f2 parsestep1.html > parsestep2procdq.html
 # Blogger workaround
 sed -i '/item-title/d' parsestep2procq.html
 sed -i '/item-title/d' parsestep2procdq.html
 # Buggy processing workaround
 sed -i '/a>/d' parsestep2procq.html
 sed -i '/a>/d' parsestep2procdq.html
 # Join files
 cat parsestep2procq.html > parsestep2proc.html
 cat parsestep2procdq.html >> parsestep2proc.html
 grep -a $PATTERN parsestep2proc.html >> parsestep3proc.html
done
printf "\n"
echo "Do you want to see the output, save the file or both? Type so, sf or both respectively."
read getanswer
if [ "$getanswer" = "so" ]
then
 cat parsestep3proc.html
else
 if [ "$getanswer" = "sf" ]
 then
  mv parsestep3proc.html output.txt
 else
  cat parsestep3proc.html
  echo ----------------
  mv parsestep3proc.html output.txt
  echo "Saved output as 'output.txt'."
 fi
fi
