#!/usr/bin/env sh
########################################
#  Android ROM automatic clone and build script
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################
#
# Depends on: AOSP build dependencies, tee and wget.
#
########################################

# Set the globals
WORKING_DIR="$HOME"'/los16'
ROM_NAME='LineageOS'
ROM_VERSION='16.0'
ROM_LUNCH='lineage' # Used in "lunch lineage_device-userdebug" and "brunch lineage_device-userdebug"
BUILD_DATE=$(date '+%Y-%m-%d_%H-%M-%S')
LOG_FILENAME="$ROM_NAME"'_'"$ROM_VERSION"'_'"$BUILD_DATE"'.txt'
LOG_PATH="$WORKING_DIR"'/../'
MANIFEST_URL='https://raw.githubusercontent.com/Harpia-development/los_harpia/master/harpia.xml'
SIGN=1
SIGNBUILD_URL='https://raw.githubusercontent.com/FacuM/shellscripts/master/android/signbuild/signbuild.sh'
BREAKFAST_DEVICE='harpia'
REPO_INIT_OPTS='--depth=1 --no-clone-bundle'
REPO_SYNC_OPTS='--force-sync --force-broken --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune'
# REPO_SYNC_THREADS can be 'auto' or integer
REPO_SYNC_THREADS=32
# Signed build?

# This script must be run from the source shell, if not, crash.
if [ "${BASH_SOURCE[0]}" == "${0}" ]
then
 echo '
This script must be run from the source shell.

Usage:
       . los.sh [reset]|[clobber]
  source los.sh [reset]|[clobber]

reset - Remove old source (if existing) before building.
clobber - Clean environment before building.'
 exit 1
fi

# Set repo sync threads
REPO_SYNC_OPTS="$REPO_SYNC_OPTS"' -j'
if [ $REPO_SYNC_THREADS == 'auto' ]
then
 REPO_SYNC_OPTS="$REPO_SYNC_OPTS"$(nproc --all)
else
 REPO_SYNC_OPTS="$REPO_SYNC_OPTS""$REPO_SYNC_THREADS"
fi

# Check if $LOG_PATH is writable
touch "$LOG_PATH"'.test'
if [ $? -ne 0 ]
then
 echo '
===================================
I             WARNING             I
I                                 I
I  Log path not writable.         I
I  Will not log anything.         I
==================================='
 LOG_PATH='/dev/null'
else
 rm "$LOG_PATH"'.test'
 LOG_PATH="$LOG_PATH""$LOG_FILENAME"
 echo '=> Enabled logging!' | tee -a $LOG_PATH
fi

# Prepare the working directory.
echo '=> Preparing...' | tee -a $LOG_PATH
if [ "$1" == 'reset' ]
then
 echo '
===================================
I               INFO              I
I                                 I
I        Removing old source.     I
===================================' | tee -a $LOG_PATH
 rm -Rf "$WORKING_DIR"
fi
mkdir -p "$WORKING_DIR"
if [ -d "$WORKING_DIR" ]
then
 echo 'Success creating working directory.' | tee -a $LOG_PATH
 echo 'ROM: '"$ROM_NAME"' '"$ROM_VERSION" | tee -a $LOG_PATH
 echo 'DATE: '$(date '+%Y-%m-%d %H:%M:%S') | tee -a $LOG_PATH
 echo 'LOG: '"$LOG_PATH" | tee -a $LOG_PATH
 echo 'MANIFEST: '"$MANIFEST_URL" | tee -a $LOG_PATH
 cd "$WORKING_DIR"
 echo '=> Initializing repo...' | tee -a $LOG_PATH
 repo init -u git://github.com/LineageOS/android.git -b lineage-16.0 $REPO_INIT_OPTS 2>&1 | tee -a $LOG_PATH
 echo '=> Downloading device manifest...' | tee -a $LOG_PATH
 mkdir -p "$WORKING_DIR"'/.repo/local_manifests'
 if [ $? -eq 0 ]
 then
  wget -q "$MANIFEST_URL" -O "$WORKING_DIR"'/.repo/local_manifests/'"$BREAKFAST_DEVICE"'.xml' 2>&1 | tee -a $LOG_PATH
  echo '=> Syncing repo...' | tee -a $LOG_PATH
  repo sync $REPO_SYNC_OPTS 2>&1 | tee -a $LOG_PATH
  if [ $? -eq 0 ]
  then
   if [ "$1" == 'clobber' ]
   then
    echo '=> Cleaning...' | tee -a $LOG_PATH
    . build/envsetup.sh
    make -j$(nproc --all) clobber
   fi
   echo '=> Building...' | tee -a $LOG_PATH
   if [ $SIGN -eq 1 ]
   then
    echo 'Will now try to use private signature on this build.' | tee -a $LOG_PATH
    if [ ! -f ~/signbuild.sh ]
    then
      echo '
===================================
I              INFO               I
I                                 I
I signbuild.sh is not present in  I
I your home path. Downloading...  I
===================================' | tee -a $LOG_PATH
      wget -q "$SIGNBUILD_URL" -O ~/signbuild.sh
    fi
    . ~/signbuild.sh $BREAKFAST_DEVICE 2>&1 | tee -a $LOG_PATH
   else
    echo '
===================================
I             WARNING             I
I                                 I
I       Publicly signed build.    I
===================================' | tee -a $LOG_PATH
    . build/envsetup.sh 2>&1 | tee -a $LOG_PATH
    brunch "$ROM_LUNCH"_"$BREAKFAST_DEVICE"-userdebug 2>&1 | tee -a $LOG_PATH
   fi
   if [ $? -eq 0 ]
   then
    echo '
===================================
I              ERROR              I
I                                 I
I    Build compilation failed.    I
===================================' | tee -a $LOG_PATH
   fi
  else
   echo '
===================================
I              ERROR              I
I                                 I
I       Failed to sync repo       I
===================================' | tee -a $LOG_PATH
  fi
 else
  echo '
===================================
I              ERROR              I
I                                 I
I    Failed to initialize repo    I
===================================' | tee -a $LOG_PATH
 fi
fi
