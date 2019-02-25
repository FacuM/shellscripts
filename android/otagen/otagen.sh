#!/usr/bin/env sh
########################################
#  Android ROM build automatic OTA generator
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################
#
# Depends on: buildrom.
#
########################################

# This script must be run from the source shell, if not, crash.
if [ "${BASH_SOURCE[0]}" == "${0}" ]
then
 echo '
This script must be run from the source shell.

Usage:
       . configname.sh [reset]|[clobber]|[ns] [release notes] [maintainership] [testers]
  source configname.sh [reset]|[clobber]|[ns] [release notes] [maintainership] [testers]

reset - Remove old source (if existing) before building.
clobber - Clean environment before building.
ns - Do not sync, just build.
js - Just sync, do not build.

Do not run the script directly, call your configuration script instead.'
 exit 1
fi

# This script is intented to be run from buildrom, or from a
# bunch of lines setting it up before. Seriously, don't set it
# up by hand, please.

# ============================================
# TODO: Validate all the input and the output.
# ============================================

if [ -z $WORKING_DIR ] || [ -z $BREAKFAST_DEVICE ] || [ -z $LOG_PATH ] || [ -z $TARGETPATH ] || [ -z $ROM_LUNCH ]
then
 echo "Some of the following fields will be empty. The ones that are empty, are the ones to blame for this crash.

WORKING_DIR: ""$WORKING_DIR"'
BREAKFAST_DEVICE: '"$BREAKFAST_DEVICE"'
LOG_PATH: '"$LOG_PATH"'
TARGETPATH: '"$TARGETPATH"'
ROM_LUNCH: '"$ROM_LUNCH"'

ERROR: Cannot proceed, one or more required values are missing.'
else
 echo 'Running OTA generation commands...'
 # Logic from https://github.com/artur9010/pdup
 ROM_URL=$(curl -# -F 'fileName='"$TARGETPATH" -F 'file=@'"$TARGETPATH" 'https://sia.pixeldrain.com/api/file' | cut -d '"' -f 4)
 MD5_URL=$(curl -# -F 'fileName='"$TARGETPATH"'.md5sum' -F 'file=@'"$TARGETPATH"'.md5sum' 'https://sia.pixeldrain.com/api/file' | cut -d '"' -f 4)
 OTA_TARGET_PATH='out/target/product/'"$BREAKFAST_DEVICE"
 . vendor/"$ROM_LUNCH"/tools/changelog.sh
 CHANGELOG_PATH="$OTA_TARGET_PATH"'/Changelog.txt'
 echo 'All done! You are ready to post your OTA updates.

ROM URL: '"$ROM_URL"'
MD5 URL: '"$MD5_URL"'
Changelog path: '"$CHANGELOG_PATH"
fi
