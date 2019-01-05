#!/usr/bin/env bash
if [ -z $1 ]
then
 echo "You must provide a device codename."
 echo "Nothing to do."
else
 echo "The build date is "$(date)"."
 echo "=> Set up the environment."
 . build/envsetup.sh
 if [ -z $2 ]
 then
  echo "=> Will now run breakfast for device codename $1"
  breakfast sample 2>&1 > /dev/null
  if [ $? -eq 127 ]
  then
    echo "WARN: This ROM doesn't seem to support breakfast, trying with lunch instead."
    lunch "$ROM_LUNCH"'_'"$BREAKFAST_DEVICE"'-userdebug' > tmp
  else
    breakfast $1 2>&1 > tmp
  fi
 else
  echo "=> Will now run lunch using string '$2'."
  TEST=$(echo "$2" | grep 'eng') && echo "
=====================================
|                                   |
|               WARNING             |
|                                   |
| This is an eng build, expect lag  |
| and other unexpected behavior.    |
|                                   |
====================================="
  lunch $2 > tmp
 fi
 TARGETZIP=$(cat tmp | sed 's/PLATFORM_VERSION//')
 rm tmp
 echo "$TARGETZIP" | grep lineage > /dev/null
 if [ $? -eq 0 ]
 then
  TARGETZIP=$(echo "$TARGETZIP" | grep TARGET_PRODUCT | sed 's/TARGET_PRODUCT=//' | sed 's/_harpia//')-$(echo "$TARGETZIP" | grep _VERSION | sed 's/._VERSION/\n/' | grep = | sed 's/=//').zip
 else
  TARGETZIP=$(echo "$TARGETZIP" | grep _VERSION | sed 's/._VERSION/\n/' | grep = | sed 's/=//' | head -1).zip
 fi
 echo '==> Target filename is '"$TARGETZIP"
 echo "=> Making target files package..."
 mka -j$(nproc --all) target-files-package dist &&
 printf "=> Signing apks... "
 TARGET=$(ls -tr1 out/dist | tail -1)
 printf "(target from $TARGET)\n"
 if [ ! -d ~/.android-certs ]
 then
  echo "=> ~/.android-certs not found, aborting..."
  export SIGNSTAT='err'
 else
  export SIGNSTAT='ok'
  croot
  ./build/tools/releasetools/sign_target_files_apks -e Gallery2.apk,GoogleCamera.apk,AntHalService.apk,framework-res__auto_generated_rro.apk=$HOME/.android-certs/releasekey -o -d ~/.android-certs \
      "out/dist/$TARGET" \
      signed-target_files.zip || export SIGNSTAT='err'
  echo "Making OTA package..."
  ./build/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey \
      --block --backup=true \
      signed-target_files.zip \
      $TARGETZIP || export SIGNSTAT='err'
  if [ "$SIGNSTAT" != 'err' ]
  then
   echo '==> All done, writing MD5sum file to '"$TARGETZIP"'.md5sum'
   md5sum "$TARGETZIP" > "$TARGETZIP"'.md5sum'
   echo '==> Success! <=='
  else
   echo '==> Failed to sign your build. Please check the errors above.'
  fi
 fi
fi
