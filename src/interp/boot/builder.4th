( Command line usage:
    echo 'tmp" ./src/interp/boot/builder.4th" drop load c" interp-boot" here cell-size + swap builder-run' | ./bin/interp.elf > test.out 2>test.err
)

load-comp

( 4 const> cell-size
4 const> -op-size )
( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )
( 0xFFFFFFFF const> -op-mask )

0 var> code-origin

def builder-run ( entry )
  " Building..." error-line
  4 align-data
  dhere out-origin poke
  write-elf32-header
  dhere code-origin poke

  ( The main stage: )
  load-ops
  ( load-sources )

  " main" 4 create
  arg1 arg0 does-defalias
  " ./src/runner/thumb/init.4th" load

  code-origin peek
  ( entry point: )
  " init" 4 cross-lookup UNLESS " no init found" error-line not-found return THEN
  dict-entry-code uint32@
  ( finish the ELF file )
  .s write-elf32-ending

  " Writing..." error-line
  out-origin peek ddump-binary-bytes
  dhere to-out-addr .s

  exit-frame
end