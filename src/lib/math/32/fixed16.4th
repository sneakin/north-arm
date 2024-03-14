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

alias> fixed16-equals? equals?
alias> fixed16-negate negate
alias> fixed16-abs abs-int

def fixed16-truncate
  arg0 0xFFFF lognot logand return1-1
end

def fixed16-fraction
  arg0 0xFFFF logand return1-1
end

def fixed16-signed-fraction
  arg0 0xFFFF logand arg0 0 int< IF fixed16-negate THEN return1-1
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

def fixed16-sign
  arg0 0 fixed16< return1-1
end

def fixed16-add
  arg1 arg0 + 2 return1-n
end

def fixed16-addc
  arg1 arg0 int-addc 2 return2-n
end

def ufixed16-addc
  arg1 arg0 uint-addc 2 return2-n
end

def fixed16-sub
  arg1 arg0 - 2 return1-n
end

def fixed16-mul
  arg1 arg0 int-mulc 16 int64-absr drop 2 return1-n
end

def fixed16-mul-int32
  arg1 arg0 int-mul 2 return1-n
end

def fixed16-mul-int32->int32
  arg1 arg0 int-mulc 16 int64-absr drop 2 return1-n
end

def fixed16-div ( fixed fixed -- fixed )
  arg1 0 16 int64-bsl arg0 int64-div32 drop 2 return1-n
end

def ufixed16-div ( fixed fixed -- fixed )
  arg1 0 16 int64-bsl arg0 uint64-div32 drop 2 return1-n
end

def ufixed16-div-int32 ( fixed int32 -- fixed )
  arg1 0 arg0 uint64-div32 drop 2 return1-n
end

def fixed16-div-int32 ( fixed int32 -- fixed )
  arg1 0 arg0 int64-div32 drop 2 return1-n
end

def int-div->ufixed16 ( int32 int32 -- fixed )
  arg1 0 16 int64-bsl arg0 uint64-div32 drop 2 return1-n
end

def fixed16-reciprocal
  0 1 arg0 int64-div32 drop return1-1
end

def fixed16-reciprocal32 ( fixed16 -- fixed32 )
  0 0x10000 arg0 int64-div32 drop return1-1
end

def parse-ufixed16 ( str len -- n valid? )
  ( \d+\.\d+e\d+ )
  arg0 0 equals? IF 0 int32->fixed16 false 2 return2-n THEN
  ( whole number )
  arg1 arg0 input-base @ 0 0 parse-uint-loop
  3 overn 0 equals? not ( to detect " ." )
  arg1 5 overn string-peek decimal-point?
  and IF
    ( the fraction )
    drop
    5 overn 5 overn 5 overn 5 overn 1 + 0 parse-uint-loop
    UNLESS 0 int32->fixed16 false 2 return2-n
    ELSE
      ( input-base ** [offset2 - offset1 - 1] )
      input-base @ 3 overn 9 overn - 1 - int-pow int-div->ufixed16
      6 overn uint32->fixed16 fixed16-add
    THEN
  ELSE
    ( just a whole or invalid number )
    ( todo return an integer here so interp-token can skip reparsing )
    IF uint32->fixed16 ELSE 0 int32->fixed16 false 2 return2-n THEN
  THEN
  true 2 return2-n
end

def parse-fixed16 ( str len -- n valid? )
  ( [-+]\d+\.\d+ )
  ( sign in local0 )
  arg1 0 string-peek minus-sign?
  arg1 0 string-peek plus-sign?
  over or IF
    arg1 1 + set-arg1
    arg0 1 - set-arg0
  THEN
  arg1 arg0 parse-ufixed16 UNLESS false 2 return2-n THEN
  ( apply the sign )
  local0 IF fixed16-negate THEN true 2 return2-n
end

def ufixed16->string/5 ( str max-len n decimals offset -- str real-len )
  ( integer part )
  arg2 fixed16->uint32
  dup 4 argn arg0 + arg3 arg0 - uint->string/3
  arg0 + set-arg0 drop
  dup uint32->fixed16 arg2 fixed16-equals? UNLESS
    ( the decimal to 8 digits in output-base )
    46 4 argn arg0 string-poke
    arg0 1 + set-arg0
    ( and the fraction )
    uint32->fixed16 arg2 swap fixed16-sub
    output-base peek arg1 int-pow fixed16-mul-int32->int32
    4 argn arg0 + arg3 arg0 - arg1 umin uint->padded-string/3
    arg0 + set-arg0 drop
  THEN 4 argn arg0 2dup null-terminate 5 return2-n
end

def fixed16->string/5 ( str max-len n decimals offset -- str real-len )
  ( the sign )
  arg2 fixed16-sign IF
    45 4 argn arg0 string-poke
    arg0 1 + set-arg0
    arg2 fixed16-negate set-arg2
  THEN
  ' ufixed16->string/5 tail-0
end

def fixed16->string/4 ( str max-len n decimals -- str real-len )
  0 ' fixed16->string/5 tail+1
end

def ufixed16->string/4 ( str max-len n decimals -- str real-len )
  0 ' ufixed16->string/5 tail+1
end

def fixed16->string ( str max-len n -- str real-len )
  output-precision @ ' fixed16->string/4 tail+1
end

def ufixed16->string ( str max-len n -- str real-len )
  output-precision @ ' ufixed16->string/4 tail+1
end

def write-ufixed16/2 ( n decimals )
  ( integer part )
  arg1 dup fixed16->uint32 dup write-uint
  2dup uint32->fixed16 fixed16-equals? UNLESS
    ( the decimal to 8 digits in output-base )
    s" ." write-string/2
    ( todo arg for fd & total number of digits )
    uint32->fixed16 fixed16-sub
    output-base peek arg0 int-pow fixed16-mul-int32->int32
    arg0 write-padded-uint
  THEN
  2 return0-n
end

def write-fixed16/2 ( n decimals )
  ( the sign )
  arg1 fixed16-sign IF
    s" -" write-string/2
    arg1 fixed16-negate set-arg1
  THEN
  ' write-ufixed16/2 tail-0
end

def write-fixed16 ( n )
  arg0 output-precision @ write-fixed16/2 1 return0-n
end

def write-ufixed16 ( n )
  arg0 output-precision @ write-ufixed16/2 1 return0-n
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

( todo break the exponent down by /2 )

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

def ln-fixed16-loop ( n guess counter -- log-fixed16 )
  ( Use Newton's method to calculate the fraction. )
  ( y = ln[x] -> e**y = x )
  ( f[y] = e**y - x = 0 )
  ( f'[y] = e**y )
  ( f / f1 = 1 - x/[e**y] )
  ( y1 = y0 - f[y0] / f'[y0] )
  arg0 0 uint> UNLESS arg1 3 return1-n THEN
  arg1
    fixed16-one
      arg2 arg1 exp-fixed16 fixed16-div
    fixed16-sub
  fixed16-sub set-arg1
  arg0 1 - set-arg0 repeat-frame
end

0x15000000 ( 0x7FFFFFFF ) var> fixed16-ln-cut-off

def ln-fixed16
  ( ln[x] = -ln[1/x] )
  arg0 fixed16-ln-cut-off @ fixed16< IF
    arg0
    arg0 fixed16->int32 badlog2-uint int32->fixed16
    int32-precision @ ln-fixed16-loop return1-1
  ELSE
    arg0 fixed16-reciprocal ln-fixed16
    negate return1-1
  THEN
end

def pow-fixed16
  arg0 0 equals? IF fixed16-one 2 return1-n THEN
  arg1 0 int<
  dup arg0 fixed16-fraction 0 int> and IF
    0
  ELSE
    arg0 arg1 fixed16-abs ln-fixed16 fixed16-mul exp-fixed16
    local0 IF arg0 fixed16->int32 int32-odd? IF fixed16-negate THEN THEN
  THEN 2 return1-n
end

def pow2-fixed16
  arg0 0 equals? IF fixed16-one return1-1 THEN
  arg0 0 int< IF
    2 int32->fixed16 arg0 pow-fixed16
  ELSE
    2 int32->fixed16 arg0 fixed16-fraction pow-fixed16
    1 arg0 fixed16->int32 bsl int32->fixed16 fixed16-mul
  THEN return1-1
end

def log2-fixed16
  arg0 ln-fixed16 fixed-1/LN2 15 bsr fixed16-mul return1-1
end

def sqrt-fixed16
  ( domain seems to error out after 24000 )
  arg0 ln-fixed16 fixed16-1/2 fixed16-mul exp-fixed16 return1-1
end

def map-fixed16-range ( fn min max step ++ )
  arg2 arg1 fixed16< UNLESS exit-frame THEN
  arg2 arg3 exec-abs
  arg2 arg0 fixed16-addc
  over swap arg1 0 int64< UNLESS exit-frame THEN
  set-arg2 repeat-frame
end

def map-ufixed16-range ( fn min max step ++ )
  arg2 arg1 ufixed16< UNLESS exit-frame THEN
  arg2 arg3 exec-abs
  arg2 arg0 ufixed16-addc IF exit-frame THEN
  set-arg2 repeat-frame
end
