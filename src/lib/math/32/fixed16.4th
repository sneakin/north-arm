( s[ src/lib/math.4th src/lib/math/int64.4th src/runner/math/fixed.4th ] load-list )

0x8000 const> fixed16-1/2
0x10000 const> fixed16-one
0xb504f333 const> fixed-sqrt-2 ( sqrt[2] << 31 )
45426 const> fixed-LN2 ( 0.6931471805599453 << 16 )
( 94548 ) 0xb8aa3b29 const> fixed-1/LN2 ( 1 / 0.6931471805599453 << 31 )
0x2B7DE const> fixed16-e ( e<<16 )
0x76387 const> fixed16-ee ( e**2 << 16 )
0x14159B const> fixed16-eee ( e**3 << 16 )
0x1921fb544 const> fixed-pi ( pi << 31 )
0x3243f const> fixed16-pi

def fixed16-truncate
  arg0 0xFFFF lognot logand return1-1
end

def fixed16-fraction
  arg0 0xFFFF logand return1-1
end

def fixed16->int32
  arg0 16 bsr return1-1
end

def int32->fixed16
  arg0 16 bsl return1-1
end

alias> uint32->fixed16 int32->fixed16
alias> fixed16->uint32 fixed16->int32

def fixed16->float32
  arg0 int32->float32 0x10000 int32->float32 float32-div return1-1
end

def ufixed16->float32
  arg0 uint32->float32 0x10000 uint32->float32 float32-div return1-1
end

def float32->fixed16
  arg0 fixed16-one int32->float32 float32-mul float32->int32 return1-1
end

def float32->ufixed16
  arg0 fixed16-one int32->float32 float32-mul float32->uint32 return1-1
end

alias> fixed16< int<
alias> fixed16<= int<=
alias> fixed16> int>
alias> fixed16>= int>=

alias> ufixed16< uint<
alias> ufixed16<= uint<=
alias> ufixed16> uint>
alias> ufixed16>= uint>=

def fixed16-add
  arg1 arg0 + 2 return1-n
end

def fixed16-sub
  arg1 arg0 - 2 return1-n
end

alias> fixed16-negate negate
alias> fixed16-abs abs-int

def fixed16-mul
  arg1 arg0 int-mulc 16 int64-absr drop 2 return1-n
end

def fixed16-div ( fixed fixed -- fixed )
  arg1 0 16 int64-bsl arg0 int64-div32 drop 2 return1-n
end

def ufixed16-div-int32 ( fixed int32 -- fixed )
  arg1 0 arg0 uint64-div32 drop 2 return1-n
end

def fixed16-div-int32 ( fixed int32 -- fixed )
  arg1 0 arg0 int64-div32 drop 2 return1-n
end

def fixed16-reciprocal
  0 1 arg0 int64-div32 drop return1-1
end

def fixed16-reciprocal32 ( fixed16 -- fixed32 )
  0 0x10000 arg0 int64-div32 drop return1-1
end

def parse-fixed16 ( str len -- n valid? )
  ( todo no float )
  arg1 arg0 parse-float32
  IF float32->fixed16 true ELSE 0 false THEN 2 return2-n
end

def fixed16->string ( out-ptr len n -- out-ptr real-len )
  ( todo no float )
  arg2 arg1 arg0 fixed16->float32 float32->string
  3 return2-n
end

def write-fixed16
  ( todo no float )
  arg0 fixed16->float32 write-float32
  1 return0-n
end

def exp-fixed16-loop ( x acc numer-lo numer-hi denom limit counter -- result )
  ( sum[x^k/k!, k, 0, infinity] )
  ( pow and factorial build up in the loop )
  ( arg0 write-int space 4 argn arg3 write-hex-int64 space arg2 write-hex-int space 5 argn write-hex-int nl )
  arg0 arg1 uint< IF
    4 argn arg3 6 argn 0 int64-mul 16 int64-absr set-arg3 4 set-argn
    arg2 arg0 int-mul set-arg2
    4 argn arg3 arg2 int64-div32
    5 argn 0 int64-add drop 5 set-argn
    arg0 1 + set-arg0 repeat-frame
  ELSE 5 argn 7 return1-n
  THEN
end

( With a limited range of 0...4, a loop multiplying by e while subtracting the exponent  by 1 until the range works. )

def exp-fixed16-big-exp-loop ( acc exp -- acc new-exp )
  arg0 3 int32->fixed16 fixed16< IF return0 THEN
  arg0 4 int32->fixed16 fixed16<
  IF 1 fixed16-e
  ELSE				    
    arg0 6 int32->fixed16 fixed16<
    IF 2 fixed16-ee
    ELSE 3 fixed16-eee
    THEN
  THEN
  arg1 fixed16-mul set-arg1
  int32->fixed16 arg0 swap fixed16-sub set-arg0 repeat-frame
end

( Breaks down when the exponent is >= 11.5. 16 bits overflows at that point. )

def exp-fixed16
  ( arg0 0 fixed16< IF 0 int32->fixed16 1 return1-n THEN )
  arg0 0 fixed16< IF arg0 negate exp-fixed16 fixed16-reciprocal return1-1 THEN
  ( arg0 1 int32->fixed16 fixed16< IF 1 int32->fixed16 1 return1-n THEN )
  1 int32->fixed16 arg0 exp-fixed16-big-exp-loop
  1 int32->fixed16 dup 0 1 int32-precision peek 1 exp-fixed16-loop
  fixed16-mul return1-1
end

def ln-fixed16-loop ( n guess counter -- log2<<16 )
  ( Use Newton's method to calculate the fraction. )
  ( y = ln[x] -> e**y = x )
  ( f[y] = e**y - x = 0 )
  ( f'[y] = e**y )
  ( f / f1 = 1 - x/[e**y] )
  ( x1 = x0 - f[x0] / f'[x0] )
  arg0 0 uint> UNLESS arg1 3 return1-n THEN
  arg1
    1 int32->fixed16
      arg2 arg1 exp-fixed16 fixed16-div
    fixed16-sub
  fixed16-sub set-arg1
  arg0 1 - set-arg0 repeat-frame
end

def ln-fixed16
  ( ln[x] = -ln[1/x] )
  ( 0x1000 int32->fixed16 arg0 fixed16< IF
    arg0 fixed16-reciprocal ln-fixed16
    negate return1-1
  ELSE )
    arg0
    arg0 fixed16->int32 badlog2-uint int32->fixed16
    8 ln-fixed16-loop return1-1
( THEN )
end

def pow-fixed16
  arg0 0 equals? IF fixed16-one 2 return1-n THEN
  arg0 arg1 ln-fixed16 fixed16-mul exp-fixed16 2 return1-n
end

def pow2-fixed16
  arg0 0 equals? IF fixed16-one return1-1 THEN
  1 arg0 fixed16->int32 bsl int32->fixed16
  2 int32->fixed16 arg0 fixed16-fraction pow-fixed16
  fixed16-mul return1-1
end

def log2-fixed16
  arg0 ln-fixed16 fixed-1/LN2 15 bsr fixed16-mul return1-1
end

def sqrt-fixed16
  ( range seems to error out after 24000 )
  arg0 ln-fixed16 fixed16-1/2 fixed16-mul exp-fixed16 return1-1
end

def fixed16-stepper ( fn min max step ++ )
  arg2 arg1 fixed16< UNLESS exit-frame THEN
  arg2 arg3 exec-abs
  arg2 arg0 fixed16-add set-arg2 repeat-frame
end

def test-ln-fixed16-fn
  arg0 write-fixed16 space
  arg0 ln-fixed16 write-fixed16 nl
  1 return0-n
end

def test-ln-fixed16 ( min max step -- )
  ' test-ln-fixed16-fn arg2 arg1 arg0 fixed16-stepper
  3 return0-n
end

def test-sqrt-fixed16-fn
  arg0 write-fixed16 space
  arg0 sqrt-fixed16 write-fixed16 nl
  1 return0-n
end

def test-sqrt-fixed16 ( min max step -- )
  ' test-sqrt-fixed16-fn arg2 arg1 arg0 fixed16-stepper
  3 return0-n
end

