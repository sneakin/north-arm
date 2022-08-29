( Aliases and definitions to make it possible to load Bash style definitions into the compiled output. )

: load-stage0-fun
  NORTH-STAGE UNLESS
    " ./src/interp/cross/bash.4th" load
  THEN
;

load-stage0-fun

( Words usod in definitions: )

defalias> return0 return
( defalias> return proper-exit ) ( caused trouble with out' looking up return )
defalias> equals equals?
defalias> mult int-mul
defalias> speek peek
defalias> speek-byte peek-byte
defalias> spoke poke
defalias> spoke-byte poke-byte

( Top level words: )

alias> : defproper
( alias> :: redefproper )
alias> var> defvar>
alias> const> defconst>
alias> const-offset> defconst-offset>
alias> symbol> defsymbol>

alias> ' out' immediate

alias> immediate out-immediate ( todo compiling or to output? )
alias> immediate-as out-immediate-as

( And finally switch alias> over: )
alias> alias> defalias>
