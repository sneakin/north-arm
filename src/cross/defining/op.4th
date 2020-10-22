( Op definitions: )

( todo needs to apply out-origin )

: does-code
  4 align-data
  dhere swap dict-entry-code uint32!
;

: defop
  create> does-code
;

: endop
  0 ,uint16
  4 align-data
; immediate

: op@
  -op-size 2 equals IF uint16@ ELSE uint32@ THEN
;

: ,op
  -op-size 2 equals IF ,uint16 ELSE ,uint32 THEN
;
