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

# Configuration
api_key='<your bot api key>'
chat_id='<your chat id (group, channel, user, etc.)>'

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
gdrive 2>&1 > /dev/null
testinst $?

# Upload file and post in Telegram
echo "Uploading ""$1""..."
FID=$(gdrive upload $1 | cut -d ' ' -f 2 | head -2 | tail -1)
echo "Sharing ""$1"" (""$FID"")""..."
gdrive share $FID
INFO=$(gdrive info $FID)
OUTPUT='**============**'
DOWNLOAD=$(printf "$INFO" | grep 'DownloadUrl' | cut -d ' ' -f 2)
NAME=$(printf "$INFO" | grep 'Name' | cut -d ' ' -f 2)
OUTPUT="$OUTPUT""
**FILE:** [""$NAME""](""$DOWNLOAD"")"
MD5=$(printf "$INFO" | grep 'Md5sum' | cut -d ' ' -f 2)
OUTPUT="$OUTPUT"'
**MD5:** `'"$MD5"'`'
SHA256=$(sha256sum $1 | cut -d ' ' -f 1)
OUTPUT="$OUTPUT"'
**SHA256:** `'"$SHA256"'`'
OUTPUT="$OUTPUT""
**NOTE:** ""$2"""
OUTPUT="$OUTPUT"'
**============**'
curl "https://api.telegram.org/bot""$api_key""/sendMessage" -d "{ \"chat_id\":\"$chat_id\", \"text\":\"$OUTPUT\", \"parse_mode\":\"markdown\"}" -H "Content-Type: application/json"
STATUS=$?
echo 'NAME: '$NAME
echo 'MD5: '$MD5
echo 'SHA256SUM: '$SHA256
echo 'DOWNLOAD: '$DOWNLOAD
printf 'STATUS: '
if [ $STATUS -eq 0 ]
then
 printf 'Posted.'
else
 printf 'Error.'
fi
printf '\n'
if [ -f $1 ]
then
 echo 'FILE: '"$1"'.md5sum'
 curl "https://api.telegram.org/bot""$api_key""/sendDocument" -F chat_id="$chat_id" -F document=@"$1"".md5sum" -H 'Content-Type: multipart/form-data'
fi
exit 0
