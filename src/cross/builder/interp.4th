( todo constants need to be vars. single return strings. lists & strings on stack prevent straight arg ordering. )

( load-core )
load-thumb-asm

4 const> cell-size
4 const> -op-size

( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

0 var> code-origin

def builder-run ( entry len src-cons )
  elf32-dynamic-stub
  
  " Building..." error-line
  4 align-data
  dhere out-origin poke
  write-elf-header
  dhere code-origin poke

  ( The main stage: )
  load-runner
  arg0 load-list

  s" main" create arg2 arg1 does-defalias
  " version.4th" load
  " ./src/runner/thumb/init.4th" load

  code-origin peek
  ( entry point: )
  s" init" cross-lookup UNLESS " no init found" error-line not-found return THEN
  dict-entry-code uint32@
  ( finish the ELF file )
  .s write-elf-ending

  " Writing..." error-line
  out-origin peek ddump-binary-bytes
  dhere to-out-addr .s

  exit-frame
end