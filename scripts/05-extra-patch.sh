
#!/usr/bin/bash

SELF_DIR=$(git -C $(dirname $0) rev-parse --show-toplevel)

function log() {
    echo "[extra-patch.sh] $@"
}

if [ "$APPLY_EXTRA_HIDE_PATCH" = "yes" ]; then
    log "applying extra hide stuff"
    patch -p1 < $SELF_DIR/SukiSU_patch/69_hide_stuff.patch
fi
