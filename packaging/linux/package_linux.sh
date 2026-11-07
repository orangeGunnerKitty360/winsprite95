#!/bin/sh

set -eu

out=$(pwd)
APP="WinSprite95"
APPDIR="$out/../WinSprite95.AppDir"
ARCH="$(uname -m)"

chmod +x winsprite95

mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib"

cp ../../desktop/libresprite.desktop "$APPDIR/winsprite95.desktop"
cp ../../desktop/icons/hicolor/256x256/apps/libresprite.png "$APPDIR/winsprite95.png"

mv ./*.so* "$APPDIR/usr/lib" 2>/dev/null || true

# Create AppImage with lib4bin and Sharun. Keep the helper outside the AppDir
# so it cannot recursively discover the directory that it is constructing.
LIB4BIN="$(mktemp)"
wget "https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin" -O "$LIB4BIN"
chmod +x "$LIB4BIN"
xvfb-run -a -- "$LIB4BIN" -d "$APPDIR" -p -v -e -k -w \
  "$out/winsprite95" \
  /usr/lib/libpthread.so* \
  /usr/lib/librt.so* \
  /usr/lib/libstdc++.so* 
test -x "$APPDIR/sharun"
ln "$APPDIR/sharun" "$APPDIR/AppRun"
"$APPDIR/sharun" -g

# Maybe the data folder is being read during initial run
# This lets the run complete with expected original locations and then
# copies it over afterwards using the below command
mv "$out/data" "$APPDIR/bin"

wget "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$ARCH.AppImage" -O appimagetool
chmod +x ./appimagetool
./appimagetool --comp zstd \
	--mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 \
	-n "$APPDIR" "$out/$APP-anylinux-$ARCH.AppImage"
