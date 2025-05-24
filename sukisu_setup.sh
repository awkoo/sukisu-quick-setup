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

## END CONFIG SECTION

SELF_DIR=$(realpath $(dirname $0))

function check-exec() {
    if ! which $1 &> /dev/null; then
        echo "missing $1! abort!"
        exit 1
    fi
}

check-exec curl
check-exec git
check-exec jq

echo "setting up $SUKISU_REPO"

curl -LSs "https://raw.githubusercontent.com/$SUKISU_REPO/main/kernel/setup.sh" | bash -s $BRANCH

if ! [ $? -eq 0 ]; then
    echo "setup failed ($?)!"
    exit 1
fi


cd KernelSU
echo "enter KernelSU directory"
if ! [ "$COMMIT" = "" ]; then
    echo "using commit $COMMIT"
    git reset --hard $COMMIT
fi


if [ "$APPLY_ZAKO_HASH" = "yes" ]; then
    echo "adding zakosu manager"
    patch -p1 < $SELF_DIR/01-add-zakosu-manager.patch
fi

if [ "$SUSFS_DUPLICATE_DEF_FIX" = "yes" ]; then
    echo "applying susfs duplicate definition fix"
    patch -p1 < $SELF_DIR/03-fix-susfs-duplicate-definition.patch
fi

cd ..

echo "downloading patch_linux..."
$SELF_DIR/download_patch_linux.sh

echo "adding CONFIG_KPM=y"
echo "CONFIG_KPM=y" >> arch/arm64/configs/gki_defconfig

echo "adding auto kpm patch"
if [ -f "$SELF_DIR/patch_kpm.sh" ]; then
    patch -p1 < $SELF_DIR/02-add-auto-kpm-patch.patch
else
    echo "error! patch_kpm.sh not found!"
    exit 1
fi

echo "adding susfs4ksu"
if [ -f "$SELF_DIR/patch_susfs.sh" ]; then
    $SELF_DIR/patch_susfs.sh $SUSFS_BRANCH
else
    echo "error! patch_susfs.sh not found!"
    exit 1
fi

echo "applying custom kernel name settings"
if [ "$REMOVE_DIRTY" = "yes" ]; then
    sed -i -e "s/printf '%s' -dirty/:/g" scripts/setlocalversion
fi


if ! [ "$CUSTOM_KERNEL_SUFFIX" = "" ]; then
    sed -i -e "s/echo \"\$res\"/echo \"\$res-$CUSTOM_KERNEL_SUFFIX\"/g" scripts/setlocalversion
fi

if ! [ "$CUSTOM_KERNEL_NAME" = "" ]; then
    : > scripts/setlocalversion # :> owo
    echo "#!/bin/sh" >> scripts/setlocalversion
    echo "echo '$CUSTOM_KERNEL_NAME'" >> scripts/setlocalversion
fi

echo "setup done"

