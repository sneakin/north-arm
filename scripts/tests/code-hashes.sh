#!/bin/sh
# Computes sha256 digests of each block of a file.
# Used to compare and detect changes in binaries block by block.
# test-sha256-code-hashes has similar output but for memory regions.

INPUT="${1}"
CODESIZE=$(wc -c "$INPUT" | cut -d ' ' -f 1)
BLOCKSIZE="${2:-1024}"
OFFSET="${3:-0}"

while [[ $(($OFFSET < $CODESIZE)) == 1 ]]; do
  printf "%X %s\n" "$OFFSET" "$(dd if="${INPUT}" bs=1 skip=$OFFSET count=$BLOCKSIZE 2>/dev/null | sha256sum | cut -f 1 -d ' ' | tr '[:lower:]' '[:upper:]')"
  OFFSET=$(($OFFSET + $BLOCKSIZE))
done