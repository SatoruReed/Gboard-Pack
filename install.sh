##########################################################################################
#
# Script by Satoru Reed
# Credits: topjohnwu, modified by Zackptg5
#
##########################################################################################

##########################################################################################
# Unity Logic - Don't change/move this section
##########################################################################################

if [ -z $UF ]; then
  UF=$TMPDIR/common/unityfiles
  unzip -oq "$ZIPFILE" 'common/unityfiles/util_functions.sh' -d $TMPDIR >&2
  [ -f "$UF/util_functions.sh" ] || { ui_print "! Unable to extract zip file !"; exit 1; }
  . $UF/util_functions.sh
fi

comp_check


##########################################################################################
# Config Flags
##########################################################################################

# Uncomment and change 'MINAPI' and 'MAXAPI' to the minimum and maximum android version for your mod
# Uncomment DYNLIB if you want libs installed to vendor for oreo+ and system for anything older
# Uncomment SYSOVER if you want the mod to always be installed to system (even on magisk) - note that this can still be set to true by the user by adding 'sysover' to the zipname
# Uncomment DEBUG if you want full debug logs (saved to /sdcard in magisk manager and the zip directory in twrp) - note that this can still be set to true by the user by adding 'debug' to the zipname
#MINAPI=21
#MAXAPI=25
#DYNLIB=true
#SYSOVER=true
#DEBUG=true

# Uncomment if you do *NOT* want Magisk to mount any files for you. Most modules would NOT want to set this flag to true
# This is obviously irrelevant for system installs. This will be set to true automatically if your module has no files in system
#SKIPMOUNT=true

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
# Custom Logic
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print " "
  ui_print "    ♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥️♥️"
  ui_print "    ♥ REED PACK: Themes and Emoji's ♥"
  ui_print "    ♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥️♥️"
  ui_print "    ♥     v4.0 (Special version)    ♥"
  ui_print "    ♥       by @TheReedLegend       ♥"
  ui_print "    ♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥️♥️"
  ui_print " "
}
on_install() {
  #Definitions
  MSG_DIR="/data/data/com.facebook.orca"
  FB_DIR="/data/data/com.facebook.katana"
  EMOJI_DIR="app_ras_blobs"
  FONT_DIR=$MODPATH/system/fonts
  FONT_EMOJI="NotoColorEmoji.ttf"
  ui_print "- Extracting module files"
  ui_print "- Installing Emojis"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

  #Compatibility with different devices and potential Support for Android 13?
  variants='SamsungColorEmoji.ttf LGNotoColorEmoji.ttf HTC_ColorEmoji.ttf AndroidEmoji-htc.ttf ColorUniEmoji.ttf DcmColorEmoji.ttf CombinedColorEmoji.ttf NotoColorEmojiLegacy.ttf'
  for i in $variants ; do
        if [ -f "/system/fonts/$i" ]; then
            cp $FONT_DIR/$FONT_EMOJI $FONT_DIR/$i && ui_print "- Replacing $i"
        fi
  done
  
  #Facebook Messenger
  if [ -d "$MSG_DIR" ]; then
    ui_print "- Replacing Messenger Emojis"
    cd $MSG_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$FONT_EMOJI ./FacebookEmoji.ttf
  fi
  
  #Facebook App
  if [ -d "$FB_DIR" ]; then
    ui_print "- Replacing Facebook Emojis"
    cd $FB_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$FONT_EMOJI ./FacebookEmoji.ttf
  fi
  
  #Verifying Android version
  android_ver=$(getprop ro.build.version.sdk)
  #if Android 12 detected
  if [ $android_ver -ge 31 ]; then
        DATA_FONT_DIR="/data/fonts/files"
    if [ -d "$DATA_FONT_DIR" ] && [ "$(ls -A $DATA_FONT_DIR)" ]; then
            ui_print "- Android 12 Detected"
            ui_print "- Checking [$DATA_FONT_DIR]"
        for dir in $DATA_FONT_DIR/*/ ; do
                cd $dir
            for file in * ; do
                if [ "$file" == *ttf ] ; then
                    cp $FONT_DIR/$FONT_EMOJI $file && ui_print "- Replacing $file"
                fi
                done
        done
    fi
  fi
  
  
  [[ -d /sbin/.core/mirror ]] && MIRRORPATH=/sbin/.core/mirror || unset MIRRORPATH
  FONTS=/system/etc/fonts.xml
  FONTFILES=$(sed -ne '/<family lang="und-Zsye".*>/,/<\/family>/ {s/.*<font weight="400" style="normal">\(.*\)<\/font>.*/\1/p;}' $MIRRORPATH$FONTS)
  for font in $FONTFILES
  do
    ln -s /system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/$font
  done
}


set_permissions() {

  set_perm_recursive $UNITY$MODPATH 0 0 0755 0644
  set_perm_recursive $UNITY/data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700
  set_perm_recursive $UNITY/data/data/com.facebook.katana/app_ras_blobs 0 0 0755 755
  set_perm_recursive $UNITY/data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700

  # Note that all files/folders have the $UNITY prefix - keep this prefix on all of your files/folders
  # Also note the lack of '/' between variables - preceding slashes are already included in the variables
  # Use $VEN for vendor (Do not use /system$VEN, the $VEN is set to proper vendor path already - could be /vendor, /system/vendor, etc.)

  # Some examples:
  
  # For directories (includes files in them):
  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  
  # set_perm_recursive $UNITY/system/lib 0 0 0755 0644
  # set_perm_recursive $UNITY$VEN/lib/soundfx 0 0 0755 0644

  # For files (not in directories taken care of above)
  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  
  # set_perm $UNITY/system/lib/libart.so 0 0 0644
}

# Custom Variables for Install AND Uninstall - Keep everything within this function - runs before uninstall/install
unity_custom() {
  : # Remove this if adding to this function
}

# Custom Functions for Install AND Uninstall - You can put them here