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

( todo rm what is in include/asm & bring bash up to par & compile in )
def builder-load
  s" IF" immediates @ cs + dict-lookup
  IF 3 dropn ELSE 3 dropn load-core THEN
  s" src/cross/builder/assembly.4th" load/2
  s" src/cross/builder/run/interp.4th" load/2
  s" Builder loaded." error-line/2
  exit-frame
end
