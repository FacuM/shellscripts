#!/usr/bin/env bash
if [ -z $1 ]
then
 echo "You must provide a device codename."
 echo "Nothing to do."
else
echo "The build date is "$(date)"."
echo "Set up the environment."
. build/envsetup.sh
echo "Will now run breakfast for device codename $1".
TARGETZIP=$(breakfast $1)
TARGETZIP=$(echo "$TARGETZIP" | grep TARGET_PRODUCT | sed 's/TARGET_PRODUCT=//' | sed 's/_harpia//')-$(echo "$TARGETZIP" | grep LINEAGE_VERSION | sed 's/LINEAGE_VERSION=//').zip
echo '==> Target filename is '"$TARGETZIP"
echo "Making target files package..."
mka -j$(nproc --all) target-files-package dist &&
printf "Signing apks... "
TARGET=$(ls -tr1 out/dist | tail -1)
printf "(target from $TARGET)\n"
croot
./build/tools/releasetools/sign_target_files_apks -e Gallery2.apk,GoogleCamera.apk,AntHalService.apk,framework-res__auto_generated_rro.apk=$HOME/.android-certs/releasekey -o -d ~/.android-certs \
    "out/dist/$TARGET" \
    signed-target_files.zip &&
echo "Making OTA package..."
./build/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey \
    --block --backup=true \
    signed-target_files.zip \
    $TARGETZIP
echo '==> All done, writing MD5sum file to '"$TARGETZIP"'.md5sum'
md5sum "$TARGETZIP" > "$TARGETZIP"'.md5sum'
echo '==> Success! <=='
fi
