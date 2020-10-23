( Constants: )

: does-constant
  out' do-const dict-entry-code uint32@
  over dict-entry-code uint32!
;

: defconst
  create does-constant
  dict-entry-data uint32!
;

: defconst>
  next-token defconst
;

( Constants whose data is a CS offset: )

: does-const-offset
  out' do-const-offset dict-entry-code uint32@
  over dict-entry-code uint32!
;

: defconst-offset
  create does-const-offset
  dict-entry-data uint32!
;

: defconst-offset>
  next-token defconst-offset
;

( Constants with string values: )

: string-const>
  dhere swap
  ,byte-string 4 pad-data defconst-offset>
;

: defsymbol>
  create> does-constant
  dup dict-entry-data uint32!
;
