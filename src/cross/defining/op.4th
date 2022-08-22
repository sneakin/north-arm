( Op definitions: )

( todo lost the ability to have aarch32 ops w/ the size changes )
: does-op
  4 align-data
  dhere to-out-addr
  target-thumb? IF 1 + THEN swap dict-entry-code uint32!
;

: defop
  create> does-op
  0 ,uint32
  ( 0xCCCCCCCC ,uint32 )
;

: endop
  ( calculate the sequence's size )
  dhere to-out-addr out-dict dict-entry-code uint32@
  target-thumb? IF 1 - THEN cell-size + -
  out-dict dict-entry-code uint32@ from-out-addr
  target-thumb? IF 1 - THEN uint32!
  ( pad the sequence )
  0 ,uint16
  4 align-data
;

: op@
  -op-size 2 equals IF uint16@ ELSE uint32@ THEN
;

: ,op
  -op-size 2 equals IF ,uint16 ELSE ,uint32 THEN
;
