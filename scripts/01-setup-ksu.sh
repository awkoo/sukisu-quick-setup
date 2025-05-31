#!/usr/bin/bash

SELF_DIR=$(git -C $(dirname $0) rev-parse --show-toplevel)

function log() {
    echo "[setup-ksu.sh] $@"
}

if ! [ -d KernelSU ]; then
    log "KernelSU not found! Adding KSU as submodule..."
    git submodule add https://github.com/$SUKISU_REPO.git KernelSU
fi

cd KernelSU

log "Resetting workspace..."
git reset --hard
git clean -f -d
git checkout $SUKISU_BRANCH
git pull

if ! [ "$COMMIT" = "" ]; then
    log "Using commit $COMMIT"
    git reset --hard $COMMIT
fi

if [ "$APPLY_ZAKO_HASH" = "yes" ]; then
    log "Adding zakosu manager"
    patch -p1 < $SELF_DIR/patches/01-add-zakosu-manager.patch
fi

if [ "$SUSFS_DUPLICATE_DEF_FIX" = "yes" ]; then
    log "Applying susfs duplicate definition fix"
    patch -p1 < $SELF_DIR/patches/03-fix-susfs-duplicate-definition.patch
fi

cd ..

log "Creating symlink..."
ln -sf ../KernelSU/kernel drivers/kernelsu

if ! grep -q "kernelsu" drivers/Makefile; then
    log "Adding kernelsu driver..."
    echo "obj-\$(CONFIG_KSU) += kernelsu" >> drivers/Makefile
fi

if ! grep -q "kernelsu" Kconfig; then
    log "Adding kernelsu Kconfig entry..."
    sed -i '/menu "Device Drivers"/a source "drivers/kernelsu/Kconfig"' drivers/Kconfig
fi

log "Done!"

