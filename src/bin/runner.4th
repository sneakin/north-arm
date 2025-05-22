( todo split like interp for android and linux )

" src/cross/builder.4th" load
" src/copyright.4th" load

builder-load

" thumb-linux-static" builder-target !

s[ src/interp/strings.4th
   src/runner/main.4th
] const> sources

s" runner-boot" sources builder-run
