mount -o rw,remount /data
MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`
AML=/data/adb/modules/aml
ACDB=/data/adb/modules/acdb

# debug
exec 2>$MODPATH/debug-pfsd.log
set -x

# run
FILE=$MODPATH/sepolicy.sh
if [ -f $FILE ]; then
  . $FILE
fi

# context
chcon -R u:object_r:system_lib_file:s0 $MODPATH/system/lib*
chcon -R u:object_r:vendor_file:s0 $MODPATH/system/vendor
chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/etc
chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/odm/etc
chcon u:object_r:same_process_hal_file:s0 $MODPATH/system/vendor/lib*/libhidltransport.so
chcon u:object_r:same_process_hal_file:s0 $MODPATH/system/vendor/lib*/libhwbinder.so
chcon u:object_r:same_process_hal_file:s0 $MODPATH/system/vendor/lib*/libhidlbase.so
chcon u:object_r:hal_dms_default_exec:s0 $MODPATH/system/vendor/bin/hw/vendor.dolby.hardware.dms@*-service
chcon u:object_r:hal_dms_default_exec:s0 $MODPATH/system/vendor/odm/bin/hw/vendor.dolby_v3_6.hardware.dms360@2.0-service

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
ETC=$SYSTEM/etc
VETC=$VENDOR/etc
VOETC=$VENDOR/odm/etc
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
VAE=`find $VETC /odm/etc /my_product/etc -maxdepth 1 -type f -name $NAME2`
AP=`find $ETC -maxdepth 1 -type f -name $NAME3`
VAP=`find $VETC /odm/etc /my_product/etc -maxdepth 1 -type f -name $NAME3`
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
rm -f `find $MODPATH/system -type f -name *policy*volume*.xml -o -name *audio*effects*spatializer*.xml`

# run
. $MODPATH/.aml.sh

# directory
DIR=/data/vendor/media
if [ ! -d $DIR ]; then
  mkdir -p $DIR
fi
chmod 0770 $DIR
chown 1046.1013 $DIR
chcon u:object_r:vendor_media_data_file:s0 $DIR

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  rm -f $FILE
fi

# patch manifest
if [ "$API" -ge 28 ]; then
  M=$ETC/vintf/manifest.xml
  MODM=$MODETC/vintf/manifest.xml
  FILE="$MAGISKTMP/mirror/*/etc/vintf/manifest.xml
        $MAGISKTMP/mirror/*/*/etc/vintf/manifest.xml
        /*/etc/vintf/manifest.xml /*/*/etc/vintf/manifest.xml
        $MAGISKTMP/mirror/*/etc/vintf/manifest/*.xml
        $MAGISKTMP/mirror/*/*/etc/vintf/manifest/*.xml
        /*/etc/vintf/manifest/*.xml /*/*/etc/vintf/manifest/*.xml"
else
  M=$MAGISKTMP/mirror/system/manifest.xml
  MODM=$MODPATH/system/manifest.xml
  FILE="$MAGISKTMP/mirror/*/manifest.xml
        $MAGISKTMP/mirror/*/*/manifest.xml
        /*/manifest.xml /*/*/manifest.xml"
fi
rm -f $MODM
if ! grep -A2 vendor.dolby.hardware.dms $FILE | grep 1.0; then
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
    if [ "$API" -ge 28 ]; then
      mount -o bind $MODM /system/etc/vintf/manifest.xml
    else
      mount -o bind $MODM /system/manifest.xml
    fi
    killall hwservicemanager
  fi
fi


