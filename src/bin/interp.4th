" src/cross/builder.4th" load

s[ src/interp/messages.4th
   src/interp/strings.4th
   src/interp/dictionary.4th
   src/interp/output.4th
   src/interp/reader.4th
   src/interp/interp.4th
   src/interp/compiler.4th
   src/interp/debug.4th
   src/interp/data-stack.4th
   src/interp/data-stack-list.4th
   src/runner/thumb/proper.4th
   src/runner/proper.4th
] const> sources

s" interp-boot" sources builder-run
