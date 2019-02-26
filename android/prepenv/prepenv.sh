########################################
#  Android source automatic environment setup
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################
#
# Depends on: Ubuntu or Ubuntu-based distro.
#
########################################

CCACHE_SIZE='100G'
DEBIAN_BUILD_DEPENDENCIES='bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev screen screenie tmux unzip libisl15 git-lfs'
ARCH_BUILD_DEPENDENCIES='bc bison curl unzip zip tmux screen lib32-gcc-libs git gnupg flex gperf sdl wxgtk2 squashfs-tools lineageos-devel git-lfs'
ARCH_BUILD_DEPENDENCIES_NOROOT='isl'
BIN_PATH="$HOME"'/bin'
# This script must be run from the source shell, if not, crash.
if [ "${BASH_SOURCE[0]}" == "${0}" ]
then
 echo '
This script must be run from the source shell.

Usage:
       . prepenv.sh
  source prepenv.sh'
 exit 1
fi

OS_RELEASE="$(cat /etc/*-release)"
if echo "$OS_RELEASE" | grep "Arch" > /dev/null
then
 # Fetching an updated list of mirrors
 cp -f /etc/pacman.d/mirrorlist ./mirrorlist
 echo 'Backed up /etc/pacman.d/mirrorlist to ./mirrorlist. Fetching from country "all".'
 if curl -s 'https://www.archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on' > ./mirrorlist_new 2> /dev/null
 then
  echo 'Success downloading an updated list of mirrors.'
  cat ./mirrorlist_new | sed 's/#Server =/Server =/g' > ./mirrorlist_new_enabled
  rm -f ./mirrorlist_new
  sudo cp -f ./mirrorlist_new_enabled /etc/pacman.d/mirrorlist
  rm -f ./mirorlist_new_enabled
 else
  echo 'WARNING: Unable to update the list of mirrors. This might cause unexpected behavior.'
 fi
 PM_CMD='sudo pacman -Syu --noconfirm'
 $PM_CMD base-devel
 # Enable multilib
 echo 'Enabling multilib support...'
 echo '--- pacman.conf 2019-02-25 11:37:33.365488333 +0000
+++ /etc/pacman.conf    2019-01-07 18:36:11.309331112 +0000
@@ -90,8 +90,8 @@
 #[multilib-testing]
 #Include = /etc/pacman.d/mirrorlist

-#[multilib]
-#Include = /etc/pacman.d/mirrorlist
+[multilib]
+Include = /etc/pacman.d/mirrorlist

 # An example of a custom package repository.  See the pacman manpage for
 # tips on creating your own repositories.' > patch
 CUR=$PWD
 cd /etc
 sudo patch -f < $CUR'/patch'
 # Delete patch rejections (if any)
 sudo rm -f pacman.conf.rej
 cd $CUR
 rm -rf yay
 git clone https://aur.archlinux.org/yay.git
 cd yay
 makepkg -si --noconfirm
 cd ../
 PM_CMD='yay -Syu --noconfirm'
 BUILD_DEPENDENCIES=$ARCH_BUILD_DEPENDENCIES
 $PM_CMD isl
else
 PM_CMD='sudo apt-get'
 $PM_CMD update
 PM_CMD="$PM_CMD"' -y install'
 BUILD_DEPENDENCIES=$DEBIAN_BUILD_DEPENDENCIES
fi
if [ $? -eq 0 ]
then
 echo '=> Installing dependencies...'
 $PM_CMD $BUILD_DEPENDENCIES
 if [ $? -eq 0 ]
 then
  echo '=> Setting up your profile...'
  echo '
# ====================== #
# Android build settings #
# ====================== #
export USE_CCACHE=1
ccache -M '"$CCACHE_SIZE"'
# ====================== #
# Android build settings #
# ====================== #
' >> ~/.bashrc
  if [ $? -eq 0 ]
  then
   echo '=> Installing and setting up repo...'
   # Make sure $BIN_PATH exists.
   mkdir -p $BIN_PATH
   curl -s https://storage.googleapis.com/git-repo-downloads/repo > "$BIN_PATH"'/repo'
   if [ $? -eq 0 ]
   then
    chmod a+x "$BIN_PATH"'/repo'
    echo '=> Reloading Bash configuration please wait...'
    . ~/.bashrc
    echo '=> Done reloading Bash configuration.'
    echo '=> Checking if '"$BIN_PATH"' is present in $PATH.'
    echo "$PATH" | grep "$BIN_PATH" >> /dev/null
    if [ $? -ne 0 ]
    then
     echo '
WARNING: This distribution might be too outdated as '"$BIN_PATH"' is not being included automatically.
Forcing this behavior in ~/.bashrc.

=> Setting up $PATH to include '"$BIN_PATH"'.'
     echo '
PATH='"$BIN_PATH"':$PATH' >> ~/.bashrc
     echo '=> Reloading Bash configuration please wait...'
     . ~/.bashrc
     echo '=> Done reloading Bash configuration.'
    fi
    echo '=> All done, you can now build your ROM!'
   else
    echo '=> Failed to download repo. Please try again.'
   fi
  else
   echo '=> Failed to set up your profile. Please try again.'
  fi
 else
  echo '=> Failed to fetch the required packages.'
 fi
fi
