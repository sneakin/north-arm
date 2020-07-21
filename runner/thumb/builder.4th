4 const> cell-size
4 const> -op-size
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

runner/thumb/load.4th load

0 var> code-origin

: builder-run/2 ( entry-fn files... count )
  " Building..." error-line
  write-elf32-header
  dhere set-code-origin

  ( The main stage: )
  runner/thumb/math.4th
  runner/thumb/linux.4th
  runner/thumb/frames.4th
  runner/thumb/ops.4th
  4 load-sources

  load-sources

  ' main create does-defalias
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