shellscripts
------------

Some shell scripts made in my boring moments.

# What's all this?

This is a bunch of the scripts I tend to code which are meant to simplify the work involved in ROM compilation, system cleanup, using Freenet, my smartphone, git, coding jokes, signing software, making Bash easier, etc.


android
-------

#### buildrom

Automatically build a ROM from source. Set it up, run it and enjoy!

#### prepenv

Prepare any recently installed Ubuntu distro to build Android-related projects (ROM, recovery, kernel, etc.).

#### signbuild

Quickly build a ROM and sign it with your own private certificates.

	NOTE: buildrom automatically calls signbuild during a compilation if you're making a signed build.


android_scriptmaker
-------------------

A really old script a friend and I wrote, it's meant to iterate through your system partition and build the required updater-script to flash a ROM. It's supposed to i.e.: be able of backing up your whole stock ROM and letting you flash it through recovery.


freenetstats
------------

Another oldie, this script lets you parse the statistics output of your Freenet node and represents the data in your terminal.


git
---

#### qbp

Quickly process a conflictive cherry-pick, skipping empty commits and workarounding some git issues.

#### qbr

Quickly process a set of reverts without needing to match them with any timespan in the repo.

#### qbrb

Quickly handle rebasing, just like `qbp`.


harpia
------

Contains a set of miscelaneous scripts which are meant to be some little experiments that run on the Moto G4 Play.

#### ledctl

This script is intended to workaround the hidden LED issues, handling notifications in a... questionable way. It works.


iptv
----

Parse links from some compatible IPTV websites and make a clean URL list off them.


makehelper
----------

A super outdated and horrible script meant to optimize a kernel build process. Don't use it, it's just there for historic reasons.


parsefnet
---------

Easily parse all keys from a freesite. (Freenet)


reccrypt
--------

Broken TrueCrypt container recovery tool.


sepolicy
--------

Easily patch your device's sepolicies to match any modern implementation or update. It must be paired with `audit2allow`.


shell
-----

#### gotogoback

Adds the ability of going to a path and then return to the previous path with ease. Just ran `goto` and `back`, respectively.

#### uploadtg

Lets you upload a file to Telegram through a bot and Gdrive.


spacectl
--------

Ridiculous super heavy script to control space on... something. Yeah I'm not exactly proud of this one.


tvheadend
---------

Convert a list of IPTV channels into a pipe to ffmpeg, could be improved.


websiteparser
-------------

Not yet implemented script to parse sites into sets of links, based off available user-interactive items.
