#!/usr/bin/bash

SELF_DIR=$(git -C $(dirname $0) rev-parse --show-toplevel)

function log() {
    echo "[add-lz4kd.sh] $@"
}

# Code kang-ed from ShirkNeko/GKI_KernelSU_SUSFS/blob/main/.github/workflows/gki-kernel.yml
if ! [ "$ADD_ZRAM_LZ4KD_KERNEL_VERSION" = "" ]; then
    CONFIG_FILE="arch/arm64/configs/gki_defconfig"

    log "Adding lz4kd ($ADD_ZRAM_LZ4KD_KERNEL_VERSION)"

    cp -r $SELF_DIR/SukiSU_patch/other/zram/lz4k/include/linux/* ./include/linux/
    cp -r $SELF_DIR/SukiSU_patch/other/zram/lz4k/lib/* ./lib/
    cp -r $SELF_DIR/SukiSU_patch/other/zram/lz4k/crypto/* ./crypto/
    
    patch -p1 -F 3 < $SELF_DIR/SukiSU_patch/other/zram/zram_patch/$ADD_ZRAM_LZ4KD_KERNEL_VERSION/lz4kd.patch

    case "$ADD_ZRAM_LZ4KD_KERNEL_VERSION" in
        "5.10")
            echo "CONFIG_ZSMALLOC=y" >> "$CONFIG_FILE"
            echo "CONFIG_ZRAM=y" >> "$CONFIG_FILE"
            echo "CONFIG_MODULE_SIG=n" >> "$CONFIG_FILE"
            echo "CONFIG_CRYPTO_LZO=y" >> "$CONFIG_FILE"
            echo "CONFIG_ZRAM_DEF_COMP_LZ4KD=y" >> "$CONFIG_FILE"
            ;;
        "5.15" | "6.1")
            if grep -q "CONFIG_ZSMALLOC" -- "$CONFIG_FILE"; then
                log "Applying ZSMALLC config..."
                sed -i 's/CONFIG_ZSMALLOC=m/CONFIG_ZSMALLOC=y/g' "$CONFIG_FILE"
            else
                log "Warning! CONFIG_ZSMALLOC not set in config file"
                echo "CONFIG_ZSMALLOC=y" >> "$CONFIG_FILE"
            fi
            ;;
        "6.6")
            echo "CONFIG_ZSMALLOC=y" >> "$CONFIG_FILE"
            sed -i 's/CONFIG_ZRAM=m/CONFIG_ZRAM=y/g' "$CONFIG_FILE"
            ;;
        *)
            log "Error! Unsupported lz4kd version $ADD_ZRAM_LZ4KD_KERNEL_VERSION"
            ;;
    esac
    
fi

