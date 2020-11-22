( Output quote, does need literalizing ops: )

: out-off'
  POSTPONE out' to-out-addr
; out-immediate-as [']

: [out-off'']
  literal literal POSTPONE out-off'
; immediate-as out-off'

: out''
  out' pointer POSTPONE out-off'
; out-immediate-as '

: out-off''
  out' literal POSTPONE out-off'
; out-immediate-as out-off'
