#!/usr/bin/bash

SELF_DIR=$(git -C $(dirname $0) rev-parse --show-toplevel)

function log() {
    echo "[custom-version.sh] $@"
}

log "Applying custom kernel name settings"
if [ "$REMOVE_DIRTY" = "yes" ]; then
    sed -i -e "s/printf '%s' -dirty/:/g" scripts/setlocalversion
fi

if ! [ "$CUSTOM_KERNEL_NAME" = "" ]; then
    :> scripts/setlocalversion # :> owo
    echo "#!/bin/sh" >> scripts/setlocalversion
    echo "echo '$CUSTOM_KERNEL_NAME'" >> scripts/setlocalversion
fi

