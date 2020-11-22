#!/bin/sh

MODE="$1"
INPUT="$2"
OUTPUT="$3"

BPP=3
FMT=BGR
WIDTH=64

OUTOPTS="-negate"
	 
case "${MODE}" in
    "e") SIZE=$(wc -c $INPUT | cut -f 1 -d " ")
	 HEIGHT=$(( ($SIZE+$WIDTH*${BPP} )/$WIDTH/${BPP} ))
	 PAD=$(($HEIGHT*$WIDTH*${BPP}))

	 echo ${WIDTH}x${HEIGHT} $SIZE $PAD $(($PAD-$SIZE)) 1>&2

	 (cat $INPUT; dd if=/dev/urandom bs=1 count=$(($PAD-$SIZE)) ) |
	     convert -depth 8 -size ${WIDTH}x${HEIGHT} ${FMT}:- ${OUTOPTS} $OUTPUT
	 ;;
    "d") convert "${INPUT}" -depth 8 ${OUTOPTS} "${FMT}":"${OUTPUT}"
	 ;;
    *) echo "Unknown mode ${MODE}" ;;
esac
