( todo constants need to be vars. single return strings. lists & strings on stack prevent straight arg ordering. )

s[ src/cross/builder/globals.4th
   src/cross/builder/predicates/interp.4th
] load-list

def builder-reset!
  DEFAULT-BUILDER-TARGET builder-target !
  true builder-with-runner !
  DEFAULT-OUTPUT-FORMAT builder-output-format !
  0 builder-output-file !
  0 builder-output !
  0 code-origin !
  0 BUILD-COPYRIGHT !
end

( A post-execution load step: )

def builder-load
  s" IF" immediates @ cs + dict-lookup
  IF 3 dropn ELSE 3 dropn load-core THEN
  target-thumb? IF
    s" Loading thumb assembler..." error-line/2
    " src/include/thumb-asm.4th" load ( load-thumb-asm )
  ELSE
    target-x86? IF
      s" Loading x86 assembler..." error-line/2
      " src/include/x86-asm.4th" load
    ELSE s" Unsupported target" error-line/2 -1 sysexit ( todo error )
    THEN
  THEN
  " src/cross/builder/run/interp.4th" load
  s" Builder loaded." error-line/2
  exit-frame
end
