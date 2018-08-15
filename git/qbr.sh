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
      revstr="\e[93m\e[5mReverting commit $c\e[0m"
      i=0
      printf "$revstr"
      git revert --no-edit $c
      if [ $? -eq 0 ]
      then
        printf "\r"
        while [ $i -lt $(printf "$revstr" | wc -m) ]
        do
          printf " "
          i=$(( $i + 1))
        done
        printf "\r\e[92mSuccess reverting, please wait...\e[0m\n"
        i=$((i + 1))
      else
          printf "\e[91mUnable to continue, please type \"git status\" to see what happened or, if the problem is an already applied commit, just remove it from the list.\n"
          printf "$i commits reverted.\e[0m\n"
          exit 1
      fi
    done
  else
    printf "\e[91mThe specified file ($1) doesn't exist.\e[0m\n"
    exit 1
  fi
fi
printf "\e[92m\e[1mOperation completed.\e[0m\n"
printf "\e[2m$i commits reverted.\e[0m\n"
exit 0
