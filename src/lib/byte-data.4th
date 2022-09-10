alias> ,uint8 dpush-byte
alias> uint8! dpoke-byte
alias> uint8@ dpeek-byte

: ddump-binary-bytes
  dup dhere equals IF drop return THEN
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

( todo optimize for byte by byte in stage0, longs and double longs elsewhere? )

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

( fixme doesn't work with 32 bit cells )

NORTH-STAGE 0 int> [IF]
  " src/lib/byte-data/stage1.4th" load
  cell-size 4 equals? [IF]
    " src/lib/byte-data/32.4th" load
  [ELSE]
     cell-size 8 int>= [IF]
        " src/lib/byte-data/64.4th" load
     [ELSE]
        s" Only 32 and 64 bit cells supported." error-line/2 error ( todo raise error )
     [THEN]
  [THEN]
[ELSE]
  " src/lib/byte-data/stage0.4th" load
[THEN]

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
  2dup equals IF 0 ,uint8 3 dropn return THEN
  3 overn 2 overn string-peek ,uint8
  1 + loop
;

: ,byte-string/2 0 ,byte-string/3 ;

: ,byte-string
  dup string-length 0 ,byte-string/3
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
  2dup + over / over mult
  rot 2 dropn
;

: pad-data
  dhere swap pad-addr dmove
;

: align-data
  dhere over mod IF pad-data ELSE drop THEN
;
