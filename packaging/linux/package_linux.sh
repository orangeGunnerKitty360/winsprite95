#!/bin/sh


out=$(pwd)
src=$(pwd)
APP="WinSprite95"
ARCH="$(uname -m)"

chmod +x winsprite95

mkdir -p WinSprite95/usr/bin

mv ../../desktop/libresprite.desktop WinSprite95/winsprite95.desktop
cp ../../desktop/icons/hicolor/256x256/apps/libresprite.png WinSprite95/winsprite95.png

mv *.so* WinSprite95/usr/lib

# Create AppImage with lib4bin and Sharun
(
export ARCH="$(uname -m)" # Just to be double sure
cd WinSprite95
wget "https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin" -O ./lib4bin
chmod +x ./lib4bin
xvfb-run -a -- ./lib4bin -p -v -e -k -w \
  ../winsprite95 \
  /usr/lib/libpthread.so* \
  /usr/lib/librt.so* \
  /usr/lib/libstdc++.so* 
ln ./sharun ./AppRun 
./sharun -g
)

# Maybe the data folder is being read during initial run
# This lets the run complete with expected original locations and then
# copies it over afterwards using the below command
mv "$out"/data "$out"/WinSprite95/bin

wget "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$ARCH.AppImage" -O appimagetool
chmod +x ./appimagetool
./appimagetool --comp zstd \
	--mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 \
	-n "$out"/WinSprite95 "$out"/"$APP"-anylinux-"$ARCH".AppImage
