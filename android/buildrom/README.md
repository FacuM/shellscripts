Simple automatic ROM compilation script
=====================================

Usage
-----

Download the script

	wget -q https://raw.githubusercontent.com/FacuM/shellscripts/master/android/buildrom/buildrom.sh -O ~/buildrom.sh

Edit the variables at the top to your liking

	vi ~/buildrom.sh   or   nano ~/buildrom.sh

![Variables to edit](https://i.imgur.com/6gqS7sn.png)

Then begin the build, syncing source and just building what you need.

	. ~/buildrom.sh

If you want to remove the old source, you can run it like this.

	. ~/buildrom.sh reset

Or you can just clean the old compilation and build it all again.

	. ~/buildrom.sh clobber

Resources
---------

- Understanding bash sourcing: [How to detect if a script is being sourced - Stack Overflow](https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced)
