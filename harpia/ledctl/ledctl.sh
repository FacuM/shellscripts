#!/system/xbin/bash
########################################
#   Notifications reader for ATC LED                     
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

# Test whether everything is set up or not.
if [ -e /sdcard/ledsettings.sh ]
then
 # If it is, try to use it
 source /sdcard/ledsettings.sh
 if [ $enabled -eq 1 ]
 then
  # Hello
  if [ $interval -gt 1 ]
  then
   mist='minutes'
  else
   mist='minute'
  fi
  echo "Hey there! Turn off your screen and wait $interval $mist, then, the LED will start blinking."
  # Convert minutes to seconds
  interval=$(($interval * 60))
  # Check for custom trigger
  if [ -z "$trigger" ]
  then
   echo "The custom trigger wasn't set, so I'll fall back to defaults (heartbeat)"
   trigger="heartbeat"
  fi
  # Blink the LED every defined minutes
  PREV='None'
  while true
  do
   sleep $interval
   # Run ONLY if charger is present
   if [ "$(cat /sys/class/power_supply/battery/status)" == 'Charging' ]
   then
    if [ $debug -eq 1 ]
    then
     echo 'CHARGER: Plugged.'
    fi
    # Check if screen is on
    service call power 12 | grep 1 > /dev/null
    if [ $? -ne 0 ] || [ $son -eq 1 ]
    then
     # Get DB entries
     QUERY="SELECT * FROM log"
     if [ $debug -eq 1 ]
     then
      echo "QUERY: $QUERY"
     fi
     # Prepare the command
     CMD="sqlite3 /data/system/notification_log.db '$QUERY'"
     if [ $debug -eq 1 ]
     then
      echo "COMMAND: $CMD"
     fi
    # Get last notification
    LNOF=$(su -c "$CMD | tail -1")
    # Get last notification ID
    LID=$(printf "$LNOF" | cut -d '|' -f 7)
    if [ $debug -eq 1 ]
    then
     echo "LAST NOTIFICATION: $LNOF"
     echo "LAST ID: $LID"
    fi
    if [ "$LNOF" != "$PREV" ] && [ "$LID" != "$PID" ]
    then
       # On
       su -c 'echo heartbeat > /sys/class/leds/charging/trigger'
       if [ $debug -eq 1 ]
       then
        cat /sys/class/leds/charging/trigger
       fi
       sleep  3
       # Off
       su -c 'echo none > /sys/class/leds/charging/trigger'
       if [ $debug -eq 1 ]
       then
        cat /sys/class/leds/charging/trigger
       fi
       # Save previous notification
       PREV=$LNOF
       # Save previous ID to skip execution if equals
       PID=$(printf "$LNOF" | cut -d '|' -f 7)
       if [ $debug -eq 1 ]
       then
        echo "PREVIOUS NOTIFICATION: $PREV"
        echo "PREVIOUS ID: $PID"
       fi
     fi
    fi
    else
     if [ $debug -eq 1 ]
     then
      echo 'CHARGER: Not plugged.'
     fi
   fi
  done
 fi
else
 # If it isn't, just generate the file and exit with a generic error code.
 printf '#!/system/bin/bash\n# Set to 0 to disable, 1 to enable\nenabled=1\n# Set the reading interval: (minutes)\ninterval=10\n# Also with screen on (could cause issues)\nson=0\n# Custom LED trigger \ntrigger=""\n# Toggle debugging\ndebug=0' > /sdcard/ledsettings.sh
 printf '==========\nPLEASE READ\n==========\n\nUnable to startup, please edit /sdcard/ledsettings.sh before continuing or run again for defaults.\n'
 exit 1
fi
exit 0
