: make-const
  swap " fpush " ++
  swap set-word!
;

: alias
  get-word swap set-word!
;

: alias>
  next-token next-token alias
;

alias> ! dpoke
alias> @ dpeek

: dallot
  dhere + dhere swap dmove
;

: unsigned-integer/2
  " #" swap ++ ++ 0 +
;

: bit-set? 1 swap bsl logand ;
: bit-set 1 swap bsl logior ;
: bit-clear 1 swap bsl lognot logand ;

: negate
  0 swap -
;
