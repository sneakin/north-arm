tmp" src/interp/boot/core.4th" drop load
( tmp" lib/case.4th" drop load )
tmp" src/lib/asm/words.4th" drop load
tmp" src/lib/bit-fields.4th" drop load
tmp" src/lib/byte-data.4th" drop load
tmp" src/lib/asm/thumb.4th" drop load
tmp" src/lib/asm/thumb2.4th" drop load
tmp" src/lib/elf/stub32.4th" drop load

tmp" src/interp/boot/cross.4th" drop load
tmp" src/cross/defining/op.4th" drop load

tmp" src/runner/thumb/ops.4th" drop load

tmp" src/cross/defining/alias.4th" drop load
tmp" src/cross/defining/constants.4th" drop load
tmp" src/cross/defining/variables.4th" drop load
tmp" src/cross/defining/colon.4th" drop load

( runner/thumb/iwords.4th load
runner/thumb/words.4th load )
