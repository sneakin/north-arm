( Colon definitions: )

( some ops will need to be defined before this. )

: does-col
  out' do-col dict-entry-code uint32@
  over dict-entry-code uint32!
  4 align-data
  dhere over dict-entry-data uint32!
  drop
;

: defcol
  create> does-col
  defcol-read
  out' exit ,op
;
