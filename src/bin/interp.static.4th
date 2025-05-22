( Later stage static build )
" src/bin/interp.common.4th" load
" thumb-linux-static" builder-target !
elf32-target-linux!
s" interp-boot" sources peek builder-run
