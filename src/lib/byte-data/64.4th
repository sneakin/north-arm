: ,uint64 ( value -- )
  dpush
;

: uint64! ( value place - )
  dpoke
;

: uint64@ ( place -- value )
  dpeek
;

alias> ,cell ,int64
alias> .cell .int64
alias> cell@ int64@
alias> cell! int64!
