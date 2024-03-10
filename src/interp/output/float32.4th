( 32 bit floating point output: )

( todo take an fd asjankarg )

4 var> output-precision

def float32->string/5 ( str max-len n decimals offset -- str real-len )
  ( the sign )
  arg2 float32-sign IF
    45 4 argn arg0 string-poke
    arg0 1 + set-arg0
  THEN
  arg2 float32-abs set-arg2
  ( special cases )
  arg2 float32-infinity float32-equals? IF
    s" Inf"
    4 argn arg0 +
    swap 1 + arg3 umin
    copy
    4 argn 4 arg3 umin 5 return2-n
  THEN
  arg2 float32-nan float32-equals? IF
    s" NaN"
    4 argn arg0 +
    swap 1 + arg3 umin
    copy
    4 argn 4 arg3 umin 5 return2-n
  THEN
  ( integer part )
  arg2 float32->uint32
  dup 4 argn arg0 + arg3 arg0 - uint->string/3
  arg0 + set-arg0 drop
  dup uint32->float32 arg2 float32-equals? UNLESS
    ( the decimal to 8 digits in output-base )
    46 4 argn arg0 string-poke
    arg0 1 + set-arg0
    ( and the fraction )
    uint32->float32 arg2 swap float32-sub
    output-base peek arg1 int-pow uint32->float32 float32-mul
    float32->uint32 4 argn arg0 + arg3 arg0 - arg1 umin uint->padded-string/3
    arg0 + set-arg0 drop
  THEN 4 argn arg0 2dup null-terminate 5 return2-n
end

def float32->string/4 ( str max-len n decimals -- str real-len )
  0 ' float32->string/5 tail+1
end

def float32->string ( str max-len n -- str real-len )
  output-precision @ ' float32->string/4 tail+1
end

def write-float32/2 ( n decimals )
  ( the sign )
  arg1 float32-sign IF s" -" write-string/2 THEN
  arg1 float32-abs
  ( special cases )
  dup float32-infinity float32-equals? IF s" Inf" write-string/2 2 return0-n THEN
  dup float32-nan float32-equals? IF s" NaN" write-string/2 2 return0-n THEN
  ( integer part )
  dup float32->uint32 dup write-uint
  2dup uint32->float32 float32-equals? UNLESS
    ( the decimal to 8 digits in output-base )
    s" ." write-string/2
    ( todo arg for fd & total number of digits )
    uint32->float32 float32-sub
    output-base peek arg0 int-pow uint32->float32 float32-mul
    float32->uint32 arg0 write-padded-uint
  THEN
  2 return0-n
end

def write-float32 ( n ) arg0 output-precision @ write-float32/2 1 return0-n end

def dump-float32
  arg0 dup bin write-uint dec
  dup space write-float32
  dup float32-exponent space write-int
  dup float32-zero-exponent space write-float32 nl
end

defcol .f swap write-float32 endcol
defcol ,f over write-float32 endcol
