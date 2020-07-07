: ddump-binary-bytes
  dup dhere equals IF return THEN
  dup dpeek write-byte
  1 + loop
;

: ,uint8 255 logand dpush ;
: uint8! swap 255 logand swap dpoke ;

: ,uint16
  dup ,uint8
  8 bsr ,uint8
;

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

: ,byte-string/3
  ( string length n )
  2dup equals IF 0 ,uint8 return THEN
  3 overn 2 overn string-peek char-code ,uint8
  1 + loop
;

: ,byte-string
  dup string-length 0 ,byte-string/3
  3 dropn
;

: align-data
  dhere over / over mult
  dmove
  drop
;

: pad-data
  dhere over + over / over mult
  dmove
  drop
;
