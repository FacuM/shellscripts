#!/usr/bin/env sh
########################################
#  GZOSP 9.0 configuration for buildrom.sh (harpia)
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################
#
# Depends on: buildrom.sh
#
########################################

# Set the globals
WORKING_DIR="$HOME"'/gzosp'
ROM_NAME='GZOSP'
ROM_VERSION='9.0'
ROM_LUNCH='gzosp' # Used in "lunch gzosp_device-userdebug" and "brunch gzosp_device-userdebug"
ROM_MANIFEST_URL='https://github.com/GZOSP/manifest.git'
ROM_MANIFEST_BRANCH='9.0'
BUILD_DATE=$(date '+%Y-%m-%d_%H-%M-%S')
# Signed build?
SIGN=1
SIGNBUILD_URL='https://raw.githubusercontent.com/FacuM/shellscripts/master/android/signbuild/signbuild.sh'
BREAKFAST_DEVICE='harpia'
DEVICE_MANIFEST_URL='https://gist.githubusercontent.com/FacuM/c6438354de3ac95eab87c54fc3a80cb2/raw/a7df8c144a7d11a1cb4229b812f35f4c89586a0b/gzosp_harpia.xml'
REPO_INIT_OPTS='--depth=1 --no-clone-bundle'
REPO_SYNC_OPTS='--force-sync --force-broken --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune'
# REPO_SYNC_THREADS can be 'auto' or integer
REPO_SYNC_THREADS=32
# => Logging
LOG_FILENAME="$ROM_NAME"'_'"$ROM_VERSION"'_'"$BUILD_DATE"'.txt'
LOG_PATH="$WORKING_DIR"'/..'
LOG_DIR=$LOG_PATH
# USERNAME can be 'auto' to match $USER or string.
#
# This section replaces the real username with the one on $USERNAME
# so that you can publicly share your logs.
USERNAME='auto'

# =======> Don't edit anything after this line.
LAUNCH_NOW='yes'
if [ -f "$HOME"'/buildrom.sh' ]
then
 . "$HOME"'/buildrom.sh'
else
 echo "$HOME"'/buildrom.sh not found, downloading...'
 wget -q 'https://raw.githubusercontent.com/FacuM/shellscripts/master/android/buildrom/buildrom.sh' -O "$HOME"'/buildrom.sh'
 if [ -f "$HOME"'/buildrom.sh' ]
 then
  . "$HOME"'/buildrom.sh'
 else
  echo 'Unable to download buildrom.sh, please try again.'
 fi
fi
