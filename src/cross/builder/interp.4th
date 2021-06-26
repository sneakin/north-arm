( todo constants need to be vars. single return strings. lists & strings on stack prevent straight arg ordering. )

( load-core )
load-thumb-asm

4 const> cell-size
4 const> -op-size

( Needs defconst sooner. )
0xFFFFFFFF const> -op-mask

0 var> code-origin
0 var> BUILD-COPYRIGHT

def builder-run ( entry len src-cons )
  NORTH-STAGE 2 int> IF elf32-dynamic-stub THEN
  
  " Building..." error-line
  4 align-data
  dhere out-origin poke
  write-elf-header
  dhere code-origin poke

  ( Words to later patch: )
  BUILD-COPYRIGHT peek dup IF
    ,byte-string
    s" copyright" create
  ELSE drop
  THEN
  s" main" create

  ( The main stage: )
  load-runner
  " version.4th" load
  " ./src/runner/thumb/init.4th" load
  arg0 load-list

  s" copyright" cross-lookup IF
    s" do-const-offset" cross-lookup IF
      dict-entry-code uint32@ over dict-entry-code uint32!
      code-origin peek to-out-addr over dict-entry-data uint32!
    ELSE drop
    THEN
  THEN drop
  s" main" cross-lookup IF arg2 arg1 does-defalias ELSE not-found drop THEN
  s" *init-dict*" cross-lookup IF out-dict to-out-addr swap dict-entry-data uint32! ELSE not-found drop THEN
  s" *code-size*" cross-lookup IF dhere to-out-addr swap dict-entry-data uint32! ELSE not-found drop THEN

  code-origin peek
  ( entry point: )
  s" init" cross-lookup UNLESS " no init found" error-line not-found return THEN
  dict-entry-code uint32@
  ( finish the ELF file )
  write-elf-ending
  s" *program-size*" cross-lookup IF dhere to-out-addr swap dict-entry-data uint32! ELSE not-found drop THEN

  " Writing..." error-line
  out-origin peek .s ddump-binary-bytes
  dhere to-out-addr return1
end
