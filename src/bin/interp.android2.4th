" src/bin/interp.common.4th" load
" thumb2-linux-android" string-const> BUILDER-TARGET
" src/runner/imports/android.4th" sources push-onto
elf32-target-android!
s" interp-boot" sources peek builder-run
