#!/bin/env -S busybox ash

source "$(dirname "$0")"/core.sh

if [[ $(basename "${0}") == "forth.sh" ]]; then
    finterp
fi
