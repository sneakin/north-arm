forth/compiler.4th load
asm/words.4th load
asm/byte-data.4th load
asm/thumb.4th load
elf/stub32.4th load

4 const> cell-size
cell-size const> -op-size

runner/thumb/iwords.4th load
runner/thumb/words.4th load

write-elf32-header
dhere

( The main stage: )
runner/thumb/ops.4th load
runner/thumb/frames.4th load
runner/thumb/interp.4th load

( todo load itself into dictionary )

runner/thumb/init.4th load

( entry point: )
op-init dict-entry-size + 4 pad-addr
( finish the ELF file )
1 + .s write-elf32-ending

" Writing..." error-line
0 ddump-binary-bytes
dhere .s
