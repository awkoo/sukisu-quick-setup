#!/usr/bin/bash

## BEGIN CONFIG SECTION

# SukiSU Config
SUKISU_REPO="ShirkNeko/SukiSU-Ultra"
BRANCH="susfs-dev"
COMMIT=""

# Should we add zakosu hash as well?
APPLY_ZAKO_HASH="yes"

# susfs4ksu branch name
SUSFS_BRANCH="gki-android13-5.15"

# Should we remove '-dirty' kernel name?
REMOVE_DIRTY="yes"

# Add a custom kernel suffix
CUSTOM_KERNEL_SUFFIX="zako"

# If you'd like a custom kernel name, specify it here
# This will override above name settings.
CUSTOM_KERNEL_NAME=""

# Should we apply susfs duplicate definition fix?
SUSFS_DUPLICATE_DEF_FIX="yes"

# Should we apply hide patch?
APPLY_EXTRA_HIDE_PATCH="yes"

## END CONFIG SECTION

SELF_DIR=$(realpath $(dirname $0))

function check-exec() {
    if ! which $1 &> /dev/null; then
        log "missing $1! abort!"
        exit 1
    fi
}

function log() {
    echo "[$(basename $0)] $@"
}

check-exec curl
check-exec git
check-exec jq

log "setting up $SUKISU_REPO"

curl -LSs "https://raw.githubusercontent.com/$SUKISU_REPO/main/kernel/setup.sh" | bash -s $BRANCH

if ! [ $? -eq 0 ]; then
    log "setup failed ($?)!"
    exit 1
fi


cd KernelSU
log "enter KernelSU directory"
if ! [ "$COMMIT" = "" ]; then
    log "using commit $COMMIT"
    git reset --hard $COMMIT
fi


if [ "$APPLY_ZAKO_HASH" = "yes" ]; then
    log "adding zakosu manager"
    patch -p1 < $SELF_DIR/01-add-zakosu-manager.patch
fi

if [ "$SUSFS_DUPLICATE_DEF_FIX" = "yes" ]; then
    log "applying susfs duplicate definition fix"
    patch -p1 < $SELF_DIR/03-fix-susfs-duplicate-definition.patch
fi

cd ..

log "downloading patch_linux..."
$SELF_DIR/download_patch_linux.sh

log "adding CONFIG_KPM=y"
log "CONFIG_KPM=y" >> arch/arm64/configs/gki_defconfig

log "adding auto kpm patch"
if [ -f "$SELF_DIR/patch_kpm.sh" ]; then
    patch -p1 < $SELF_DIR/02-add-auto-kpm-patch.patch
else
    log "error! patch_kpm.sh not found!"
    exit 1
fi

log "adding susfs4ksu"
if [ -f "$SELF_DIR/patch_susfs.sh" ]; then
    $SELF_DIR/patch_susfs.sh $SUSFS_BRANCH
else
    log "error! patch_susfs.sh not found!"
    exit 1
fi

log "applying custom kernel name settings"
if [ "$REMOVE_DIRTY" = "yes" ]; then
    sed -i -e "s/printf '%s' -dirty/:/g" scripts/setlocalversion
fi


if ! [ "$CUSTOM_KERNEL_SUFFIX" = "" ]; then
    sed -i -e "s/log \"\$res\"/log \"\$res-$CUSTOM_KERNEL_SUFFIX\"/g" scripts/setlocalversion
fi

if ! [ "$CUSTOM_KERNEL_NAME" = "" ]; then
    : > scripts/setlocalversion # :> owo
    log "#!/bin/sh" >> scripts/setlocalversion
    log "log '$CUSTOM_KERNEL_NAME'" >> scripts/setlocalversion
fi

if [ "$APPLY_EXTRA_HIDE_PATCH" = "yes" ]; then
    log "applying extra hide stuff"
    patch -p1 < $SELF_DIR/SukiSU_patch/69_hide_stuff.patch
fi

log "setup done"

