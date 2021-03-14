( todo split like interp for android and linux )

" src/cross/builder.4th" load

" thumb-linux-static" string-const> BUILDER-TARGET

s[ src/interp/strings.4th
   src/interp/dictionary.4th
   src/runner/thumb/math-init.4th
   src/runner/main.4th
] const> sources

s" runner-boot" sources builder-run
