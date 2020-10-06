#!/bin/bash

ROOT=$(dirname "$BASH_SOURCE")
ARGV=("$@")

set -e

source "$ROOT"/core.sh
source "$ROOT"/dict.sh
source "$ROOT"/builtins.sh
source "$ROOT"/state.sh
source "$ROOT"/data.sh

if [[ "$BASH_SOURCE" == "$0" ]]; then
    INPUT="boot"
    finterp
fi
