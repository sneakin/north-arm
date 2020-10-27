4 const> cell-size
4 const> -op-size
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

src/bash/compiler.4th load
src/cross/arch/thumb.4th load

0 var> code-origin

: builder-run/2 ( entry-fn files... count )
  " Building..." error-line
  dhere set-out-origin
  write-elf32-header
  dhere set-code-origin

  ( The main stage: )
  src/runner/thumb/math.4th
  src/runner/thumb/logic.4th
  src/runner/thumb/linux.4th
  src/cross/defining/frames.4th
  src/runner/frames.4th
  src/runner/thumb/frames.4th
  src/runner/aliases.4th
  src/cross/defining/variables.4th
  src/cross/constants.4th
  src/cross/defining/constants.4th
  src/cross/defining/alias.4th
  src/cross/defining/colon.4th
  src/cross/defining/colon-bash.4th
  src/runner/thumb/ops.4th
  14 load-sources

  load-sources

  ' main create swap does-defalias
  src/runner/thumb/init.4th load

  code-origin
  ( entry point: )
  " init" cross-lookup UNLESS " no init found" error-line not-found return THEN
  dict-entry-code uint32@
  ( finish the ELF file )
  1 + .s write-elf32-ending

  " Writing..." error-line
  out-origin .s ddump-binary-bytes
  dhere .s
;