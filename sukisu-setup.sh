#!/usr/bin/bash

## BEGIN CONFIG SECTION

# SukiSU Config
export SUKISU_REPO="ShirkNeko/SukiSU-Ultra"
export SUKISU_BRANCH="susfs-dev"
export SUKISU_COMMIT=""

# Should we add zakosu hash as well?
export APPLY_ZAKO_HASH="yes"

# susfs4ksu branch name
export SUSFS_BRANCH="gki-android13-5.15"

# Should we remove '-dirty' kernel name?
export REMOVE_DIRTY="yes"

# Override default kernel suffix
export CUSTOM_KERNEL_SUFFIX=""

# Should we apply susfs duplicate definition fix?
export SUSFS_DUPLICATE_DEF_FIX="yes"

# Should we apply hide patch?
export APPLY_EXTRA_HIDE_PATCH="yes"

# Should we add lz4kd?
# Set to either 5.10, 5.15, 6.1, or 6.6 to enabled lz4kd
export ADD_ZRAM_LZ4KD_KERNEL_VERSION="5.15"

# Should we set BBR as default TCP blocking algorithm?
# This could technically boost network performance
export SET_TCP_BBR_DEFAULT="no"

## END CONFIG SECTION

SELF_DIR=$(git -C $(dirname $0) rev-parse --show-toplevel)

$SELF_DIR/scripts/00-check-env.sh
$SELF_DIR/scripts/01-setup-ksu.sh
$SELF_DIR/scripts/02-setup-kpm.sh
$SELF_DIR/scripts/03-setup-susfs.sh
$SELF_DIR/scripts/04-custom-version.sh
$SELF_DIR/scripts/05-extra-patch.sh
$SELF_DIR/scripts/06-add-lz4kd.sh

echo ""
echo "All done!"
echo ""

