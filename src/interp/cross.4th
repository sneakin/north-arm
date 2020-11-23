( Aliases and definitions to make it possible to load Bash style definitions into the compiled output. )

: load-stage0-fun
  NORTH-STAGE UNLESS
    " ./src/interp/cross/bash.4th" load
  THEN
;

load-stage0-fun

defalias> return0 return
( defalias> return proper-exit ) ( caused trouble with out' looking up return )
defalias> equals equals?
defalias> mult int-mul
defalias> speek peek
defalias> speek-byte peek-byte
defalias> spoke poke
defalias> spoke-byte poke-byte

alias> : defproper
alias> :: redefproper
alias> var> defvar>
alias> const> defconst>
alias> symbol> defsymbol>
alias> alias> defalias>
