4 const> cell-size
4 const> -op-size
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

runner/thumb/load.4th load

0 var> code-origin

: load-sources
  dup 0 equals IF drop return THEN
  swap load .s
  1 - loop
;

: builder-run ( files... count )
  " Building..." error-line
  write-elf32-header
  dhere set-code-origin

  ( The main stage: )
  runner/thumb/math.4th
  runner/thumb/interp.4th
  runner/thumb/frames.4th
  runner/thumb/linux.4th
  runner/thumb/ops.4th
  5 load-sources

  load-sources

  runner/thumb/init.4th load

  code-origin
  ( entry point: )
  op-init dict-entry-size + 4 pad-addr
  ( finish the ELF file )
  1 + .s write-elf32-ending

  " Writing..." error-line
  0 ddump-binary-bytes
  dhere .s
;
