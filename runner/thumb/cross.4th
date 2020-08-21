: defined?
  make-label get-word null? swap drop
;

defcol up-stack/2
  rot swap cell-size int-mul int-add swap
endcol

defcol up-stack
  swap int32 1 up-stack/2 swap
endcol

defcol down-stack/2
  rot swap cell-size int-mul int-sub swap
endcol

defcol down-stack
  swap int32 1 down-stack/2 swap
endcol

defalias> : defproper
defalias> return proper-exit
defalias> equals equals?
defalias> mult int-mul
defalias> speek peek
defalias> speek-byte peek-byte
defalias> spoke poke
defalias> spoke-byte poke-byte

( alias> make-const defconst )
( ' RECURSE ' loop out-immediate/2 )

alias> c: :
alias> ;c ;
alias> : defproper
alias> ; endproper
alias> :: redefproper

( alias> immediate out-immediate )
( alias> immediate-as out-immediate-as )

alias> var> defvar>
alias> const> defconst>
alias> alias> defalias>
