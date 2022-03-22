(

mount /data
mount -o rw,remount /data
MODPATH=${0%/*}
MODID=`echo "$MODPATH" | sed -n -e 's/\/data\/adb\/modules\///p'`
APP="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app`"
PKG="com.dolby.dax2appUI
     com.dolby.daxservice
     com.motorola.motosignature.app"
     
# cleaning
for PKGS in $PKG; do
  rm -rf /data/user/*/$PKGS
done
for APPS in $APP; do
  rm -f `find /data/dalvik-cache /data/resource-cache -type f -name *$APPS*.apk`
done
rm -rf /metadata/magisk/"$MODID"
rm -rf /mnt/vendor/persist/magisk/"$MODID"
rm -rf /persist/magisk/"$MODID"
rm -rf /data/unencrypted/magisk/"$MODID"
rm -rf /cache/magisk/"$MODID"
rm -f /data/vendor/media/dax_sqlite3.db

# boot mode
if [ ! "$BOOTMODE" ]; then
  [ -z $BOOTMODE ] && ps | grep zygote | grep -qv grep && BOOTMODE=true
  [ -z $BOOTMODE ] && ps -A | grep zygote | grep -qv grep && BOOTMODE=true
  [ -z $BOOTMODE ] && BOOTMODE=false
fi

# magisk
if [ ! "$MAGISKTMP" ]; then
  if [ -d /sbin/.magisk ]; then
    MAGISKTMP=/sbin/.magisk
  else
    MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
  fi
fi

# remount
mount -o rw,remount $MAGISKTMP/mirror/system
mount -o rw,remount $MAGISKTMP/mirror/system_root
mount -o rw,remount $MAGISKTMP/mirror/system_ext
mount -o rw,remount $MAGISKTMP/mirror/vendor
mount -o rw,remount /system
mount -o rw,remount /
mount -o rw,remount /system_root
mount -o rw,remount /system_ext
mount -o rw,remount /vendor

# function
restore() {
  for FILES in $FILE; do
    if [ -f $FILES.orig ]; then
      mv -f $FILES.orig $FILES
    fi
    if [ -f $FILES.bak ]; then
      mv -f $FILES.bak $FILES
    fi
  done
}

# restore
FILE=`find $MAGISKTMP/mirror/system\
           $MAGISKTMP/mirror/system_ext\
           $MAGISKTMP/mirror/vendor\
           $MAGISKTMP/mirror/system_root/system\
           $MAGISKTMP/mirror/system_root/system_ext\
           $MAGISKTMP/mirror/system_root/vendor\
           /system\
           /system_ext\
           /vendor\
           /system_root/system\
           /system_root/system_ext\
           /system_root/vendor -type f -name manifest.xml -o -name *_hwservice_contexts -o -name *_file_contexts`
restore

# remount
if [ "$BOOTMODE" == true ]; then
  mount -o ro,remount $MAGISKTMP/mirror/system
  mount -o ro,remount $MAGISKTMP/mirror/system_root
  mount -o ro,remount $MAGISKTMP/mirror/system_ext
  mount -o ro,remount $MAGISKTMP/mirror/vendor
  mount -o ro,remount /system
  mount -o ro,remount /
  mount -o ro,remount /system_root
  mount -o ro,remount /system_ext
  mount -o ro,remount /vendor
fi

) 2>/dev/null


