#!/usr/bin/bash

SELF_DIR=$(dirname $0)

if ! [ -f "$SELF_DIR/patch_linux" ]; then
    echo "patch_linux not found! abort!"
    exit 1
fi

cp "$SELF_DIR/patch_linux" .
chmod +x ./patch_linux

if ! [ -f "$1" ]; then
    echo "no input! abort!"
    exit 1
fi

FILENAME=$(basename "$1")
if [ "$FILENAME" = "Image" ]; then
    mv $1 ./Image
else
    echo "wrong file! expected 'Image' but got '$FILENAME'. abort!"
    exit 1
fi

./patch_linux

if ! [ -f "oImage" ]; then
    echo "patch failed!"
    exit 1
fi

mv ./oImage $1

echo "KPM patch done"
