4 const> cell-size
4 const> -op-size
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

src/cross/builder.4th load

' assembler-boot
src/lib/elf/stub32.4th
src/lib/asm/thumb2.4th
src/lib/asm/thumb.4th
src/lib/strings.4th
src/lib/stack.4th
src/lib/byte-data.4th
src/lib/bit-fields.4th
src/interp/cross.4th
src/assembler/main.4th
src/runner/thumb/proper.4th
src/interp/data-stack.4th
src/interp/interp.4th
src/interp/reader.4th
src/interp/output.4th
src/interp/dictionary.4th
src/interp/strings.4th
src/interp/messages.4th
17 builder-run/2