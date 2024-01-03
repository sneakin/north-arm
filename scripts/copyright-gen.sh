#!/bin/sh

ROOT=$(dirname $0)
TMPL="${1:-${ROOT}/../src/copyright.4th.tmpl}"
SRC="${2:-${ROOT}/../src/copyright.txt}"

RICH="$(ruby "${ROOT}/enriched.rb" ${SRC})"
RICH_LEN=${#RICH}
TXT="$(STRIPED=1 ruby "${ROOT}/enriched.rb" ${SRC})"
TXT_LEN=${#TXT}

export RICH RICH_LEN TXT TXT_LEN
envsubst < "${TMPL}"
