########################################
# This script parses online IPTV players looking for the lists URL. Once done, it'll go through any links it found and save them to a file. (links.txt)
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

# Check wether the first argument is defined, if not, exit returning a generic error code.
if [ -z "$1" ]
then
 printf 'Usage \n\tbash parselinksfromlist.sh URL\n'
 exit 1
fi
# Make sure everything is clean and ready.
rm -f links.txt ; touch links.txt
# Fetch the whole website and download in a variable.
clear
echo "Downloading $1..."
URLS=$(curl -s $1 |
# Look for a URL containing player/.
grep 'player/' |
# Remove HTML tags.
sed 's/<li><a href="//g' |
# Remove HTML tags endings and close.
sed 's/">.*//g' |
# Links cleaning (whitespaces removal).
sed 's/^[ \t]*//g')
echo "Done downloading $1..."
sleep 1
# Go through the links and look for the list.
for URL in $URLS
do
 clear
 echo "====================="
 echo "Current list"
 echo "====================="
 echo "====================="
 LINKS=$(cat links.txt)
 if [ $(printf "$LINKS" | wc -m) -lt 1 ]
 then
  echo 'No matching content.'
 else
  cat links.txt
 fi
 echo "====================="
 printf '\n'
 echo "Processing $URL..."
 # Fetch the websit.
 curl -s $URL |
 # Look for a URL linking a M3U file.
 grep '.m3u</p>' |
 # Remove HTML tags.
 sed 's-</p>.*--g' |
 # Remove all data coming with the link. Then, save.
 sed 's/^.*\(http\)/http/g' >> links.txt
 echo "Done processing $URL."
 printf "\n"
 sleep 1
done
clear
echo "Done processing everything! Saved in $PWD/links.txt"
exit 0
