( Op definitions: )

( todo lost the ability to have aarch32 ops w/ the size changes )
: does-op
  4 align-data
  dhere to-out-addr
  target-thumb? IF 1 + THEN swap dict-entry-code uint32!
;

: defop
  push-asm-mark
  create> does-op
  0 ,uint32
  ( 0xCCCCCCCC ,uint32 )
;

: op@
  -op-size 2 equals IF uint16@ ELSE uint32@ THEN
;

: ,op
  -op-size 2 equals IF ,uint16 ELSE ,uint32 THEN
;
