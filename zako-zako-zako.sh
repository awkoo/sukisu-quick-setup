#!/usr/bin/bash

function open-file() {
    if ! [ "$EDITOR" = "" ]; then
        $EDITOR $1
    elif test nvim; then
        nvim $1
    elif test vim; then
        vim $1
    elif test vi; then
        vi $1
    elif test nano; then
        nano $1
    elif test emacs; then
        echo "((((((what? i cant hear you! there's too many brackets here!))))))"
        sleep 3
        echo "((((((((oh what? you wanna open emacs? ok sure.. one second!))))))))"
        sleep 1

        emacs $1
    fi
}

git clone --recurse-submodules https://github.com/Lama3L9R/sukisu-quick-setup sukisu-quick-setup

open-file sukisu-quick-setup/sukisu_setup.sh

echo "alright, lets go!"
sleep 1

bash sukisu-quick-setup/sukisu_setup.sh

