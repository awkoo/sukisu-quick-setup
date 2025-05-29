
#!/usr/bin/bash

SELF_DIR=$(git -C $(dirname $0) rev-parse --show-toplevel)

function log() {
    echo "[extra-patch.sh] $@"
}

if [ "$APPLY_EXTRA_HIDE_PATCH" = "yes" ]; then
    log "Applying extra hide stuff"
    patch -p1 < $SELF_DIR/SukiSU_patch/69_hide_stuff.patch
fi

if [ "$SET_TCP_BBR_DEFAULT" = "yes" ]; then
    log "Set BBR as default tcp blocking algorithm"
    echo "CONFIG_DEFAULT_BBR=y" >> arch/arm64/configs/gki_defconfig
fi
