( 32 bit floating point output: )

( todo take the fd, into a string )

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

def write-float32 ( n ) arg0 6 write-float32/2 1 return0-n end

def dump-float32
  arg0 dup bin write-uint dec
  dup space write-float32
  dup float32-exponent space write-int
  dup float32-zero-exponent space write-float32 nl
end

alias> .f write-float32
defcol ,f over write-float32 endcol
