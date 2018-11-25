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
if [ ! -f ~/.uploadtg_config.sh ]
then
 echo 'No config file found at '"$HOME"'/.uploadtg_config.sh.'
 echo "# Configuration
api_key='<your bot api key>'
chat_id='<your chat id (group, channel, user, etc.)>'" > ~/.uploadtg_config.sh
 if [ $? -eq 0 ]
 then
  echo 'Defaults were written to '"$HOME"'/.uploadtg_config.sh.
You can now run your favorite editor and add your credentials on it.'
 else
  echo 'Unable to write defaults. Do you have write permission on '"$HOME"'?'
 fi
 exit 1
else
 if [ -f ~/.uploadtg_config.sh ]
 then
  . ~/.uploadtg_config.sh
  if [ "$api_key" == '<your bot api key>' ] || [ "$chat_id" == '<your chat id (group, channel, user, etc.)>' ]
  then
   echo 'One or more variables are stil using their default values. Edit the config file and try again.'
   exit 1
  fi
 fi
fi

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

# Check if a file's been provided.
if [ -z $1 ]
then
 echo "You didn't provide any file to upload. Aborting..."
 exit 1
else
 if [ ! -f "$1" ]
 then
  echo "No such file or directory while looking for ""$1"'. Aborting....'
  exit 1
 fi
fi

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
