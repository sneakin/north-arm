" src/bin/interp.common.4th" load
" thumb-linux-gnueabi" builder-target !
( " src/runner/imports/linux.4th" sources push-onto )
elf32-target-linux!
s" interp-boot" sources peek builder-run
