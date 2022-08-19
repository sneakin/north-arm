( Division: )

( todo optimize with a log2? )

def bsl-to-match/3 ( to-match n bits-left )
  arg2 arg1 uint<= IF return THEN
  arg0 32 uint>= IF return THEN
  arg1 int32 1 bsl set-arg1
  arg0 int32 1 int-add set-arg0
  repeat-frame
end

def bsl-to-match ( to-match n -- shifted-n bits )
  ( shift N until it's larger than to-match. Return N shifted and the number of bits it was. )
  arg1 arg0 int32 0 bsl-to-match/3
  set-arg0 set-arg1
end

def int-divmod-sw/4 ( numer subtractor bit quotient -- quotient remainder )
  ( no work left with zero bits )
  arg1 int32 0 uint<= IF arg0 arg3 4 return2-n THEN
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
  ( fix the sign:
       n/d => x r
       -/- => + -
       -/+ => - -
       +/+ => + +
       +/- => - +
  )
  arg1 negative? swap drop
  dup IF swap negate swap THEN
  arg0 negative? swap drop
  equals? UNLESS swap negate swap THEN
  ( save the returns )
  set-arg0 set-arg1
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
    set-arg0 set-arg1
  THEN
end

( Software implemented quotients: )

defcol int-div-sw
  rot swap int-divmod-sw drop swap
endcol

defcol uint-div-sw
  rot swap uint-divmod-sw drop swap
endcol

defalias> int-divmod int-divmod-sw
defalias> uint-divmod uint-divmod-sw
defalias> int-div int-div-sw
defalias> uint-div uint-div-sw

defcol int-mod
  rot swap int-divmod swap drop swap
endcol

defcol uint-mod
  rot swap uint-divmod swap drop swap
endcol

( Floored division: )

def floored-divmod
  arg1 arg0 int-divmod
  dup IF arg1 0 int< arg0 0 int>= logand IF arg0 int-add over 1 int-sub swap THEN THEN
  set-arg0 set-arg1
end

def floored-div
  arg1 arg0 int-divmod
  IF arg1 0 int< arg0 0 int>= logand IF 1 int-sub THEN THEN
  set-arg1 1 return0-n
end

def floored-mod
  arg1 arg0 int-divmod
  dup IF arg1 0 int< arg0 0 int>= logand IF arg0 int-add THEN THEN
  set-arg1 1 return0-n
end
