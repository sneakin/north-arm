4 const> cell-size
4 const> -op-size
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

runner/thumb/builder.4th load

' assembler-boot
elf/stub32.4th
asm/thumb2.4th
asm/thumb.4th
lib/strings.4th
lib/stack.4th
asm/byte-data.4th
lib/bit-fields.4th
runner/thumb/cross.4th
runner/thumb/case.4th
runner/thumb/assembler.4th
runner/thumb/proper.4th
runner/thumb/data-stack.4th
runner/thumb/interp.4th
runner/thumb/reader.4th
runner/thumb/output.4th
runner/thumb/dictionary.4th
runner/thumb/strings.4th
runner/thumb/messages.4th
18 builder-run/2
