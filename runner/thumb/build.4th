4 const> cell-size
4 const> -op-size
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

runner/thumb/load.4th load

write-elf32-header
dhere

( The main stage: )
runner/thumb/ops.4th load
runner/thumb/linux.4th load
runner/thumb/frames.4th load
runner/thumb/interp.4th load
runner/thumb/math.4th load

( todo load itself into dictionary )

runner/thumb/init.4th load

( entry point: )
op-init dict-entry-size + 4 pad-addr
( finish the ELF file )
1 + .s write-elf32-ending

" Writing..." error-line
0 ddump-binary-bytes
dhere .s
