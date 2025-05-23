( Output word quoting. Order is important with postpones in the output variants in owords.4th. )

: out'
  next-token cross-lookup LOOKUP-NOT-FOUND equals IF
    not-found
  THEN
; immediate-as [out'] immediate ( for postpone safety )

: OUT:DEFINED?
  POSTPONE out' 0 equals? not
;
 
: out''
  literal literal POSTPONE out'
; immediate-as out'

: out-off'
  POSTPONE out' to-out-addr
; ( cross-immediate-as ['] ) immediate ( for postpone safety )

: out-off''
  ( Pointer is not available during compile in north-bash. )
  literal literal POSTPONE out-off'
; immediate-as out-off'

( Output quote for north-bash: )

: out-out''
  ( Using literal as out' can't be used as it pushes an integer that causes double literalizing, and it's north-bash which pushes tokens. )
  literal pointer next-token
;
cross-immediate-as out-off'
cross-immediate-as out'
cross-immediate-as '
