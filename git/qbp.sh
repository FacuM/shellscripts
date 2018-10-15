#!/bin/bash
########################################
#   Quick batch pick handler
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

# Skip a line at every run.
printf "\n"
# Look for working path
    while true
    do
      printf '\e[93m\e[5mContinuing cherry-pick\e[0m'
      PICK=$(git cherry-pick --continue 2>&1)
      printf '\r\e[93mContinuing cherry-pick\e[0m'
      printf "\n$PICK\n"
      printf "$PICK" | grep 'no cherry-pick' 2>&1 > /dev/null
      if [ $? -eq 0 ]
      then
          printf '\r\e[92mCherry pick completed, exitting.\e[0m\n'
          exit 0
      else
          printf "$PICK" | grep 'error' 2>&1 > /dev/null
          if [ $? -eq 1 ]
          then
            printf "$PICK" | grep 'reset' 2>&1 > /dev/null
            if [ $? -eq 0 ]
            then
                printf '\e[0m\nThe commit was already applied, resetting git.\n'
                git reset
            else
                printf '\r\e[92mSuccess picking, please wait...\e[0m\n'
            fi
          else
            printf '\n\e[91mUnable to continue, please type "git status" to see what happened.\nSome changes have been made.\e[0m\n'
            exit 1
          fi
      fi
    done
exit 0
