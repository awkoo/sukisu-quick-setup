#!/usr/bin/bash

SUSFS=susfs4ksu

SELF_DIR=$(git -C $(dirname $0) rev-parse --show-toplevel)

function log() {
    echo "[patch-susfs.sh] $@"
}

if ! [ -d "susfs4ksu" ]; then
    git submodule add -b $SUSFS_BRANCH https://gitlab.com/simonpunk/susfs4ksu.git
fi

log "Updating all submodules..."
git submodule update --init --recursive susfs4ksu

log "Updating all susfs4ksu kernel part files..."
cp $SUSFS/kernel_patches/fs/* fs/
cp $SUSFS/kernel_patches/include/linux/* include/linux/

log "Appling susfs4ksu patches..."
patch -p1 < "$SUSFS/kernel_patches/50_add_susfs_in_$SUSFS_BRANCH.patch"

log "Done!"
