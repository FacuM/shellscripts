#!/system/xbin/bash
########################################
#                       Notifications reader forn ATC LED                     
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

# Test wether everything is set up or not.
if [ -e /sdcard/ledsettings.sh ]
then
 # If it is, try. to use it
 source /sdcard/ledsettings.sh
 if [ $enabled -eq 1 ]
 then
  # Convert hours to milliseconds
  thold=$(($thold * 3600000))
  #Convert minutes to seconds
  interval=$(($interval * 60))
  # Blink the LED every defined minutes
  PREV='None'
  while true
  do
   sleep 5
   # Check if screen is on
   su -c 'dumpsys power | grep "Display Power" | grep "ON"'
   if [ $? -ne 0 ]
   then
    # Get DB entries (with 1 it's enough)
    QUERY="SELECT * FROM log WHERE posttime_ms < $thold ORDER BY posttime_ms DESC LIMIT 1"
    CMD="sqlite3 /data/system/notification_log.db '$QUERY'"
    LNOF=$(su -c "$CMD")
   if [ "$LNOF" != "$PREV" ]
   then
      # On
      su -c 'echo heartbeat > /sys/class/leds/charging/trigger'
      sleep  3
      # Off
      su -c 'echo none > /sys/class/leds/charging/trigger'
      PREV=$LNOF
    else
    fi
#   fi
  done
 fi
else
 # If it isn't, just generate the file and exit with a generic error code.
 printf '#!/system/bin/bash\n# Set to 0 to disable, 1 to enable\nenabled=1\n# Set this variable to the desired threshold: (hours)\nthold=1\n# Set the reading interval: (minutes)\ninterval=10' > /sdcard/ledsettings.sh
 echo 'Unable to startup, please edit /sdcard/ledsettings.sh before continuing or run again for defaults.'
 exit 1
fi
exit 0
