( Constants: )

: defconst
  create
  out' do-const dict-entry-code uint32@
  over dict-entry-code uint32!
  dict-entry-data uint32!
;

: defconst>
  next-token defconst
;

( Constants whose data is a CS offset: )

: defconst-offset
  create
  out' do-const-offset dict-entry-code uint32@
  over dict-entry-code uint32!
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
