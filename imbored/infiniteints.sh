#!/usr/bin/env bash
########################################
#  Inifnitely print integers
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################

printf '\n'; C=0
while true
do
 C=$(( $C + 1 ))
 printf '\r'$C
done
