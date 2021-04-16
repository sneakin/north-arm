alias> ,uint8 dpush-byte
alias> uint8! dpoke-byte
alias> uint8@ dpeek-byte

: ddump-binary-bytes
  dup dhere equals IF return THEN
  dup uint8@ write-byte
  1 + loop
;

: ,uint16
  dup ,uint8
  8 bsr ,uint8
;

: uint16@
  dup uint8@
  swap 1 + uint8@ 8 bsl
  logior
;

: uint16!
  2dup uint8!
  1 + swap 8 bsr swap uint8!
;

( todo optimize? )

: ,uint32
  dup ,uint8
  dup 8 bsr ,uint8
  dup 16 bsr ,uint8
  24 bsr ,uint8
;

: uint32!
  2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap uint8!
;

: uint32@
  dup uint8@
  swap 1 + dup uint8@
  swap 1 + dup uint8@
  swap 1 + uint8@
  8 bsl logior
  8 bsl logior
  8 bsl logior
;

: ,uint64
  dup ,uint8
  dup 8 bsr ,uint8
  dup 16 bsr ,uint8
  dup 24 bsr ,uint8
  dup 32 bsr ,uint8
  dup 40 bsr ,uint8
  dup 48 bsr ,uint8
  56 bsr ,uint8
;

( fixme doesn't work with 32 bit cells )

: uint64!
  2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap uint8!
;

: uint64@
  dup uint8@
  swap 1 + dup uint8@
  swap 1 + dup uint8@
  swap 1 + dup uint8@
  swap 1 + dup uint8@
  swap 1 + dup uint8@
  swap 1 + dup uint8@
  swap 1 + uint8@
  8 bsl logior
  8 bsl logior
  8 bsl logior
  8 bsl logior
  8 bsl logior
  8 bsl logior
  8 bsl logior
;

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

: ,byte-string/3
  ( string length n )
  2dup equals IF 0 ,uint8 return THEN
  3 overn 2 overn string-peek ,uint8
  1 + loop
;

: ,byte-string
  dup string-length 0 ,byte-string/3
  3 dropn
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
  swap drop
;

( Big endian: )

: UINT16@
  uint16@ byte-swap-uint16
;

: UINT32@
  uint32@ byte-swap-uint32
;

( Data stack alignment & padding: )

: pad-addr ( addr alignment )
  2dup + over / over mult
  rot 2 dropn
;

: pad-data
  dhere swap pad-addr dmove
;

: align-data
  dhere over mod IF pad-data ELSE drop THEN
;
