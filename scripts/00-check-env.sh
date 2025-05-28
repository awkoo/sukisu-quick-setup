
#!/usr/bin/bash

SELF_DIR=$(git -C $(dirname $0) rev-parse --show-toplevel)

function log() {
    echo "[check-env.sh] $@"
}

function check-exec() {
    if ! which $1 &> /dev/null; then
        log "missing $1! abort!"
        exit 1
    fi
}

check-exec curl
check-exec git
check-exec jq
