( todo build static binary with this build script )
" src/bin/interp.common.4th" load
elf32-interp-android *elf32-interp* poke
s" interp-boot" sources builder-run
