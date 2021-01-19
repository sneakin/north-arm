( Comparisons: )

defcol int>
  rot int< swap
endcol

defcol int>=
  rot int<= swap
endcol

defcol uint>
  rot uint< swap
endcol

defcol uint>=
  rot uint<= swap
endcol

( Signed operations: )

def negative?
  arg0 int32 0 int< return1
end

def abs-int
  arg0 negative? IF negate THEN set-arg0
end

( Division: )

def bsl-to-match/3 ( to-match n bits-left )
  arg2 arg1 uint<= IF return THEN
  arg0 32 uint>= IF return THEN
  arg1 int32 1 bsl set-arg1
  arg0 int32 1 int-add set-arg0
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
  arg1 int32 0 uint<= IF return THEN
  ( add the bit to the quotient if numer can have subtractor subtracted )
  arg2 arg3 uint<= IF
    arg3 arg2 int-sub set-arg3
    arg0 arg1 int-add set-arg0
  THEN
  ( shift the subtractor & bit right )
  arg2 int32 1 bsr set-arg2
  arg1 int32 1 bsr set-arg1
  repeat-frame
end

def int-divmod-sw ( numer denom -- quotient remainder )
  ( setup args )
  arg1 abs-int
  dup arg0 abs-int bsl-to-match ( shift the denominator left )
  int32 1 swap bsl ( start with the number bits shifted's bit set )
  int32 0
  ( do the divide )
  int-divmod-sw/4
  ( fix the sign )
  arg1 negative? swap drop
  IF arg0 negative? swap drop UNLESS negate THEN
  ELSE arg0 negative? swap drop IF negate THEN
  THEN
  ( save the returns )
  set-arg1
  int32 2 dropn
  set-arg0
end

( Unsigned division: )

def uint-divmod-sw ( numer denom -- quotient remainder )
  ( setup args )
  arg1
  dup arg0 bsl-to-match ( shift the denominator left )
  ( if the shift is 32 bits, then the high or low bit needs to be specially handled. The low bit is one so that's this case: )
  dup int32 32 uint>= IF
    ( shift numer right and divide )
    2 dropn
    1 bsr arg0 uint-divmod-sw
    ( shift quotient and remainder left )
    swap 1 bsl swap 1 bsl
    ( add the low bit into the remainder )
    arg1 1 logand int-add
    ( is the remainder divisible? )
    dup arg0 uint>= IF
      arg0 int-sub
      swap 1 int-add swap
    THEN
    ( set return values )
    set-arg0
    set-arg1
  ELSE
    int32 1 swap bsl ( start with the number bits shifted's bit set )
    int32 0
    ( do the divide )
    int-divmod-sw/4
    ( save the returns )
    set-arg1
    int32 2 dropn
    set-arg0
  THEN
end

( Software implemented quotients: )

defcol int-div-sw
  rot swap int-divmod-sw drop swap
endcol

defcol uint-div-sw
  rot swap uint-divmod-sw drop swap
endcol

( Thumb2 divmod, divide and then multiply and subtract for the remainder: )

defcol int-divmod-v2
  rot swap
  2dup int-div-v2 ( num den quot )
  rot swap 3 overn int-mul int-sub abs-int
  swap rot
endcol

defcol uint-divmod-v2
  rot swap
  2dup uint-div-v2 ( num den quot )
  rot swap 3 overn int-mul int-sub
  swap rot
endcol

defalias> int-divmod int-divmod-sw
defalias> uint-divmod uint-divmod-sw

defcol int-mod
  rot swap int-divmod swap drop swap
endcol

defcol uint-mod
  rot swap uint-divmod swap drop swap
endcol

defalias> int-div int-div-sw
defalias> uint-div uint-div-sw
