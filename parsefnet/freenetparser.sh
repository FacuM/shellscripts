# #----------------------------------#
# # bash, curl and sed are mandatory #
# #----------------------------------#
#
# ---------------------------------------
# Facundo Montero ( facumo.fm@gmail.com )
# ---------------------------------------
#
# This script retrieves a freesite saved in your node and parses its keys.
#
rm curllog 2> /dev/null
TEST=`curl --fail --silent --show-error $1 -o /dev/null 2>&1`
if [[ -z $TEST ]]
then
 RUNCMD=1
else
 RUNCMD=0
fi
DATETIME=`date`
if [ $RUNCMD -eq 1 ]
then
 wget $1 -qO - | grep @ | sed 's-<a href="/-\n-g' | sed 's-">.*--g' | sed 's/<.*//g' | sed '/^\s*$/d' | sed 's/^.newbookmark=//g' | sed 's/&amp.*//g' > parsed"$DATETIME".txt
 cat parsed"$DATETIME".txt
printf "\n"
VALWAIT=5
while [[ $VALWAIT -gt -1 ]]
do
 printf "%s" "$VALWAIT seconds remaining..."
 printf "\r"
 sleep 1
 VALWAIT=$(($VALWAIT - 1))
done
printf "\n"
while [ "$save" != "Y" -a "$save" != "N" ]
do
 echo "Do you want to save the output to 'parsed$DATETIME.txt'?"
 read save
 if [ "$save" = "Y" -o "$save" = "y" ]
 then
  save=Y
 else
  save=N
 fi
done
if [ "$save" = "Y" ]
then
 echo "Saved!"
else
 rm parsed"$DATETIME".txt
 echo "See you! ;)"
fi
else
 TESTURL=`echo $1 | sed 's/:.*//g'`
 if [ "$TESTURL" = "http" ]
 then
  echo "There's something wrong with your input, please check: $1"
 else
  echo 'Usage: bash freenetparser.sh "URL"'
  printf '\n'
  echo 'Example: '
  echo 'bash freenetparser.sh "http://127.0.0.1:8888/USK@............."'
 fi
fi
