( Constants: )

: does-constant
  dup out' do-const does
;

: defconst does-constant dict-entry-data uint32! ;

: defconst> create> defconst ;

( Constants whose data is a CS offset: )

: does-const-offset
  dup out' do-const-offset does
;

: defconst-offset does-const-offset dict-entry-data uint32! ;

: defconst-offset> create> defconst-offset ;

( Constants with string values: )

: string-const>
  dhere to-out-addr swap
  ,byte-string 4 pad-data defconst-offset>
;

( Self referential symbols: )
: defsymbol>
  create> does-const-offset dup to-out-addr swap dict-entry-data poke
;
