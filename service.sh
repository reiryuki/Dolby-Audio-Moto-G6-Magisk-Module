(

MODPATH=${0%/*}
AML=/data/adb/modules/aml

# debug
exec 2>$MODPATH/debug.log
set -x

# prevent soft reboot
echo 0 > /proc/sys/kernel/panic
echo 0 > /proc/sys/kernel/panic_on_oops
echo 0 > /proc/sys/kernel/panic_on_rcu_stall
echo 0 > /proc/sys/kernel/panic_on_warn
echo 0 > /proc/sys/vm/panic_on_oom

# property
resetprop ro.product.brand motorola
resetprop ro.product.device ali
resetprop ro.product.manufacturer motorola
resetprop ro.product.model "moto g(6)"
resetprop audio.dolby.ds2.enabled true
resetprop audio.dolby.ds2.hardbypass true
resetprop vendor.audio.dolby.ds2.enabled true
resetprop vendor.audio.dolby.ds2.hardbypass true

# stop
NAME=dms-hal-2-0
if getprop | grep "init.svc.$NAME\]: \[running"; then
  stop $NAME
fi

# function
run_service() {
if getprop | grep "init.svc.$NAME\]: \[stopped"; then
  start $NAME
fi
PID=`pidof $FILE`
if [ ! "$PID" ]; then
  $FILE &
fi
PID=`pidof $FILE`
resetprop init.svc.$NAME running
resetprop init.svc_debug_pid.$NAME "$PID"
}

# run
NAME=dms-hal-1-0
FILE=/vendor/bin/hw/vendor.dolby.hardware.dms@1.0-service
run_service

# wait
sleep 20

# mount
NAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
if [ ! -d $AML ] || [ -f $AML/disable ]; then
  DIR=$MODPATH/system/vendor
else
  DIR=$AML/system/vendor
fi
FILE=`find $DIR/odm/etc -maxdepth 1 -type f -name $NAME`
if [ "`realpath /odm/etc`" != /vendor/odm/etc ] && [ "$FILE" ]; then
  for i in $FILE; do
    j="$(echo $i | sed "s|$DIR||")"
    umount $j
    mount -o bind $i $j
  done
fi
if [ ! -d $AML ] || [ -f $AML/disable ]; then
  DIR=$MODPATH/system
else
  DIR=$AML/system
fi
FILE=`find $DIR/etc -maxdepth 1 -type f -name $NAME`
if [ -d /my_product/etc ] && [ "$FILE" ]; then
  for i in $FILE; do
    j="$(echo $i | sed "s|$DIR||")"
    umount /my_product$j
    mount -o bind $i /my_product$j
  done
fi

# restart
killall audioserver

# wait
sleep 40

# oom
PKG=com.dolby.daxservice
PID=`pidof $PKG`
if [ $PID ]; then
  echo -17 > /proc/$PID/oom_adj
  echo -1000 > /proc/$PID/oom_score_adj
fi

) 2>/dev/null


