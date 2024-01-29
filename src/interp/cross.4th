( Aliases and definitions to make it possible to load North-Bash and interpreter
  vocabularies into the compiled output. )

NORTH-STAGE UNLESS
  : load-stage0-fun
    " ./src/interp/cross/bash.4th" load
  ;

  load-stage0-fun
THEN

' NORTH-COMPILE-TIME defined? IF
  ' redefproper defined? UNLESS
    s[ src/cross/defining/proper.4th ] load-list
  THEN
THEN

( Track that this is loaded: )
true const> NORTH-CROSSED

( Words used in definitions: )

( defalias> return proper-exit ) ( caused trouble with out' looking up return )
defalias> equals equals?
defalias> mult int-mul
defalias> speek peek
defalias> speek-byte peek-byte
defalias> spoke poke
defalias> spoke-byte poke-byte

( Top level words: )

alias> sys:: :
alias> : defproper
( alias> :: redefproper )
alias> var> defvar>
alias> const> defconst>
alias> const-offset> defconst-offset>
alias> symbol> defsymbol>

alias> sys' ' immediate
alias> ' out' immediate

alias> immediate out-immediate
alias> immediate-as out-immediate-as

( And finally switch alias> over: )
alias> alias> defalias>
