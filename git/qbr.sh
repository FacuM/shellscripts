#!/bin/bash
########################################
#   Quick batch commits reverter
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

# Skip a line at every run.
printf "\n"
# Initialize counter
i=0
# Look for working path
if [ -z "$1" ]
then
  printf "Usage: \n\n\nSomewhere, there must be a file containing all the commits hashes that you are willing to revert. Point this script there, as follows: \n\n$0 /path/to/file\n"
  exit 1
else
  if [ -f "$1" ]
  then
    for c in $(cat $1)
    do
      printf "Reverting commit $c\n"
      git revert --no-edit $c
      if [ $? -eq 0 ]
      then
        printf "Success reverting, please wait...\n"
        i=$((i + 1))
      else
          printf "Unable to continue, please type \"git status\" to see what happened or, if the problem is an already applied commit, just remove it from the list.\n"
          printf "$i commits reverted.\n"
          exit 1
      fi
    done
  else
    printf "The specified file ($1) doesn't exist.\n"
    exit 1
  fi
fi
printf "Operation completed.\n"
printf "$i commits reverted.\n"
exit 0
