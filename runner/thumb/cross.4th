: out-loop
  ' pointer
  dict dict-entry-data uint32@
  ' jump
; out-immediate-as loop

: defined?
  make-label get-word null? swap drop
;

defalias> return proper-exit
defalias> equals equals?
defalias> mult int-mul
( alias> make-const defconst )
( ' RECURSE ' loop out-immediate/2 )

alias> c: :
alias> ;c ;
alias> : defproper
alias> ; endproper

alias> immediate out-immediate
alias> immediate-as out-immediate-as

alias> const> defconst>
alias> alias> defalias>
