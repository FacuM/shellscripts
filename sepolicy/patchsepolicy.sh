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
PRIVATE_TYPES=('adbtcp_prop' 'storaged' 'hal_allocator' 'sysinit' 'ctl_mdnd_prop' 'statsd' 'recovery_prop' 'lineage_recovery_prop' 'untrusted_app_tmpfs' 'untrusted_app_27_tmpfs' 'magisk_file')

if [ -z $1 ]
then
 printf "\nInvalid input.\n\nUsage: bash $0 path/to/audit2allowoutput\n"
 exit 1
else
 if [ ! -f "$1" ]
 then
  echo "While reading \"$1\": file not found."
  exit 1
 fi
fi
unset OUT
echo "- Patching sepolicies from \"$1\"..."
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
done < $1
printf '\n- Patch completed.\n'
