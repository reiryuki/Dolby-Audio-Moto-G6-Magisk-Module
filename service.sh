(

MODPATH=${0%/*}

resetprop ro.product.brand motorola
resetprop ro.product.device ali
resetprop ro.product.manufacturer motorola
resetprop ro.product.model "moto g(6)"
resetprop audio.dolby.ds2.enabled true
resetprop audio.dolby.ds2.hardbypass true
resetprop vendor.audio.dolby.ds2.enabled true
resetprop vendor.audio.dolby.ds2.hardbypass true

killall audioserver

stop dms-hal-2-0
if ! getprop | grep -Eq init.svc.dms-hal-1-0; then
  /vendor/bin/hw/vendor.dolby.hardware.dms@1.0-service &
  PID=`pidof /vendor/bin/hw/vendor.dolby.hardware.dms@1.0-service`
  resetprop init.svc.dms-hal-1-0 running
  resetprop init.svc_debug_pid.dms-hal-1-0 $PID
else
  killall /vendor/bin/hw/vendor.dolby.hardware.dms@1.0-service
fi

sleep 60

PKG=com.dolby.daxservice
PID=`pidof $PKG`
if [ $PID ]; then
  echo -17 > /proc/$PID/oom_adj
  echo -1000 > /proc/$PID/oom_score_adj
fi

) 2>/dev/null


