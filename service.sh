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

# restart
killall audioserver

# function
stop_service() {
if getprop | grep "init.svc.$NAME\]: \[running"; then
  stop $NAME
fi
}
run_service() {
killall $FILE
$FILE &
PID=`pidof $FILE`
}

# stop
NAME=dms-hal-1-0
stop_service
NAME=dms-hal-2-0
stop_service
NAME=dms-v36-hal-2-0
stop_service

# run
FILE=`realpath /vendor`/bin/hw/vendor.dolby.hardware.dms@1.0-service
run_service

# wait
sleep 20

# aml fix
DIR=$AML/system/vendor/odm/etc
if [ -d $DIR ] && [ ! -f $AML/disable ]; then
  chcon -R u:object_r:vendor_configs_file:s0 $DIR
fi

# mount
NAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
if [ ! -d $AML ] || [ -f $AML/disable ]; then
  DIR=$MODPATH/system/vendor
else
  DIR=$AML/system/vendor
fi
FILE=`find $DIR/etc -maxdepth 1 -type f -name $NAME`
if [ `realpath /odm/etc` == /odm/etc ] && [ "$FILE" ]; then
  for i in $FILE; do
    j="/odm$(echo $i | sed "s|$DIR||")"
    if [ -f $j ]; then
      umount $j
      mount -o bind $i $j
    fi
  done
fi
if [ -d /my_product/etc ] && [ "$FILE" ]; then
  for i in $FILE; do
    j="/my_product$(echo $i | sed "s|$DIR||")"
    if [ -f $j ]; then
      umount $j
      mount -o bind $i $j
    fi
  done
fi
if ( [ `realpath /odm/etc` == /odm/etc ] && [ "$FILE" ] )\
|| ( [ -d /my_product/etc ] && [ "$FILE" ] ); then
  killall audioserver
  FILE=`realpath /vendor`/bin/hw/vendor.dolby.hardware.dms@1.0-service
  run_service
fi

# wait
sleep 40

# allow
PKG=com.dolby.dax2appUI
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

# allow
PKG=com.dolby.daxservice
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi


