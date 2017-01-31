#Freenet stats

This bash script is able to parse your Freenet node's statistics page and show you your input and output rates. Optionally, you can see an scrolling list of your node's downloads list. After stopping the script by keystroke, it'll safely cleanup the temp file from your hard drive.

Required packages:

wget bash

Usage: 

freenetstats.sh ip:port [repeats/active] [interval]

repeats: type an amount to repeat the script.

   freenetstats.sh 127.0.0.1:8888 5 - repeats five times
active: keep updating every one second or add interval.

   freenetstats.sh active - update every one second.
   freenetstats.sh active 5 - update every five seconds.
