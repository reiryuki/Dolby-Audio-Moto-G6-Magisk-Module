(

mount /data
mount -o rw,remount /data
MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`
AML=/data/adb/modules/aml
ACDB=/data/adb/modules/acdb

# debug
magiskpolicy --live "dontaudit system_server system_file file write"
magiskpolicy --live "allow     system_server system_file file write"
exec 2>$MODPATH/debug-pfsd.log
set -x

# run
FILE=$MODPATH/sepolicy.sh
if [ -f $FILE ]; then
  sh $FILE
fi

# etc
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
fi
ETC="/my_product/etc $MAGISKTMP/mirror/system/etc"
VETC=$MAGISKTMP/mirror/system/vendor/etc
VOETC="/odm/etc $MAGISKTMP/mirror/system/vendor/odm/etc"
MODETC=$MODPATH/system/etc
MODVETC=$MODPATH/system/vendor/etc
MODVOETC=$MODPATH/system/vendor/odm/etc

# conflict
if [ -d $AML ] && [ ! -f $AML/disable ]\
&& [ -d $ACDB ] && [ ! -f $ACDB/disable ]; then
  touch $ACDB/disable
fi
rm -f /data/adb/modules/*/system/app/MotoSignatureApp/.replace

# directory
SKU=`ls $VETC/audio | grep sku_`
if [ "$SKU" ]; then
  for SKUS in $SKU; do
    mkdir -p $MODVETC/audio/$SKUS
  done
fi
PROP=`getprop ro.build.product`
if [ -d $VETC/audio/"$PROP" ]; then
  mkdir -p $MODVETC/audio/"$PROP"
fi

# audio files
NAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
NAME2="*audio*effects*.conf -o -name *audio*effects*.xml"
NAME3="*policy*.conf -o -name *policy*.xml"
rm -f `find $MODPATH/system -type f -name $NAME`
AE=`find $ETC -maxdepth 1 -type f -name $NAME2`
VAE=`find $VETC -maxdepth 1 -type f -name $NAME2`
AP=`find $ETC -maxdepth 1 -type f -name $NAME3`
VAP=`find $VETC -maxdepth 1 -type f -name $NAME3`
VOA=`find $VOETC -maxdepth 1 -type f -name $NAME`
VAA=`find $VETC/audio -maxdepth 1 -type f -name $NAME`
VBA=`find $VETC/audio/"$PROP" -maxdepth 1 -type f -name $NAME`
if [ ! -d $ACDB ] || [ -f $ACDB/disable ]; then
  if [ "$AE" ]; then
    cp -f $AE $MODETC
  fi
  if [ "$VAE" ]; then
    cp -f $VAE $MODVETC
  fi
fi
if [ "$AP" ]; then
  cp -f $AP $MODETC
fi
if [ "$VAP" ]; then
  cp -f $VAP $MODVETC
fi
if [ "$VOA" ]; then
  cp -f $VOA $MODVOETC
fi
if [ "$VAA" ]; then
  cp -f $VAA $MODVETC/audio
fi
if [ "$VBA" ]; then
  cp -f $VBA $MODVETC/audio/"$PROP"
fi
if [ "$SKU" ]; then
  for SKUS in $SKU; do
    VSA=`find $VETC/audio/$SKUS -maxdepth 1 -type f -name $NAME`
    if [ "$VSA" ]; then
      cp -f $VSA $MODVETC/audio/$SKUS
    fi
  done
fi

# aml fix
DIR=$AML/system/vendor/odm/etc
if [ "$VOA" ] && [ -d $AML ] && [ ! -f $AML/disable ] && [ ! -d $DIR ]; then
  mkdir -p $DIR
  cp -f $VOA $DIR
fi
magiskpolicy --live "dontaudit vendor_configs_file labeledfs filesystem associate"
magiskpolicy --live "allow     vendor_configs_file labeledfs filesystem associate"
magiskpolicy --live "dontaudit init vendor_configs_file dir relabelfrom"
magiskpolicy --live "allow     init vendor_configs_file dir relabelfrom"
magiskpolicy --live "dontaudit init vendor_configs_file file relabelfrom"
magiskpolicy --live "allow     init vendor_configs_file file relabelfrom"
chcon -R u:object_r:vendor_configs_file:s0 $DIR

# run
sh $MODPATH/.aml.sh

# directory
DIR=/data/vendor/media
if [ ! -d $DIR ]; then
  mkdir -p $DIR
fi
chmod 0770 $DIR
chown 1046.1013 $DIR
magiskpolicy --live "dontaudit vendor_media_data_file labeledfs filesystem associate"
magiskpolicy --live "allow     vendor_media_data_file labeledfs filesystem associate"
magiskpolicy --live "dontaudit init vendor_media_data_file dir relabelfrom"
magiskpolicy --live "allow     init vendor_media_data_file dir relabelfrom"
magiskpolicy --live "dontaudit init vendor_media_data_file file relabelfrom"
magiskpolicy --live "allow     init vendor_media_data_file file relabelfrom"
chcon u:object_r:vendor_media_data_file:s0 $DIR

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  sh $FILE
  rm -f $FILE
fi

# patch manifest
NAME=manifest.xml
if [ "$API" -ge 28 ]; then
  M=$ETC/vintf/$NAME
  MODM=$MODETC/vintf/$NAME
  CHECK=@1.0::IDms/default
else
  M=$MAGISKTMP/mirror/system/$NAME
  MODM=$MODPATH/system/$NAME
  CHECK=vendor.dolby.hardware.dms
fi
rm -f $MODM
if [ "$API" -ge 28 ]; then
  if ! grep -r "$CHECK" $MAGISKTMP/mirror/*/etc/vintf\
  && ! grep -r "$CHECK" $MAGISKTMP/mirror/*/*/etc/vintf\
  && ! grep -r "$CHECK" /*/etc/vintf\
  && ! grep -r "$CHECK" /*/*/etc/vintf; then
    cp -f $M $MODM
    if [ -f $MODM ]; then
      sed -i '/<manifest/a\
    <hal format="hidl">\
        <name>vendor.dolby.hardware.dms</name>\
        <transport>hwbinder</transport>\
        <version>1.0</version>\
        <interface>\
            <name>IDms</name>\
            <instance>default</instance>\
        </interface>\
        <fqname>@1.0::IDms/default</fqname>\
    </hal>' $MODM
      mount -o bind $MODM /system/etc/vintf/$NAME
      killall hwservicemanager
    fi
  fi
else
  if ! grep "$CHECK" $MAGISKTMP/mirror/*/$NAME\
  && ! grep "$CHECK" $MAGISKTMP/mirror/*/*/$NAME\
  && ! grep "$CHECK" /*/$NAME\
  && ! grep "$CHECK" /*/*/$NAME; then
    cp -f $M $MODM
    if [ -f $MODM ]; then
      sed -i '/<manifest/a\
    <hal format="hidl">\
        <name>vendor.dolby.hardware.dms</name>\
        <transport>hwbinder</transport>\
        <version>1.0</version>\
        <interface>\
            <name>IDms</name>\
            <instance>default</instance>\
        </interface>\
    </hal>' $MODM
      mount -o bind $MODM /system/$NAME
      killall hwservicemanager
    fi
  fi
fi

) 2>/dev/null


