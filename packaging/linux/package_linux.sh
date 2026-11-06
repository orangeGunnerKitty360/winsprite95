#!/bin/sh


out=$(pwd)
src=$(pwd)
APP="WinSprite95"
APPDIR="WinSprite95.AppDir"
ARCH="$(uname -m)"

chmod +x winsprite95

mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib"

cp ../../desktop/libresprite.desktop "$APPDIR/winsprite95.desktop"
cp ../../desktop/icons/hicolor/256x256/apps/libresprite.png "$APPDIR/winsprite95.png"

mv ./*.so* "$APPDIR/usr/lib" 2>/dev/null || true

# Create AppImage with lib4bin and Sharun
(
export ARCH="$(uname -m)" # Just to be double sure
cd "$APPDIR"
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
mv "$out/data" "$out/$APPDIR/bin"

wget "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$ARCH.AppImage" -O appimagetool
chmod +x ./appimagetool
./appimagetool --comp zstd \
	--mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 \
	-n "$out/$APPDIR" "$out/$APP-anylinux-$ARCH.AppImage"
