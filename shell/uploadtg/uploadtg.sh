#!/usr/bin/env bash
########################################
#  Simple Telegram channel posting script
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################
#
# Depends on: telegram-send, gdrive.
#
########################################

# Function definition

# testinst: reports an error if a required dependency can't be found.
function testinst()
{
 if [ $1 == 127 ]
 then
  echo "Some dependencies haven't been met, please check the errors above."
  exit 1
 fi
}

# Main

# Check dependencies
telegram-send 2>&1 > /dev/null
testinst $?
gdrive 2>&1 > /dev/null
testinst $?

# Upload file and post in Telegram
echo "Uploading ""$1""..."
#FID=$(gdrive upload $1 | cut -d ' ' -f 2 | head -2 | tail -1)
FID='1Q23pSj-U-k-ZyltzzBweC85qh4jY3OPF'
echo "Sharing ""$1"" (""$FID"")""..."
#gdrive share $FID
INFO=$(gdrive info $FID)
telegram-send --format html '<b>============</b>'
DOWNLOAD=$(printf "$INFO" | grep 'DownloadUrl' | cut -d ' ' -f 2)
NAME=$(printf "$INFO" | grep 'Name' | cut -d ' ' -f 2)
telegram-send --format html '<b>FILE:</b> '"<a href=\"$DOWNLOAD\">"$NAME"</a>"
MD5=$(printf "$INFO" | grep 'Md5sum' | cut -d ' ' -f 2)
telegram-send --format html "<b>MD5:</b> <pre>""$MD5""</pre>"
SHA256=$(sha256sum $1 | cut -d ' ' -f 1)
telegram-send --format html "<b>SHA256:</b> <pre>""$SHA256""</pre>"
if [ "$2" != '-u' ]
then
 telegram-send --format html '<b>NOTE:</b> '"$2"
fi
telegram-send --format html '<b>============</b>'
STATUS=$?
echo "NAME: "$NAME
echo "MD5: "$MD5
echo "DOWNLOAD: "$DOWNLOAD
printf "STATUS: "
if [ $STATUS -eq 0 ]
then
 printf "Posted."
else
 printf "Error."
fi
printf "\n"
if [ "$2" == '-u' ] && [ "$2" != '' ]
then
 echo "FILE: "$1
 telegram-send -f $1
fi
exit 0

