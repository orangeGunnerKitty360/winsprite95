#!/bin/sh

set -eu

out=$(pwd)
APP="WinSprite95"
APPDIR="$out/../WinSprite95.AppDir"
ARCH="$(uname -m)"

chmod +x winsprite95

mkdir -p "$APPDIR/usr/bin"

cp winsprite95 "$APPDIR/usr/bin/winsprite95"
cp -R data "$APPDIR/usr/bin/data"
cp ../../desktop/libresprite.desktop "$APPDIR/winsprite95.desktop"
cp ../../desktop/icons/hicolor/256x256/apps/libresprite.png "$APPDIR/winsprite95.png"

LINUXDEPLOY="$(mktemp)"
wget "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$ARCH.AppImage" -O "$LINUXDEPLOY"
chmod +x "$LINUXDEPLOY"

OUTPUT="$out/$APP-anylinux-$ARCH.AppImage" "$LINUXDEPLOY" \
  --appdir "$APPDIR" \
  --executable "$APPDIR/usr/bin/winsprite95" \
  --desktop-file "$APPDIR/winsprite95.desktop" \
  --icon-file "$APPDIR/winsprite95.png" \
  --output appimage
