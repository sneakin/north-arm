( Byte data functions for Bash interpreter. )

: ddump-binary-bytes
  dup dhere equals IF drop return THEN
  dup uint8@ write-byte
  1 + loop
;

def byte-string@/3 ( ptr str n -- str length )
  arg2 arg0 seq-peek
  dup 0 equals? IF arg1 arg0 3 return2-n THEN
  code-char arg1 ++ set-arg1
  arg0 1 + set-arg0
  repeat-frame
end

def byte-string@ arg0 " " 0 byte-string@/3 1 return2-n end

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
