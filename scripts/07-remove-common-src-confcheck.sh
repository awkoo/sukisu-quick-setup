#!/usr/bin/bash

SELF_DIR=$(git -C $(dirname $0) rev-parse --show-toplevel)

function log() {
    echo "[remove-common-src-confcheck.sh] $@"
}

if [ "" = "yes" ]; then
    if [ -f "../build/kernel/_setup_env.sh" ]; then
        sed -i -E 's/echo ERROR\: savedefconfig.+/RES=0/g' ./build/kernel/_setup_env.sh
        log "Removed config checks"
    else
        log "Warning! ../build/kernel/_setup_env.sh file not found!"
    fi
fi
