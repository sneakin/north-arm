: make-const
  swap " fpush " ++
  swap set-word!
;

alias> ! dpoke
alias> @ dpeek

: dallot
  dhere + dhere swap dmove
;

: unsigned-integer/2
  q" #" swap ++ ++ 0 +
;

: bit-set? 1 swap bsl logand ;
: bit-set 1 swap bsl logior ;
: bit-clear 1 swap bsl lognot logand ;

: negate
  0 swap -
;

: poke-overn
  here swap up-stack/1 up-stack spoke
;

: map-stack-seq/4 ( stack-pointer state fn terminator -- state )
  ( Example: read-terminator 1 2 3 4 here 0 ' + read-terminator map-stack-seq )
  4 overn speek over equals IF 2 dropn swap drop return THEN
  rot ( sp state fn term -> sp term fn state )
  4 overn speek 3 overn exec
  rot 4 overn up-stack 4 poke-overn
  loop
;

: map-stack-seq/3 read-terminator map-stack-seq/4 ;
: map-stack-seq/2 0 swap read-terminator map-stack-seq/4 drop ;

: revmap-stack-seq-loop
  3 overn over speek 4 overn exec
  3 poke-overn
  4 overn over equals UNLESS down-stack loop THEN
;

: revmap-stack-seq/4 ( ptr acc fn term )
  4 overn stack-find/2 down-stack
  revmap-stack-seq-loop
  2 dropn swap drop
;

: revmap-stack-seq/3 read-terminator revmap-stack-seq/4 ;
