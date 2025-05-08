( " *read-terminator*" string-const> read-terminator )

DEFINED? read-terminator UNLESS
  symbol> read-terminator
THEN

: map-stack-seq/4 ( stack-pointer state fn terminator -- state )
  ( Example: read-terminator 1 2 3 4 here 0 ' + read-terminator map-stack-seq )
  4 overn speek over equals IF 2 dropn swap drop return THEN
  rot ( sp state fn term -> sp term fn state )
  4 overn speek 3 overn exec-abs
  rot 4 overn up-stack 4 set-overn
  loop
;

: map-stack-seq/3 read-terminator map-stack-seq/4 ;
: map-stack-seq/2 0 swap read-terminator map-stack-seq/4 drop ;

: revmap-stack-seq-loop ( ptr acc fn down-iter )
  4 overn over equals IF return THEN
  3 overn over speek 4 overn exec-abs
  3 set-overn
  down-stack loop
;

: revmap-stack-seq/4 ( ptr acc fn term )
  top-frame 5 overn stack-find/3 IF
    dup 5 overn equals UNLESS
      down-stack revmap-stack-seq-loop
    THEN
  THEN
  2 dropn swap drop
;

: revmap-stack-seq/3 read-terminator revmap-stack-seq/4 ;
