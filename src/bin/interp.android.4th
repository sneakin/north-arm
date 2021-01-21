" src/bin/interp.common.4th" load
" src/runner/imports/android.4th" sources push-onto
elf32-interp-android *elf32-interp* poke
s" interp-boot" sources peek builder-run
