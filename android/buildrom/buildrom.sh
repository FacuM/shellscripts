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

# This script must be run from the source shell, if not, crash.
if [ "${BASH_SOURCE[0]}" == "${0}" ]
then
 echo '
This script must be run from the source shell.

Usage:
       . configname.sh [reset]|[clobber]|[ns]
  source configname.sh [reset]|[clobber]|[ns]

reset - Remove old source (if existing) before building.
clobber - Clean environment before building.
ns - Do not sync, just build.
js - Just sync, do not build.

Do not run the script directly, call your configuration script instead.'
 exit 1
fi

if [ -z $LAUNCH_NOW ]
then
 echo 'Do not run the script directly, call your configuration script instead.'
else
 # Set repo sync threads
 REPO_SYNC_OPTS="$REPO_SYNC_OPTS"' -j'
 if [ $REPO_SYNC_THREADS == 'auto' ]
 then
  REPO_SYNC_OPTS="$REPO_SYNC_OPTS"$(nproc --all)
 else
  REPO_SYNC_OPTS="$REPO_SYNC_OPTS""$REPO_SYNC_THREADS"
 fi

 # Check if $LOG_PATH is writable
 mkdir -p "$WORKING_DIR"
 touch "$LOG_PATH"'/.test'
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
  rm "$LOG_PATH"'/.test'
  LOG_PATH="$LOG_PATH"'/'"$LOG_FILENAME"
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
 if [ -d "$WORKING_DIR" ]
 then
  echo 'Success creating working directory.' | tee -a $LOG_PATH
  echo 'ROM: '"$ROM_NAME"' '"$ROM_VERSION" | tee -a $LOG_PATH
  echo 'DEVICE: '"$BREAKFAST_DEVICE" | tee -a $LOG_PATH
  echo 'DATE: '$(date '+%Y-%m-%d %H:%M:%S') | tee -a $LOG_PATH
  echo 'LOG: '"$LOG_PATH" | tee -a $LOG_PATH
  echo 'MANIFEST: '"$DEVICE_MANIFEST_URL" | tee -a $LOG_PATH
  cd "$WORKING_DIR"
  echo '=> Initializing repo...' | tee -a $LOG_PATH
  repo init -u $ROM_MANIFEST_URL -b $ROM_MANIFEST_BRANCH $REPO_INIT_OPTS 2>&1 | tee -a $LOG_PATH
  echo '=> Downloading device manifest...' | tee -a $LOG_PATH
  mkdir -p "$WORKING_DIR"'/.repo/local_manifests'
  if [ $? -eq 0 ]
  then
   wget -q "$DEVICE_MANIFEST_URL" -O "$WORKING_DIR"'/.repo/local_manifests/'"$BREAKFAST_DEVICE"'.xml' 2>&1 | tee -a $LOG_PATH
   if [ "$1" != 'ns' ]
   then
    echo '=> Syncing repo...' | tee -a $LOG_PATH
    repo sync $REPO_SYNC_OPTS 2>&1 | tee -a $LOG_PATH
   fi
   if [ $? -eq 0 ] && [ "$1" != 'js' ]
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
    if [ $? -eq 0 ] && [ "$SIGNSTAT" != 'err' ]
    then
     echo '
===================================
I              INFO               I
I                                 I
I     Compilation completed!      I
===================================' | tee -a $LOG_PATH
     # Run "$ON_SUCCESS"
     if [ "$ON_SUCCESS" != '' ]
     then
      $ON_SUCCESS
     fi
    else
     echo '
===================================
I              ERROR              I
I                                 I
I       Compilation failed.       I
===================================' | tee -a $LOG_PATH
    fi
   else
    if [ "$1" == 'js' ]
    then
     echo '
===================================
I              INFO               I
I                                 I
I          Done syncing!          I
===================================' | tee -a $LOG_PATH
    else
     echo '
===================================
I              ERROR              I
I                                 I
I       Failed to sync repo       I
===================================' | tee -a $LOG_PATH
    fi
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

 # Handle logger privacy
 if [ "$USERNAME" != 'auto' ]
 then
  echo '=> Hiding logged username...' | tee -a $LOG_PATH
  cat $LOG_PATH | sed 's/'"$USER"'/'"$USERNAME"'/g' > "$LOG_DIR"'/tmp'
  rm $LOG_PATH
  # Using 'cp' and 'rm' as 'mv' has issues on some filesystems.
  cp "$LOG_DIR"'/tmp' $LOG_PATH
  rm "$LOG_DIR"'/tmp'
 fi
fi
