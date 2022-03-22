PKG="com.motorola.motosignature.app
     com.dolby.dax2appUI
     com.dolby.daxservice"
for PKGS in $PKG; do
  rm -rf /data/user/*/$PKGS/cache/*
done


