MODPATH=${0%/*}

# destinations
MODAEC=`find $MODPATH/system -type f -name *audio*effects*.conf`
MODAEX=`find $MODPATH/system -type f -name *audio*effects*.xml`
MODAP=`find $MODPATH/system -type f -name *policy*.conf -o -name *policy*.xml`
LIBPATH="\/vendor\/lib\/soundfx"

# function
remove_conf() {
  for RMVS in $RMV; do
    sed -i "s/$RMVS/removed/g" $MODAEC
  done
  sed -i 's/    path \/vendor\/lib\/soundfx\/removed//g' $MODAEC
  sed -i 's/    path \/system\/lib\/soundfx\/removed//g' $MODAEC
  sed -i 's/    path \/vendor\/lib\/removed//g' $MODAEC
  sed -i 's/    path \/system\/lib\/removed//g' $MODAEC
  sed -i "/^        removed {/ {;N s/        removed {\n        }//}" $MODAEC
}
remove_xml() {
  for RMVS in $RMV; do
    sed -i "s/\"$RMVS\"/\"removed\"/g" $MODAEX
  done
  sed -i 's/<library name="removed" path="removed"\/>//g' $MODAEX
  sed -i 's/<effect name="removed" library="removed" uuid="removed"\/>//g' $MODAEX
  sed -i 's/<apply effect="removed"\/>//g' $MODAEX
}

# store
LIB=libswdap.so
NAME=dap
UUID=9d4921da-8225-4f29-aefa-39537a04bcaa
RMV="$LIB $NAME $UUID"
#2RMV2="libdiraceffect.so dirac_gef 3799D6D1-22C5-43C3-B3EC-D664CF8D2F0D
#2      libdirac.so dirac_controller dirac_music b437f4de-da28-449b-9673-667f8b964304 b437f4de-da28-449b-9673-667f8b9643fe
#2      dirac 1e069d9e0-8329-11df-9168-0002a5d5c51b"
#3RMV3="libmisoundfx.so misoundfx 5b8e36a5-144a-4c38-b1d7-0002a5d5c51b"

# patch audio effects conf
if [ "$MODAEC" ]; then
  #2for RMVS2 in $RMV2; do
  #2  sed -i "s/$RMVS2/removed/g" $MODAEC
  #2done
  #3for RMVS3 in $RMV3; do
  #3  sed -i "s/$RMVS3/removed/g" $MODAEC
  #3done
  remove_conf
  sed -i "/^libraries {/a\  $NAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library $NAME\n    uuid $UUID\n  }" $MODAEC
  sed -i "/^        ring_helper {/ {;N s/        ring_helper {\n        }//}" $MODAEC
  sed -i "/^        alarm_helper {/ {;N s/        alarm_helper {\n        }//}" $MODAEC
  sed -i "/^        music_helper {/ {;N s/        music_helper {\n        }//}" $MODAEC
  sed -i "/^        voice_helper {/ {;N s/        voice_helper {\n        }//}" $MODAEC
  sed -i "/^        notification_helper {/ {;N s/        notification_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_ring_helper {/ {;N s/        ma_ring_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_alarm_helper {/ {;N s/        ma_alarm_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_music_helper {/ {;N s/        ma_music_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_voice_helper {/ {;N s/        ma_voice_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_system_helper {/ {;N s/        ma_system_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_notification_helper {/ {;N s/        ma_notification_helper {\n        }//}" $MODAEC
  sed -i "/^        sa3d {/ {;N s/        sa3d {\n        }//}" $MODAEC
  sed -i "/^        fens {/ {;N s/        fens {\n        }//}" $MODAEC
  sed -i "/^        lmfv {/ {;N s/        lmfv {\n        }//}" $MODAEC
  sed -i "/^        dirac {/ {;N s/        dirac {\n        }//}" $MODAEC
  if ! grep -Eq '^output_session_processing {' $MODAEC; then
    sed -i -e '$a\
output_session_processing {\
    music {\
    }\
    ring {\
    }\
    alarm {\
    }\
    voice_call {\
    }\
    notification {\
    }\
}\' $MODAEC
  else
    if ! grep -Eq '^    notification {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    notification {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    voice_call {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    voice_call {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    alarm {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    alarm {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    ring {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    ring {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    music {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    music {\n    }" $MODAEC
    fi
  fi
#m  sed -i "/^    music {/a\        $NAME {\n        }" $MODAEC
#r  sed -i "/^    ring {/a\        $NAME {\n        }" $MODAEC
#a  sed -i "/^    alarm {/a\        $NAME {\n        }" $MODAEC
#v  sed -i "/^    voice_call {/a\        $NAME {\n        }" $MODAEC
#n  sed -i "/^    notification {/a\        $NAME {\n        }" $MODAEC
fi

# patch audio effects xml
if [ "$MODAEX" ]; then
  #2for RMVS2 in $RMV2; do
  #2  sed -i "s/\"$RMVS2\"/\"removed\"/g" $MODAEX
  #2done
  #3for RMVS3 in $RMV3; do
  #3  sed -i "s/\"$RMVS3\"/\"removed\"/g" $MODAEX
  #3done
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$NAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$NAME\" uuid=\"$UUID\"\/>" $MODAEX
  sed -i 's/<apply effect="ring_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="alarm_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="music_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="voice_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="notification_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_ring_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_alarm_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_music_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_voice_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_system_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_notification_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="sa3d"\/>//g' $MODAEX
  sed -i 's/<apply effect="fens"\/>//g' $MODAEX
  sed -i 's/<apply effect="lmfv"\/>//g' $MODAEX
  sed -i 's/<apply effect="dirac"\/>//g' $MODAEX
  if ! grep -Eq '<postprocess>' $MODAEX || grep -Eq '<!-- Audio post processor' $MODAEX; then
    sed -i '/<\/effects>/a\
    <postprocess>\
        <stream type="music">\
        <\/stream>\
        <stream type="ring">\
        <\/stream>\
        <stream type="alarm">\
        <\/stream>\
        <stream type="voice_call">\
        <\/stream>\
        <stream type="notification">\
        <\/stream>\
    <\/postprocess>' $MODAEX
  else
    if ! grep -Eq '<stream type="notification">' $MODAEX || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"notification\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="voice_call">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"voice_call\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="alarm">' $MODAEX || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"alarm\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="ring">' $MODAEX || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"ring\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="music">' $MODAEX || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"music\">\n        <\/stream>" $MODAEX
    fi
  fi
#m  sed -i "/<stream type=\"music\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#r  sed -i "/<stream type=\"ring\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#a  sed -i "/<stream type=\"alarm\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#v  sed -i "/<stream type=\"voice_call\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#n  sed -i "/<stream type=\"notification\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
fi

# patch audio policy
#uif [ "$MODAP" ]; then
#u  sed -i 's/RAW/NONE/g' $MODAP
#u  sed -i 's/,raw//g' $MODAP
#ufi


