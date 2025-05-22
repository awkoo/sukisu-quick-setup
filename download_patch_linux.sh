
SELF_DIR=$(realpath $(dirname $0))

if ! [ -f "$SELF_DIR/patch_linux" ]; then
    echo "no patch_linux! downloading..."
    
    TAG=$(jq -r 'map(select(.prerelease)) | first | .tag_name' <<< $(curl -L --silent https://api.github.com/repos/ShirkNeko/SukiSU_KernelPatch_patch/releases))
    echo "latest tag is: $TAG"

    curl -Ls -o "$SELF_DIR/patch_linux" "https://github.com/ShirkNeko/SukiSU_KernelPatch_patch/releases/download/$TAG/patch_linux"

    if [ $? -eq 0 ]; then
        echo "download ok"
    else
        echo "download fail ($?)! abort!"
        exit 1
    fi

    if [[ $(stat -c %s "$SELF_DIR/patch_linux") -lt 1024 ]]; then
        echo "error! downloaded file corrupted (file too small)! abort!"
        exit 1
    fi

    chmod +x "$SELF_DIR/patch_linux"
    if [ $? -eq 0 ]; then
        echo "set permission ok"
    else
        echo "failed to set permission! abort!"
        exit 1
    fi
fi
