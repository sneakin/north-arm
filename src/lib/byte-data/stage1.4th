( Data stack readurs & writers for stage > 0: )

: ddump-binary-bytes
  dhere over - swap current-output @ write
  negative? IF
    s" Error dumping data: " error-string/2
    errno->string error-string/2 enl
  ELSE
    drop
  THEN
;

: byte-string@ ( nop, the pointer is fine ) ;

' dpush-short defined? [IF]
  alias> ,uint16 dpush-short
[ELSE]
  : ,uint16
    dhere poke-short
    dhere 2 + dmove
  ;
[THEN]

alias> uint16! poke-short
alias> uint16@ peek-short

alias> ,uint32 dpush
alias> uint32! poke
alias> uint32@ peek

cell-size 4 equals? [IF]
  " src/lib/byte-data/32.4th" load
[THEN]
cell-size 8 equals? [IF]
  " src/lib/byte-data/64.4th" load
[THEN]
cell-size 8 int> cell-size 4 int< or [IF]
  s" Only 32 and 64 bit cells supported. Not: " error-string/2 cell-size 8 * error-int enl ( todo raise error )
[THEN]
