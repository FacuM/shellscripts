#!/usr/bin/env bash
########################################
#  Quickly patch sepolicies using audit2allow
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

# TODO: Rework this, this should be read from the ROM source or
#       other known working private types.
PRIVATE_TYPES=('adbtcp_prop' 'storaged' 'hal_allocator' 'sysinit' 'ctl_mdnd_prop' 'statsd' 'recovery_prop' 'lineage_recovery_prop' 'untrusted_app_tmpfs' 'untrusted_app_27_tmpfs' 'magisk_file' 'blank_screen' 'snap_app' 'userinit_prop')

if [ -z $1 ]
then
 printf '\nInvalid input.\n\nUsage: bash '"$0"' path/to/log [path/to/log] [path/to/log]...\n'
 exit 1
else
 for log in "$@"
 do
  if [ -f "$log" ]
  then
   echo "- Processed \"$log\"."
   DENIALS=$(grep 'avc:' "$log" | wc -l)
   if [ $DENIALS -eq 0 ]
   then
    echo 'No denials found.'
    exit 1
   else
    echo '- '"$DENIALS"' denials found.'
    if [ ! -d 'sepolicy' ]
    then
     printf '\nNot a device tree or missing the "sepolicy" directory. If this is the expected behavior please type the following commands and try again: \n\nmkdir sepolicy\nmkdir sepolicy_private\n'
     exit 1
    fi
   fi
  else
   echo "While processing \"$log\": file not found."
   exit 1
  fi
 done
fi
unset OUT

# Look for a hidden settings file, if present, import it.
if [ -f "$HOME"'/.patchsepolicy_config.sh' ]
then
 . "$HOME"'/.patchsepolicy_config.sh'
 echo '> Loaded extra settings from '"$HOME"'/.patchsepolicy_config.sh'
 IGNORED=''
 for rule in ${IGNORED_RULES[@]}
 do
  if [ "$rule" == 'private' ]
  then
   echo '  - Ignoring private rules.'
   IGNORED="$IGNORED"'pr'
  else
   if [ "$rule" == 'public' ]
   then
    IGNORED="$IGNORED"'pu'
    echo '  - Ignoring public rules.'
   fi
  fi
 done
 if [ "$IGNORED" == 'prpu' ] || [ "$IGNORED" == 'pupr' ]
 then
  echo '  - Ignoring both private and public rules, running a simulation.'
 fi
fi

# Start patching.
INFO="- Patching sepolicies from "
COUNT=0
for log in "$@"
do
 if [ $COUNT -eq 0 ]
 then
  INFO="$INFO"'"'"$log"'"'
 else
  if [ $COUNT -lt $(( $# - 1 )) ]
  then
   INFO="$INFO"', "'"$log"'"'
  else
   INFO="$INFO"' and "'"$log"'"'
  fi
 fi
 COUNT=$(( $COUNT + 1 ))
done
echo "$INFO"'...'
audit2allow --help > /dev/null 2> /dev/null
if [ $? -eq 127 ]
then
 printf '\naudit2allow is missing.\n\n\nBuild the ROM and add it to the path as follows: \n\n. build/envsetup.sh\nbreakfast device_codename\n'
 exit 1
else
 echo '- Parsing logs (filtering denials)...'
 for log in "$@"
 do
    grep avc "$log" >> tmp
 done
 echo '- Parse completed.'
 echo '- Generating rules...'
 audit2allow < tmp > sepolicyfix
 echo '- Generation completed.'
 rm -f tmp
fi
while read -r line
do
 if printf "$line" | grep '#=============' 2> /dev/null > /dev/null
 then
  OUT=$(printf "$line" | sed 's/#============= //' | sed 's/ ==============//')
  printf "\n> Patching file '"$OUT".te'..."
 else
  if [ ! -z $OUT ]
  then
   if [ $(printf "$line" | wc -w) -gt 1 ]
   then
    for private_type in "${PRIVATE_TYPES[@]}"
    do
     if printf "$line" | grep "$private_type" 2> /dev/null > /dev/null
     then
      TYPE='PRIVATE'
      break
     else
      TYPE='PUBLIC'
     fi
    done
    if [ "$IGNORED" == 'pupr' ] || [ "$IGNORED" == 'prpu' ]
    then
     printf '\n'"$TYPE"': '"$line"' - Skipped, running a simulation.'
    else
     if [[ ("$IGNORED" == 'pu' && "$TYPE" == 'PUBLIC') || ("$IGNORED" == 'pr' && "$TYPE" == 'PRIVATE') ]]
     then
      printf '\n'"$TYPE"': '"$line"' - Skipped as per user settings.'
     else
      if [ "$TYPE" == 'PRIVATE' ]
      then
       OUTDIR='sepolicy_private'
      else
       OUTDIR='sepolicy'
      fi
      printf '\n'"$TYPE"': '"$line"
      if [ -f "$OUTDIR"'/'"$OUT"'.te' ]
      then
       MATCH=$(grep -n "$line" "$OUTDIR"'/'"$OUT"'.te')
       if [ $? -eq 0 ]
       then
        printf ' - Found matching line, skipped.'
       else
        printf ' - Added.'
        echo "$line" >> "$OUTDIR"'/'"$OUT"'.te'
       fi
      else
        printf ' - Added.'
        echo "$line" >> "$OUTDIR"'/'"$OUT"'.te'
      fi
     fi
    fi
   fi
  fi
 fi
done < sepolicyfix
printf '\n- Cleaning up...\n'
rm -f sepolicyfix
echo '- Cleanup completed.'
echo '- Patch completed.'
