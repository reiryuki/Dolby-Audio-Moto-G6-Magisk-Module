(

mount /data
mount -o rw,remount /data
MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

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
AML=/data/adb/modules/aml
ACDB=/data/adb/modules/acdb
if [ -d $AML ] && [ -d $ACDB ]; then
  rm -rf $ACDB
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

# audio effects
NAME=*audio*effects*
rm -f `find $MODPATH/system -type f -name $NAME.conf -o -name $NAME.xml`
if [ ! -d $ACDB ] || [ -f $ACDB/disable ]; then
  AE=`find $ETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
  VAE=`find $VETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
  VOAE=`find $VOETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
  cp -f $AE $MODETC
  cp -f $VAE $MODVETC
  cp -f $VOAE $MODVOETC
  if [ "$SKU" ]; then
    for SKUS in $SKU; do
      VSAE=`find $VETC/audio/$SKUS -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
      cp -f $VSAE $MODVETC/audio/$SKUS
    done
  fi
  if [ -d $VETC/audio/"$PROP" ]; then
    VBAE=`find $VETC/audio/"$PROP" -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
    cp -f $VBAE $MODVETC/audio/"$PROP"
  fi
fi

# audio policy
NAME=*policy*
rm -f `find $MODPATH/system -type f -name $NAME.conf -o -name $NAME.xml`
AP=`find $ETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
VAP=`find $VETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
VAAP=`find $VETC/audio -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
VOAP=`find $VOETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
cp -f $AP $MODETC
cp -f $VAP $MODVETC
cp -f $VAAP $MODVETC/audio
cp -f $VOAP $MODVOETC
if [ "$SKU" ]; then
  for SKUS in $SKU; do
    VSAP=`find $VETC/audio/$SKUS -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
    cp -f $VSAP $MODVETC/audio/$SKUS
  done
fi
if [ -d $VETC/audio/"$PROP" ]; then
  VBAP=`find $VETC/audio/"$PROP" -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
  cp -f $VBAP $MODVETC/audio/"$PROP"
fi

# aml fix
DIR=$AML/system/vendor/odm/etc
if [ "$VOAE" ] || [ "$VOAP" ]; then
  if [ -d $AML ] && [ ! -d $DIR ]; then
    mkdir -p $DIR
    cp -f $VOAE $DIR
    cp -f $VOAP $DIR
  fi
fi
magiskpolicy "dontaudit vendor_configs_file labeledfs filesystem associate"
magiskpolicy "allow     vendor_configs_file labeledfs filesystem associate"
magiskpolicy "dontaudit init vendor_configs_file dir relabelfrom"
magiskpolicy "allow     init vendor_configs_file dir relabelfrom"
magiskpolicy "dontaudit init vendor_configs_file file relabelfrom"
magiskpolicy "allow     init vendor_configs_file file relabelfrom"
chcon -R u:object_r:vendor_configs_file:s0 $DIR
magiskpolicy --live "type vendor_configs_file"

# run
sh $MODPATH/.aml.sh

# directory
DIR=/data/vendor/media
if [ ! -d $DIR ]; then
  mkdir -p $DIR
fi
chmod 0770 $DIR
chown 1046.1013 $DIR
magiskpolicy "dontaudit vendor_media_data_file labeledfs filesystem associate"
magiskpolicy "allow     vendor_media_data_file labeledfs filesystem associate"
magiskpolicy "dontaudit init vendor_media_data_file dir relabelfrom"
magiskpolicy "allow     init vendor_media_data_file dir relabelfrom"
magiskpolicy "dontaudit init vendor_media_data_file file relabelfrom"
magiskpolicy "allow     init vendor_media_data_file file relabelfrom"
chcon u:object_r:vendor_media_data_file:s0 $DIR
magiskpolicy --live "type vendor_media_data_file"

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
  if ! grep -rEq "$CHECK" $MAGISKTMP/mirror/*/etc/vintf\
  && ! grep -rEq "$CHECK" $MAGISKTMP/mirror/*/*/etc/vintf\
  && ! grep -rEq "$CHECK" /*/etc/vintf\
  && ! grep -rEq "$CHECK" /*/*/etc/vintf; then
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
  if ! grep -Eq "$CHECK" $MAGISKTMP/mirror/*/$NAME\
  && ! grep -Eq "$CHECK" $MAGISKTMP/mirror/*/*/$NAME\
  && ! grep -Eq "$CHECK" /*/$NAME\
  && ! grep -Eq "$CHECK" /*/*/$NAME; then
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


