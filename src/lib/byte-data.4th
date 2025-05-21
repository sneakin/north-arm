alias> ,uint8 dpush-byte
alias> uint8! dpoke-byte
alias> uint8@ dpeek-byte

NORTH-STAGE 0 equals? IF
  " src/lib/byte-data/stage0.4th" load
ELSE
  " src/lib/byte-data/stage1.4th" load
THEN

alias> ,int8 ,uint8
alias> int8@ uint8@
alias> int8! uint8!

alias> ,int16 ,uint16
alias> int16@ uint16@
alias> int16! uint16!

alias> ,int32 ,uint32
alias> int32@ uint32@
alias> int32! uint32!

alias> ,int64 ,uint64
alias> int64@ uint64@
alias> int64! uint64!

: ,byte-string
  dup string-length ,byte-string/2
;

: byte-swap-uint16
  dup 0xFF logand 8 bsl
  swap 0xFF00 logand 8 bsr logior
;

: byte-swap-uint32
  dup 0xFF logand 24 bsl
  over 0xFF00 logand 8 bsl logior
  over 0xFF0000 logand 8 bsr logior
  swap 0xFF000000 logand 24 bsr logior
;

( Big endian: )

: UINT16@
  uint16@ byte-swap-uint16
;

: UINT32@
  uint32@ byte-swap-uint32
;

: UINT32!
  swap byte-swap-uint32 swap uint32!
;

( Data stack alignment & padding: )

: pad-addr ( addr alignment )
  2dup 1 - + over uint-div over mult
  rot 2 dropn
;

: pad-data
  dhere swap pad-addr dmove
;

: align-data
  dhere over uint-mod IF pad-data ELSE drop THEN
;
