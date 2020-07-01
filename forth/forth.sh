#!/bin/bash

ROOT=$(dirname "$BASH_SOURCE")

set -e

source "$ROOT"/core.sh
source "$ROOT"/dict.sh
source "$ROOT"/state.sh
source "$ROOT"/data.sh
source "$ROOT"/compiler.sh

if [[ "$BASH_SOURCE" == "$0" ]]; then
    INPUT="boot"
    finterp
fi
