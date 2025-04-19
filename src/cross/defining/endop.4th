( defop enters the asm dictionary, so: )
( fixme which dictionary? the active one when loaded at runtime, but when compiled? )

( push-asm-mark )

: endop
  ( calculate the sequence's size )
  dhere to-out-addr out-dict dict-entry-code uint32@
  target-thumb? IF 1 - THEN cell-size + -
  out-dict dict-entry-code uint32@ from-out-addr
  target-thumb? IF 1 - THEN uint32!
  ( pad the sequence )
  0 ,uint16
  4 align-data
  top-pop-mark
;

( pop-mark )
