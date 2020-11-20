" src/cross/builder.4th" load

s[
   src/lib/seq.4th
   src/lib/list.4th
   src/interp/strings.4th
   src/lib/assoc.4th
   src/interp/messages.4th
   src/interp/dictionary.4th
   src/interp/output.4th
   src/interp/reader.4th
   src/interp/linux/program-args.4th
   src/interp/linux/auxvec.4th
   src/interp/linux/hwcaps.4th
   src/interp/interp.4th
   src/interp/list.4th
   src/interp/compiler.4th
   src/interp/debug.4th
   src/interp/data-stack.4th
   src/runner/thumb/proper.4th
   src/runner/proper.4th
   src/interp/loaders.4th
] const> sources

(
   src/interp/libc.4th
)

s" interp-boot" sources builder-run
