#!/bin/sh

forth_words()
{
    awk -P '/^(:|def.*) +(.+)/ { print $2,FILENAME }' $*
}

MODE="$1"
shift

case $MODE in
     -fun) forth_words $* | sort ;;
     -file) forth_words $* | awk -P '/./ { print $2,$1 }' | sort ;;
     *) echo "Unknown mode: $MODE" ;;
esac


