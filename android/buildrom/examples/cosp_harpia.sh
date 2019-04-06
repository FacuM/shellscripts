#!/usr/bin/env sh
########################################
#  COSP Pie configuration for buildrom.sh (harpia)
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
WORKING_DIR="$HOME"'/cosp'
ROM_NAME='COSP'
ROM_VERSION='Pie'
ROM_LUNCH='cosp' # Used in "lunch cosp_device-userdebug" and "brunch cosp_device-userdebug"
ROM_MANIFEST_URL='https://github.com/cosp-project/manifest'
ROM_MANIFEST_BRANCH='pie'
BUILD_DATE=$(date '+%Y-%m-%d_%H-%M-%S')
# Signed build?
SIGN=1
SIGNBUILD_URL='https://raw.githubusercontent.com/FacuM/shellscripts/master/android/signbuild/signbuild.sh'
BREAKFAST_DEVICE='harpia'
DEVICE_MANIFEST_URL='https://gist.githubusercontent.com/FacuM/f67473a5fb5da0bd62d77e8d7ce4a70d/raw/216e075e8bbf1c2bc4b493439aab7823dfeb8e4b/cosp_harpia.xml'
REPO_INIT_OPTS='--depth=1 --no-clone-bundle'
REPO_SYNC_OPTS='--force-sync --force-broken --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune'
# REPO_SYNC_THREADS can be 'auto' or integer
REPO_SYNC_THREADS=32
ON_SUCCESS='. '"$HOME"'/otagen.sh'
# => Logging
LOG_FILENAME="$ROM_NAME"'_'"$ROM_VERSION"'_'"$BUILD_DATE"'.txt'
LOG_PATH="$WORKING_DIR"'/..'
LOG_DIR=$LOG_PATH
# USERNAME can be 'auto' to match $USER or string.
#
# This section replaces the real username with the one on $USERNAME
# so that you can publicly share your logs.
USERNAME='HIDDEN'

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
