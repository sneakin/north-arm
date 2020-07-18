def bsl-to-match/3 ( to-match n bits-left )
  arg2 arg1 int< IF return THEN
  arg1 int32 1 bsl set-arg1
  arg0 int32 1 + set-arg0
  repeat-frame
end

defcol bsl-to-match ( to-match n -- shifted-n bits )
  ( shift N until it's larger than to-match. Return N shifted and the number of bits it was. )
  rot swap int32 0 bsl-to-match/3
  rot drop
  rot
endcol

def int-divmod-sw/4 ( numer subtractor bit quotient )
  ( no work left with zero bits )
  arg1 int32 0 int<= IF return THEN
  ( add the bit to the quotient if numer can have subtractor subtracted )
  arg2 arg3 int<= IF
    arg2 arg3 - set-arg3
    arg0 arg1 + set-arg0
  THEN
  ( shift the subtractor & bit right )
  arg2 int32 1 bsr set-arg2
  arg1 int32 1 bsr set-arg1
  repeat-frame
end

def int-divmod-sw ( numer denom -- quotient remainder )
  ( setup args )
  arg1
  arg1 arg0 bsl-to-match ( shift the denominator left )
  int32 1 swap bsl ( start with the number bits shifted's bit set )
  int32 0
  ( do the divide )
  int-divmod-sw/4
  ( save the returns )
  set-arg1
  int32 2 dropn
  set-arg0
end

defalias> sw/ int-divmod-sw

defcol int-mod
  rot swap 2dup / * swap - swap
endcol

def test-bsl-to-match
  int32 13 int32 4 bsl-to-match write-hex-int nl write-hex-int nl
  int32 0x12345 int32 5 bsl-to-match write-hex-int nl write-hex-int nl
end

def test-int-divmod-sw
  int32 13 int32 4 int-divmod-sw write-hex-int nl write-hex-int nl
  int32 128 int32 3 int-divmod-sw write-hex-int nl write-hex-int nl
  int32 0x12345 int32 5 int-divmod-sw write-hex-int nl write-hex-int nl
end
