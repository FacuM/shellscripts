#!/usr/bin/env bash
if [ -z $1 ]
then
 echo "You must provide a device codename."
 echo "Nothing to do."
else
D=$(date +%Y%m%d)
echo "The build date is "$(date)"."
echo "Will now run breakfast for device codename $1".
breakfast $1 &&
echo "Making target files package..."
mka target-files-package dist &&
printf "Signing apks... "
TARGET=$(ls -tr1 out/dist | tail -1)
printf "(target from $TARGET)\n"
croot
./build/tools/releasetools/sign_target_files_apks -e GoogleCamera.apk,AntHalService.apk,framework-res__auto_generated_rro.apk=$HOME/.android-certs/releasekey -o -d ~/.android-certs \
    "out/dist/$TARGET" \
    signed-target_files.zip &&
echo "Making OTA package..."
./build/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey \
    --block --backup=true \
    signed-target_files.zip \
    'lineage-16.0-'"$D"'-UNOFFICIAL-'"$1"'.zip'
fi
