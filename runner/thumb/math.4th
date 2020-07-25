( Comparisons: )

defcol int>
  rot int< IF int32 1 ELSE int32 0 THEN swap
endcol

defcol int>=
  rot int<= IF int32 1 ELSE int32 0 THEN swap
endcol

defalias> > int>
defalias> >= int>=
defalias> < int<
defalias> <= int<=

defcol uint>
  rot uint< IF int32 1 ELSE int32 0 THEN swap
endcol

defcol uint>=
  rot uint<= IF int32 1 ELSE int32 0 THEN swap
endcol


( Numbers: )

defcol negative?
  over int32 0 int< swap
endcol

defcol one
  int32 1 swap
endcol

defcol zero
  int32 0 swap
endcol

( Division: )

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
