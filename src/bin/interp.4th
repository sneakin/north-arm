( Stage 0 static interpreter build )
" src/bin/interp.common.4th" load
" thumb-linux-static" string-const> builder-target
elf32-target-linux!
s" interp-boot" sources builder-run
