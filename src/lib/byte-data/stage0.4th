( Byte data functions for Bash interpreter. )

( todo Works on 32 bit Bash? )

: ,uint64 ( value -- )
  dup ,uint8
  dup 8 bsr ,uint8
  dup 16 bsr ,uint8
  dup 24 bsr ,uint8
  dup 32 bsr ,uint8
  dup 40 bsr ,uint8
  dup 48 bsr ,uint8
  56 bsr ,uint8
;

: uint64! ( value place - )
  2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap 2dup uint8!
  1 + swap 8 bsr swap uint8!
;

: uint64@ ( place -- value )
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
