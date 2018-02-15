########################################
# This script converts normal HTTP m3u IPTV lists into sentences that'll get through FFMPEG (for TVHeadend).
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
#
#  All credits for the conversion steps belong to FFMPEG codec owners and the users who were discusing
#  this TVHeadend bug at one thread, specifically, this one:
#
#  https://tvheadend.org/boards/5/topics/22969?r=22972#message-22972
#
########################################

# Check wether first argument is defined, if not, exit returning a generic error and an usage explanation.
if [ -z "$1" ]
then
 printf 'Usage\n\tbash converttoffmpeg.sh URLtolist\n'
 exit 1
fi
# Fetch the list.
wget "$1" -qO templist
# Read the list.
cat templist |
# Temporarily break logos so we don't get them passed through the script
sed 's."http:."tempmod:.g' |
# Pass beginning of new sentence.
sed 's.http://.pipe:///usr/bin/ffmpeg -loglevel fatal -i http://.g' |
# Pass ending of the new sentence.
sed 's.m3u8.m3u8 -vcodec copy -acodec copy -metadata service_provider=STRING -metadata service_name=STRING -f mpegts -tune zerolatency pipe:1.g' |
# Get back logos, then, save.
sed 's."tempmod:."http:.g' > list.m3u
# Finally, remove the temporary file.
rm templist
# See you! ;)
exit 0
