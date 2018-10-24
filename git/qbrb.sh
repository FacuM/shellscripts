#!/bin/bash
########################################
#   Quick batch rebase handler
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
      printf '\e[93m\e[5mContinuing rebase\e[0m'
      REBASE=$(git rebase --continue 2>&1)
      printf '\r\e[93mContinuing rebase\e[0m\n'
      echo "$REBASE"
      STATUS=$(git status 2>&1)
      printf "\n$STATUS\n"
      printf "$REBASE" | grep 'No rebase in' 2>&1 > /dev/null
      if [ $? -eq 0 ]
      then
          printf '\r\e[92mRebase completed, exitting.\e[0m\n'
          exit 0
      else
          echo "$STATUS" | grep 'fix conflicts' 2>&1 > /dev/null
          if [ $? -eq 1 ]
          then
            printf "$STATUS" | grep 'fixed' 2>&1 > /dev/null
            if [ $? -eq 0 ]
            then
                printf '\e[0m\nThe commit was already applied, continuing rebase.\n'
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
