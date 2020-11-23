( Output quote, does need literalizing ops: )

: out-out''
  ( Using literal as out' can't be used, and it's Bash, because it pushes an integer. )
  literal pointer POSTPONE out-off'
;
out-immediate-as out'
out-immediate-as '

: out-out-off''
  literal pointer POSTPONE out-off'
; out-immediate-as out-off'

: out-off''
  ( Pointer is not available in north-bash. )
  literal literal POSTPONE out-off'
; immediate-as out-off'

