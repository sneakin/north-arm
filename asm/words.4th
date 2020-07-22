alias> ! dpoke
alias> @ dpeek

: map-stack-seq/4 ( stack-pointer state fn terminator -- state )
  ( Example: read-terminator 1 2 3 4 here 0 ' + read-terminator map-stack-seq )
  4 overn speek over equals IF 2 dropn swap drop return THEN
  rot ( sp state fn term -> sp term fn state )
  4 overn speek 3 overn exec
  rot 4 overn up-stack 4 set-overn
  loop
;

: map-stack-seq/3 read-terminator map-stack-seq/4 ;
: map-stack-seq/2 0 swap read-terminator map-stack-seq/4 drop ;

: revmap-stack-seq-loop
  4 overn over equals IF return THEN
  3 overn over speek 4 overn exec
  3 set-overn
  down-stack loop
;

: revmap-stack-seq/4 ( ptr acc fn term )
  4 overn stack-find/2
  dup 5 overn equals UNLESS
    down-stack revmap-stack-seq-loop
  THEN
  2 dropn swap drop
;

: revmap-stack-seq/3 read-terminator revmap-stack-seq/4 ;
