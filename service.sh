MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`
AML=/data/adb/modules/aml

# debug
exec 2>$MODPATH/debug.log
set -x

# property
resetprop ro.product.brand motorola
resetprop ro.product.device ali
resetprop ro.product.manufacturer motorola
resetprop ro.product.model "moto g(6)"
resetprop audio.dolby.ds2.enabled true
resetprop audio.dolby.ds2.hardbypass true
resetprop vendor.audio.dolby.ds2.enabled true
resetprop vendor.audio.dolby.ds2.hardbypass true

# function
stop_service() {
for NAMES in $NAME; do
  if getprop | grep "init.svc.$NAMES\]: \[running"; then
    stop $NAMES
  fi
done
}
run_service() {
for FILES in $FILE; do
  killall $FILES
  $FILES &
  PID=`pidof $FILES`
done
}

# stop
NAME="dms-hal-1-0 dms-hal-2-0 dms-v36-hal-2-0"
stop_service

# mount
DIR=/odm/bin/hw
FILE=$DIR/vendor.dolby_v3_6.hardware.dms360@2.0-service
if [ "`realpath $DIR`" == $DIR ] && [ -f $FILE ]; then
  mount -o bind $MODPATH/system/vendor/$FILE $FILE
fi

# run
FILE=`realpath /vendor`/bin/hw/vendor.dolby.hardware.dms@1.0-service
run_service

# restart
VIBRATOR=`realpath /*/bin/hw/vendor.qti.hardware.vibrator.service*`
[ "$VIBRATOR" ] && killall $VIBRATOR
POWER=`realpath /*/bin/hw/vendor.mediatek.hardware.mtkpower@*-service`
[ "$POWER" ] && killall $POWER
killall android.hardware.usb@1.0-service
killall android.hardware.usb@1.0-service.basic
killall android.hardware.sensors@1.0-service
killall android.hardware.sensors@2.0-service-mediatek
killall android.hardware.light-service.mt6768
killall android.hardware.lights-service.xiaomi_mithorium
CAMERA=`realpath /*/bin/hw/android.hardware.camera.provider@*-service_64`
[ "$CAMERA" ] && killall $CAMERA

# wait
sleep 20

# aml fix
DIR=$AML/system/vendor/odm/etc
if [ -d $DIR ] && [ ! -f $AML/disable ]; then
  chcon -R u:object_r:vendor_configs_file:s0 $DIR
fi

# magisk
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`realpath /dev/*/.magisk`
fi

# path
MIRROR=$MAGISKTMP/mirror
SYSTEM=`realpath $MIRROR/system`
VENDOR=`realpath $MIRROR/vendor`
ODM=`realpath $MIRROR/odm`
MY_PRODUCT=`realpath $MIRROR/my_product`

# mount
NAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
if [ -d $AML ] && [ ! -f $AML/disable ]\
&& find $AML/system/vendor -type f -name $NAME; then
  NAME="*audio*effects*.conf -o -name *audio*effects*.xml"
#p  NAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
  DIR=$AML/system/vendor
else
  DIR=$MODPATH/system/vendor
fi
FILE=`find $DIR/etc -maxdepth 1 -type f -name $NAME`
if [ ! -d $ODM ] && [ "`realpath /odm/etc`" == /odm/etc ]\
&& [ "$FILE" ]; then
  for i in $FILE; do
    j="/odm$(echo $i | sed "s|$DIR||")"
    if [ -f $j ]; then
      umount $j
      mount -o bind $i $j
    fi
  done
fi
if [ ! -d $MY_PRODUCT ] && [ -d /my_product/etc ]\
&& [ "$FILE" ]; then
  for i in $FILE; do
    j="/my_product$(echo $i | sed "s|$DIR||")"
    if [ -f $j ]; then
      umount $j
      mount -o bind $i $j
    fi
  done
fi

# restart
PID=`pidof audioserver`
if [ "$PID" ]; then
  killall audioserver
fi

# wait
sleep 40

# allow
PKG=com.dolby.daxservice
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi
killall $PKG

# allow
PKG=com.dolby.dax2appUI
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi
killall $PKG


