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
  sh $FILE
fi

# etc
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
fi
ETC=$MAGISKTMP/mirror/system/etc
VETC=$MAGISKTMP/mirror/system/vendor/etc
VOETC=$MAGISKTMP/mirror/system/vendor/odm/etc
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

# run
sh $MODPATH/.aml.sh

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
  sh $FILE
  rm -f $FILE
fi

# patch manifest
NAME=manifest.xml
if [ "$API" -ge 28 ]; then
  M=$ETC/vintf/$NAME
  MODM=$MODETC/vintf/$NAME
  FILE=`find $MAGISKTMP/mirror/*/etc/vintf\
             $MAGISKTMP/mirror/*/*/etc/vintf\
             /*/etc/vintf /*/*/etc/vintf -type f -name *.xml`
else
  M=$MAGISKTMP/mirror/system/$NAME
  MODM=$MODPATH/system/$NAME
  FILE="$MAGISKTMP/mirror/*/$NAME
        $MAGISKTMP/mirror/*/*/$NAME
        /*/$NAME /*/*/$NAME"
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
      mount -o bind $MODM /system/etc/vintf/$NAME
    else
      mount -o bind $MODM /system/$NAME
    fi
    killall hwservicemanager
  fi
fi

# AudioEffectCenter
if [ -f /my_product/app/AudioEffectCenter/AudioEffectCenter.apk ]; then
  mkdir $MODPATH/AudioEffectCenter
  mount -o bind $MODPATH/AudioEffectCenter /my_product/app/AudioEffectCenter
fi
if [ -f /my_product/priv-app/AudioEffectCenter/AudioEffectCenter.apk ]; then
  mkdir $MODPATH/AudioEffectCenter
  mount -o bind $MODPATH/AudioEffectCenter /my_product/priv-app/AudioEffectCenter
fi


