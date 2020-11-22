( Op definitions: )

: does-thumb-code
  4 align-data
  dhere to-out-addr 1 + swap dict-entry-code uint32!
;

: defop
  create> does-thumb-code
;

: endop
  0 ,uint16
  4 align-data
;

: op@
  -op-size 2 equals IF uint16@ ELSE uint32@ THEN
;

: ,op
  -op-size 2 equals IF ,uint16 ELSE ,uint32 THEN
;
