( Colon definitions: )

( some ops will need to be defined before this. )

NORTH-STAGE 0 equals? IF
  " src/cross/defining/colon/bash.4th" load
ELSE
  " src/cross/defining/colon/interp.4th" load
THEN

: defcol
  create> does-col
  defcol-read
  out' exit to-out-addr ,op
  0 ,op
;
