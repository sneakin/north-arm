( todo constants need to be vars. single return strings. lists & strings on stack prevent straight arg ordering. )

s[ src/cross/builder/globals.4th
   src/cross/builder/predicates/interp.4th
] load-list

def builder-reset!
  ' *load-paths* IF
    *load-paths* @ as-code-pointer builder-load-paths !
    *north-file-exts* @ as-code-pointer builder-file-exts !
  ELSE
    0 builder-load-paths !
    0 builder-file-exts !
  THEN
  0 builder-baked-features !
  false builder-with-runner !
  false builder-with-interp !
  false builder-with-cross !
  DEFAULT-BUILDER-TARGET builder-target !
  DEFAULT-OUTPUT-FORMAT builder-output-format !
  0 builder-output-file !
  0 builder-output !
  0 code-origin !
  0 BUILD-COPYRIGHT !
end

( A post-execution load step: )

1 NORTH-STAGE int<= IF
  DEFINED? const> UNLESS
    def does-const
      arg0 pointer do-const does
    end

    def const>
      create> does-const
      arg0 over dict-entry-data poke
      exit-frame
    end
  THEN
THEN

( Include the assembler dictionaries only if the builder is being
  compiled with the boot/core. )
SYS:DEFINED? NORTH-COMPILE-TIME IF NORTH-COMPILE-TIME @ ELSE 0 THEN
IF
  ( not that struct is used, but boot/core includes it )
  DEFINED? struct: IF
    s[ src/cross/builder/assembly.4th
       src/cross/builder/run/interp.4th
    ] load-list
  THEN
THEN

( todo rm what is in include/asm & bring bash up to par & compile in )
def builder-load
  s" IF" immediates @ cs + dict-lookup
  IF 3 dropn ELSE 3 dropn load-core THEN
  s" asm-thumb" defined?/2 UNLESS s" src/cross/builder/assembly.4th" load/2 THEN
  s" builder-run" defined?/2 UNLESS s" src/cross/builder/run/interp.4th" load/2 THEN
  s" Builder loaded." error-line/2
  exit-frame
end
