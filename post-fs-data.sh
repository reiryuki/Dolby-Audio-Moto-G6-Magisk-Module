mount -o rw,remount /data
MODPATH=${0%/*}

# log
exec 2>$MODPATH/debug-pfsd.log
set -x

# var
API=`getprop ro.build.version.sdk`
ABI=`getprop ro.product.cpu.abi`

# function
permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if ! setenforce 0; then
    echo 0 > /sys/fs/selinux/enforce
  fi
fi
}
magisk_permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
	magiskpolicy --live "permissive *"
  else
	$MODPATH/$ABI/libmagiskpolicy.so --live "permissive *"
  fi
fi
}
sepolicy_sh() {
if [ -f $FILE ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
    magiskpolicy --live --apply $FILE 2>/dev/null
  else
    $MODPATH/$ABI/libmagiskpolicy.so --live --apply $FILE 2>/dev/null
  fi
fi
}

# selinux
SELINUX=`getenforce`
chmod 0755 $MODPATH/*/libmagiskpolicy.so
#1permissive
#2magisk_permissive
#kFILE=$MODPATH/sepolicy.rule
#ksepolicy_sh
FILE=$MODPATH/sepolicy.pfsd
sepolicy_sh

# run
. $MODPATH/copy.sh

# conflict
AML=/data/adb/modules/aml
ACDB=/data/adb/modules/acdb
if [ -d $ACDB ] && [ ! -f $ACDB/disable ]; then
  if [ ! -d $AML ] || [ -f $AML/disable ]; then
    rm -f `find $MODPATH/system/etc $MODPATH/vendor/etc\
     $MODPATH/system/vendor/etc -maxdepth 1 -type f -name\
     *audio*effects*.conf -o -name *audio*effects*.xml`
  fi
fi

# run
. $MODPATH/.aml.sh

# directory
DIR=/data/vendor/media
mkdir -p $DIR
chmod 0770 $DIR
chown 1046.1013 $DIR
chcon u:object_r:vendor_media_data_file:s0 $DIR

# permission
DIRS=`find $MODPATH/vendor\
           $MODPATH/system/vendor -type d`
for DIR in $DIRS; do
  chown 0.2000 $DIR
done
chcon -R u:object_r:system_lib_file:s0 $MODPATH/system/lib*
chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/odm/etc
if [ -L $MODPATH/system/vendor ]\
&& [ -d $MODPATH/vendor ]; then
  chmod 0751 $MODPATH/vendor/bin
  chmod 0751 $MODPATH/vendor/bin/hw
  chmod 0755 $MODPATH/vendor/odm/bin
  chmod 0755 $MODPATH/vendor/odm/bin/hw
  FILES=`find $MODPATH/vendor/bin\
              $MODPATH/vendor/odm/bin -type f`
  for FILE in $FILES; do
    chmod 0755 $FILE
    chown 0.2000 $FILE
  done
  chcon -R u:object_r:vendor_file:s0 $MODPATH/vendor
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/etc
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/odm/etc
#  chcon u:object_r:hal_dms_default_exec:s0 $MODPATH/vendor/bin/hw/vendor.dolby*.hardware.dms*@*-service
#  chcon u:object_r:hal_dms_default_exec:s0 $MODPATH/vendor/odm/bin/hw/vendor.dolby*.hardware.dms*@*-service
else
  chmod 0751 $MODPATH/system/vendor/bin
  chmod 0751 $MODPATH/system/vendor/bin/hw
  chmod 0755 $MODPATH/system/vendor/odm/bin
  chmod 0755 $MODPATH/system/vendor/odm/bin/hw
  FILES=`find $MODPATH/system/vendor/bin\
              $MODPATH/system/vendor/odm/bin -type f`
  for FILE in $FILES; do
    chmod 0755 $FILE
    chown 0.2000 $FILE
  done
  chcon -R u:object_r:vendor_file:s0 $MODPATH/system/vendor
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/etc
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/odm/etc
#  chcon u:object_r:hal_dms_default_exec:s0 $MODPATH/system/vendor/bin/hw/vendor.dolby*.hardware.dms*@*-service
#  chcon u:object_r:hal_dms_default_exec:s0 $MODPATH/system/vendor/odm/bin/hw/vendor.dolby*.hardware.dms*@*-service
fi

# function
mount_helper() {
if [ -d /odm ]\
&& [ "`realpath /odm/etc`" == /odm/etc ]; then
  DIR=$MODPATH/system/odm
  FILES=`find $DIR -type f -name $AUD`
  for FILE in $FILES; do
    DES=/odm`echo $FILE | sed "s|$DIR||g"`
    umount $DES
    mount -o bind $FILE $DES
  done
fi
if [ -d /my_product ]; then
  DIR=$MODPATH/system/my_product
  FILES=`find $DIR -type f -name $AUD`
  for FILE in $FILES; do
    DES=/my_product`echo $FILE | sed "s|$DIR||g"`
    umount $DES
    mount -o bind $FILE $DES
  done
fi
}

# mount
if ! grep -E 'delta|Delta|kitsune' /data/adb/magisk/util_functions.sh; then
  mount_helper
fi

# patch manifest
if [ "$API" -ge 28 ]; then
  M=/system/etc/vintf/manifest.xml
  FILE="/*/etc/vintf/manifest.xml /*/*/etc/vintf/manifest.xml
        /*/etc/vintf/manifest/*.xml /*/*/etc/vintf/manifest/*.xml"
else
  M=/system/manifest.xml
  FILE="/*/manifest.xml /*/*/manifest.xml"
fi
rm -f $MODPATH$M
if ! grep -A2 vendor.dolby.hardware.dms $FILE | grep 1.0; then
  cp -af $M $MODPATH$M
  if [ -f $MODPATH$M ]; then
    sed -i '/<manifest/a\
    <hal format="hidl">\
        <name>vendor.dolby.hardware.dms</name>\
        <transport>hwbinder</transport>\
        <fqname>@1.0::IDms/default</fqname>\
    </hal>' $MODPATH$M
    umount $M
    mount -o bind $MODPATH$M $M
    killall hwservicemanager
  fi
fi

# function
mount_bind_file() {
for FILE in $FILES; do
  if echo $FILE | grep libhidlbase.so; then
    DES=`echo $FILE | sed 's|libhidlbase.so|libutils.so|g'`
    if grep _ZN7android8String16aSEOS0_ $DES; then
      umount $FILE
      mount -o bind $MODFILE $FILE
    fi
  else
    umount $FILE
    mount -o bind $MODFILE $FILE
  fi
done
}
mount_bind_to_apex() {
for NAME in $NAMES; do
  MODFILE=$MODPATH/system/lib64/$NAME
  if [ -f $MODFILE ]; then
    FILES=`find /apex /system/apex -path *lib64/* -type f -name $NAME`
    mount_bind_file
  fi
  MODFILE=$MODPATH/system/lib/$NAME
  if [ -f $MODFILE ]; then
    FILES=`find /apex /system/apex -path *lib/* -type f -name $NAME`
    mount_bind_file
  fi
done
}

# mount
NAMES=libhidlbase.so
mount_bind_to_apex

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  mv -f $FILE $FILE.txt
fi









