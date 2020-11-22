( to load boot/core and cross, immediate needs to build the immediate dictionary for the output. will need to pass interpreter and output immediate dictionaries into init as they won't be definable until all is compiled. )

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
   src/interp/decompiler.4th
   src/interp/data-stack.4th
   src/interp/proper.4th
   src/interp/loaders.4th
   src/cross/defining/proper.4th
   src/assembler/main.4th
   src/cross/oiwords.4th
   src/interp/cross.4th
   src/lib/bit-fields.4th
   src/lib/byte-data.4th
   src/lib/stack-marker.4th
   src/lib/strings.4th
   src/lib/asm/thumb/v1.4th
   src/lib/asm/thumb/v2.4th
   src/lib/asm/thumb/vfp.4th
   src/interp/boot/core.4th
   src/cross/builder/interp.4th
] const> sources

s" assembler-boot" sources builder-run
