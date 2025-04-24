( Aliases and definitions to make it possible to load North-Bash and interpreter
  vocabularies into the compiled output. )

NORTH-STAGE UNLESS
  : load-stage0-fun
    " ./src/interp/cross/bash.4th" load
  ;

  load-stage0-fun
THEN

DEFINED? NORTH-COMPILE-TIME IF
  DEFINED? redefproper UNLESS
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

alias> sys:def def
alias> sys:defcol defcol
alias> sys:: :
alias> sys:symbol> symbol>
alias> sys:var> var>
alias> sys:const> const>
DEFINED? const-offset> IF
  alias> sys:const-offset> const-offset>
THEN
DEFINED? const IF
  alias> sys:const const
THEN
DEFINED? const-offset IF
  alias> sys:const-offset const-offset
THEN

alias> : defproper
( alias> :: redefproper )
alias> var> defvar>
alias> const> defconst>
alias> const-offset> defconst-offset>
alias> const defconst
alias> const-offset defconst-offset
alias> symbol> defsymbol>

alias> sys' '
alias> sys'' '' immediate-as sys'
alias> ' out'
alias> '' out'' immediate-as '

alias> sys:immediate immediate
alias> sys:immediate-as immediate-as
alias> immediate out-immediate
alias> immediate-as out-immediate-as

alias> SYS:DEFINED? DEFINED?
alias> DEFINED? OUT:DEFINED?

( And finally switch alias> over: )
alias> sys:alias> alias>
alias> alias> defalias>
