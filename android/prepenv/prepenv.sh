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
DEBIAN_BUILD_DEPENDENCIES='bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev screen screenie tmux unzip libisl15'
ARCH_BUILD_DEPENDENCIES='bc bison curl libisl15 unzip zip tmux screen screenie lib32-gcc-libs git gnupg flex gperf sdl wxgtk2 squashfs-tools ncurses zlib schedtool perl-switch libxslt python2-virtualenv rsync ncurses5-compat-libs lib32-zlib lib32-ncurses lib32-readline lib32-ncurses5-compat-libs'
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
 PM_CMD='pacman -Syu --noconfirm'
 sudo $PM_CMD base-devel
 rm -rf yay
 git clone https://aur.archlinux.org/yay.git
 cd yay
 makepkg -si --noconfirm
 cd ../
 PM_CMD='yay -Syu --noconfirm'
 BUILD_DEPENDENCIES=$ARCH_BUILD_DEPENDENCIES
else
 PM_CMD='apt-get'
 sudo $PM_CMD update
 PM_CMD="$PM_CMD"' -y install'
 BUILD_DEPENDENCIES=$DEBIAN_BUILD_DEPENDENCIES
fi
echo 'Please allow me to run as root.'
sudo echo "--> We are now rooted!" || echo '--> Failed to acquire root permission, quitting.'
if [ $? -eq 0 ]
then
 echo '=> Installing dependencies...'
 sudo $PM_CMD $BUILD_DEPENDENCIES
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
  echo '=> Failed to write build settings to "~/.bashrc".'
 fi
fi
