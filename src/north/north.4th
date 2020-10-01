frame-byte-size defconst> frame-size
cell-size defconst> call-frame-size

alias> doc( ( out-immediate
alias> args( ( out-immediate

defalias> equals equals?

defcol dallot-seq
  swap
  dup int32 1 + cell-size * dallot
  2dup poke
  swap drop swap
endcol

defcol roll ( a b c -- c a b )
  int32 4 overn
  int32 2 overn int32 4 set-overn
  int32 3 overn int32 2 set-overn
  int32 3 set-overn
endcol

defcol drop2
  rot int32 2 dropn
endcol

defcol drop3
  rot int32 2 dropn
  swap drop
endcol

defcol swapdrop
  rot drop swap
endcol

defcol rotdrop2 ( a b c -- c )
  swap int32 4 set-overn
  rot int32 2 dropn
endcol

(
defcol returnN
  exit exit
endcol
)

alias> c-defvar> defvar>

: defvar>
  int32 0 c-defvar>
;

defvar> stack-top
defvar> base
defvar> *status*
defvar> *state*
defvar> *tokenizer-stack*
defvar> *tokenizer*
defvar> *mark*

: out-char-code
  next-token char-code
; out-immediate-as char-code

defcol read-byte
  exit exit
endcol

defcol input-reset
  exit exit
endcol

defalias> return0 return
defalias> drop-call-frame drop

defalias> code-segment cs

defalias> ! poke
defalias> @ peek
defalias> exec-core-word exec

' repeat-frame ' RECURSE out-immediate/2

alias> c: :
alias> ;c ;
alias> : def
alias> ; end

alias> immediate out-immediate
alias> immediate-as out-immediate-as

( read $hex )
( strings )
( recurse )
( : needs a def? )
