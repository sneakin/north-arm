#!/bin/sh

ROOT=$(dirname $0)
TMPL="${1:-${ROOT}/../src/copyright.4th.erb}"
SRC="${2:-${ROOT}/../src/copyright.txt}"

erb rich="$(ruby "${ROOT}/enriched.rb" ${SRC})" txt="$(STRIPED=1 ruby "${ROOT}/enriched.rb" ${SRC})" "${TMPL}"
