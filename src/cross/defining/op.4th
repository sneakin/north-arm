( Op definitions: )

( todo lost the ability to dave aarch32 ops w/ the size changes )
: does-thumb-code
  4 align-data
  dhere to-out-addr 1 + swap dict-entry-code uint32!
;

: defop
  create> does-thumb-code
  0 ,uint32
;

: endop
  ( calculate the sequence's size )
  dhere to-out-addr out-dict dict-entry-code uint32@ 1 - cell-size + -
  out-dict dict-entry-code uint32@ from-out-addr 1 - uint32!
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
