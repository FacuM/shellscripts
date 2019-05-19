#!/usr/bin/env bash
########################################
#  Simple Telegram channel posting script
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################
#
# Depends on: no dependencies.
#
########################################

# Configuration
if [ ! -f ~/.uploadtg_config.sh ]
then
 echo 'No config file found at '"$HOME"'/.uploadtg_config.sh.'
 echo "# Configuration
server='pixeldrain'
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
   echo 'One or more variables are still using their default values. Edit the config file and try again.'
   exit 1
  fi
 fi
fi

# Emojis
SEPARATOR=$'\xE2\x9E\x96'            # (minus symbol)
SERVER_EMOJI=$'\xF0\x9F\x92\xBE'     # (floppy disk)
FILE_EMOJI=$'\xF0\x9F\x93\x84'       # (page up)
MAINTAINER_EMOJI=$'\xF0\x9F\x91\xB7' # (constructor)
MD5_EMOJI=$'\xF0\x9F\x92\xBF'        # (cd)
SHA256_EMOJI=$'\xF0\x9F\x93\x80'     # (dvd)
NOTE_EMOJI=$'\xF0\x9F\x93\x9C'       # (scroll)
TESTERS_EMOJI=$'\xF0\x9F\x94\x8D'    # (magnifying glass left)
LOG_EMOJI=$'\xF0\x9F\x93\x9F'        # (pager)

# Function definition

# testinst: reports an error if a required dependency can't be found.
function testinst()
{
 if [ $1 -eq 127 ]
 then
  echo "Some dependencies haven't been met, please check the errors above."
  exit 1
 fi
}


# drawSeparator: draws a separator of # length off minus emojis
function drawSeparator
{
 COUNT=0; OUT=''
 while [ $COUNT -lt $1 ]
 do
  OUT="$OUT""$SEPARATOR"
  COUNT=$(( $COUNT + 1 ))
 done
 echo "$OUT"
}


# wait_for_api: prevent exceding rate limit of the API if defined (in seconds).
function wait_for_api()
{
 if [ ! -z $call_interval ]
 then
  printf '\n'
  cur=$call_interval
  while [ $cur -gt -1 ]
  do
   printf '\rWaiting '"$cur"' seconds for the next API call.'
   cur=$(( $cur - 1 ))
   sleep 1
  done
  printf '\n'
 fi
}

function check_upload()
{
 if [ $? -ne 0 ]
 then
  echo "There's been a problem uploading your release. Please try again and/or check for API updates."
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

# Input controls

# Note
if [ "$2" != '' ]
then
 NOTE="$2"
else
 NOTE='No release notes have been provided.'
fi

# Maintainer
if [ "$3" != '' ]
then
 MAINTAINER="$3"
 if [ "$4" != '' ]
 then
  MAINTAINER="$MAINTAINER"' ('"$4"')'
 fi
else
 git > /dev/null 2> /dev/null
 if [ $? -ne 127 ]
 then
  GIT_USERNAME=$(git config user.name)
  GIT_EMAIL=$(git config user.email)
  MAINTAINER="$GIT_USERNAME"' ('"$GIT_EMAIL"')'
 else
  if [ "$NO_AUTHOR_CHECK" == 'true' ]
  then
   echo "NOTICE: Assuming you're an anonymous maintainer as you didn't provide any authorship details."
   MAINTAINER='Anonymous'
  else
   echo "You didn't specify an author name and/or email address, try setting either 'Anonymous', a proper author name/email combo or installing and configuring Git.

If you ever forget this again or simply don't want to set it up, I'll assume that you're an Anonymous maintainer."
   echo "NO_AUTHOR_CHECK='true'" >> ~/.uploadtg_config.sh
   exit 1
  fi
 fi
fi

# Testers
if [ "$5" != '' ]
then
 TESTERS="

$TESTERS_EMOJI"' ''The maintainer is calling to '"$5"' to test this release!'
fi

# Set log if path given
if [ -z $LOG_PATH ] && [ "$6" != '' ]
then
 LOG_PATH="$6"
fi

# Upload file and post in Telegram
echo 'Uploading '"$1"'...'
case $server in
	'pixeldrain')
		SERVER='PixelDrain'
		DOWNLOAD='https://pixeldrain.com/api/file/'$(curl -s -F 'file=@'"$1" "https://pixeldrain.com/api/file" | cut -d '"' -f 4)'?download'
		check_upload
		;;
	'gdrive')
		SERVER='Google Drive'
		FID=$(gdrive upload "$1" | tail -1 | cut -d ' ' -f 2)
		check_upload
		echo 'Sharing file ('"$FID"')...'
		gdrive share "$FID"
		DOWNLOAD=$(gdrive info "$FID" | grep 'DownloadUrl' | cut -d ' ' -f 2)
		;;
	'transfersh')
		SERVER='transfer.sh'
		DOWNLOAD=$(curl --upload-file "$1" https://transfer.sh)
		check_upload
		;;
	*)
		if [ "$server" == '' ]
		then
		 printf 'No server specified'
		else
		 printf 'Invalid server specified'
		fi
		printf ', the valid options are "pixeldrain", "gdrive" or "transfersh". Aborting...\n'
		exit 1
		;;
esac
OUTPUT="$(drawSeparator '9')""
$SERVER_EMOJI"' **SERVER:** '"$SERVER"
COUNT=$(printf "$1" | awk -F \/ '{print NF}')
NAME=$(printf "$1" | cut -d \/ -f $COUNT)
OUTPUT="$OUTPUT""
$FILE_EMOJI"' '"**FILE:** [""$NAME""](""$DOWNLOAD"")"
OUTPUT="$OUTPUT""
$MAINTAINER_EMOJI"' ''**MAINTAINER: '"$MAINTAINER"
MD5=$(cat "$1"'.md5sum' | cut -d ' ' -f 1)
OUTPUT="$OUTPUT""
$MD5_EMOJI"' ''**MD5:** `'"$MD5"'`'
SHA256=$(sha256sum $1 | cut -d ' ' -f 1)
OUTPUT="$OUTPUT""
$SHA256_EMOJI"' ''**SHA256:** `'"$SHA256"'`'
OUTPUT="$OUTPUT""
$NOTE_EMOJI"' ''**NOTE:** '"
$NOTE"""
OUTPUT="$OUTPUT""$TESTERS"
if [ ! -z $LOG_PATH ]
then
 OUTPUT="$OUTPUT""

$LOG_EMOJI"' ''The maintainer attached a build log to this release.'
fi
OUTPUT="$OUTPUT""
$(drawSeparator '9')"
curl "https://api.telegram.org/bot""$api_key""/sendMessage" -d "{ \"chat_id\":\"$chat_id\", \"text\":\"$OUTPUT\", \"parse_mode\":\"markdown\"}" -H "Content-Type: application/json" -s > /dev/null
STATUS=$?
echo 'FILE: '$NAME' ''('"$DOWNLOAD"')'
echo 'MAINTAINER: '$MAINTAINER
echo 'MD5: '$MD5
echo 'SHA256SUM: '$SHA256
if [ "$TESTERS" != '' ]
then
 echo 'TESTERS: '$5
fi
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
 echo 'CHECKSUM: '"$1"'.md5sum'
 curl "https://api.telegram.org/bot""$api_key""/sendDocument" -F chat_id="$chat_id" -F document=@"$1"".md5sum" -H 'Content-Type: multipart/form-data' -s > /dev/null
fi
if [ ! -z $LOG_PATH ]
then
 echo 'LOG: '"$LOG_PATH"
 curl "https://api.telegram.org/bot""$api_key""/sendDocument" -F chat_id="$chat_id" -F document=@"$LOG_PATH" -H 'Content-Type: multipart/form-data' -s > /dev/null
fi
exit 0
