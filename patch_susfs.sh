#!/usr/bin/bash

SUSFS=susfs4ksu

SELF=$(basename $0)

if [ "$1" = "" ]; then
    echo "$0: error! no susfs branch specified!"
    exit 1
fi

if ! [ -d "susfs4ksu" ]; then
    git submodule add -b $1 https://gitlab.com/simonpunk/susfs4ksu.git
fi
echo "$SELF: update submodules"
git submodule update --init --recursive

echo "$SELF: update susfs files"
cp "$SUSFS/kernel_patches/50_add_susfs_in_$1.patch" .
cp $SUSFS/kernel_patches/fs/* fs/
cp $SUSFS/kernel_patches/include/linux/* include/linux/

echo "$SELF: apply susfs patch"
patch -p1 < "50_add_susfs_in_$1.patch"

echo "$SELF: done"
