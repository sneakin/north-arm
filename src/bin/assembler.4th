" src/cross/builder.4th" load

s[
   src/lib/seq.4th
   src/lib/list.4th
   src/interp/strings.4th
   src/interp/messages.4th
   src/interp/dictionary.4th
   src/lib/fun.4th
   src/lib/assoc.4th
   src/runner/thumb/math-init.4th
   src/interp/output/strings.4th
   src/interp/output/hex.4th
   src/interp/output/dec.4th
   src/interp/reader.4th
   src/interp/linux/program-args.4th
   src/interp/linux/auxvec.4th
   src/interp/linux/hwcaps.4th
   src/interp/interp.4th
   src/interp/list.4th
   src/interp/compiler.4th
   src/interp/data-stack.4th
   src/interp/loaders.4th
   src/interp/proper.4th
   src/interp/debug.4th
   src/interp/decompiler.4th
   src/assembler/main.4th
   src/cross/defining/proper.4th
   src/interp/cross.4th
   src/lib/bit-fields.4th
   src/lib/byte-data.4th
   src/lib/stack-marker.4th
   src/lib/strings.4th
   src/lib/asm/thumb/v1.4th
   src/lib/asm/thumb/v2.4th
   src/lib/asm/thumb/vfp.4th
] const> sources

" thumb-linux-static" builder-target !
s" assembler-boot" sources builder-run
