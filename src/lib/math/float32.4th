" src/lib/bit-fields.4th" load

23 var> float-precision

( Constants )

defcol 1f 1 int32->float32 swap endcol
defcol -1f -1 int32->float32 swap endcol
defcol 0f 0 int32->float32 swap endcol

( Bit fields: )

def float32-sign arg0 31 bit-set? set-arg0 end
def float32-exponent arg0 23 bsr 0xFF logand 127 - set-arg0 end
def float32-fraction arg0 0x7FFFFF logand set-arg0 end

def float32-set-exponent
  arg1 float32-fraction
  arg0 127 + 0xFF logand 23 bsl logior
  2 return1-n
end
  
def float32-zero-exponent arg0 0 float32-set-exponent set-arg0 end

( Comparisons: )

def float32< arg1 arg0 float32<=> 0 int< 2 return1-n end
def float32<= arg1 arg0 float32<=> 0 int<= 2 return1-n end
def float32> arg1 arg0 float32<=> 0 int> 2 return1-n end
def float32>= arg1 arg0 float32<=> 0 int>= 2 return1-n end

( Odd & even )

def float32-odd?
  arg0 float32->int32 int32-odd? set-arg0
end

def float32-even?
  arg0 float32-odd? not set-arg0
end

( Helpers: )

def float32-invert
  1f arg0 float32-div set-arg0
end

def float32-square
  arg0 dup float32-mul set-arg0
end

( Fun iteration: )

def pre-inc-float32 ( place step )
  arg1 peek arg0 float32-add dup arg1 poke 2 return1-n
end

def pre-inc-float32-fun ( place step )
  ' pre-inc-float32 arg0 partial-first
  arg1 partial-first exit-frame
end

def float32-under? ( value limit -- value yes? )
  arg1 arg0 float32< set-arg0
end

def float32-stepper ( min max step )
  arg2 here 0 0
  ' float32-under? arg1 partial-first set-local2
  local1 arg0 pre-inc-float32-fun
  local2 compose
  exit-frame
end

def fun-precision-stepper ( fn )
  0f float-precision peek int32->float32 1f float32-stepper
  arg0 compose exit-frame
end

def fun-power-series ( fn x init )
  arg0 here
  arg2 arg1 partial-first local1 partial-first
  fun-precision-stepper exit-frame
end

( todo use fun-reduce )
( Won't be any faster as manually writen loops as functions get composed every call. Some of the composed functions could be created at compile time such as steppers with constant limits. )

( Logarithms: )

( Natural log: )

( todo benchmark, optimize )

def float32-ln-1-stepper ( n done? last-term-place x -- value done? )
  ( Calculate the series for ln[1-x] = -sum[x^k/k, k, 1, infinity]. )
  arg3 0f float32> IF
    arg1 peek arg0 float32-mul dup arg1 poke
    arg3 float32-div
    set-arg3
  THEN 2 return0-n
end

def float32-ln-1-series
  ( Calculate the series for ln[1-x] = -sum[x^k/k, k, 1, infinity]. )
  ' float32-ln-1-stepper arg0 1f fun-power-series ( todo power from 1? )
  ' float32-add 0f fun-reduce/3 float32-negate set-arg0
end

def float32-ln-1 ( x )
  ( range 0 <= x < 2 but expanded x>=2 with ln[x] = -ln[1/x]. )
  arg0 2 int32->float32 float32>=
  IF arg0 float32-invert float32-ln-1 float32-negate ( fixme extraneous negates? )
  ELSE 1f arg0 float32-sub float32-ln-1-series
  THEN set-arg0
end

2 int32->float32 float32-ln-1 const> ln2

def float32-ln
  ( special cases )
  arg0 0f float32< IF float32-nan 1 return1-n THEN
  arg0 0f float32<= IF float32-negative-infinity 1 return1-n THEN
  ( log2 start's with the float's exponent )
  arg0 float32-exponent int32->float32 ln2 float32-mul
  ( zero exponent and calculate the fraction's log2 )
  arg0 0 float32-set-exponent float32-ln-1
  ( ln[y] = ln[2]*exponent + ln[fraction] )
  local0 float32-add set-arg0
end

( Log base 2: )

def float32-log2-series
  arg0 float32-ln-1 ln2 float32-div set-arg0
end

def float32-log2
  ( special cases )
  arg0 0f float32< IF float32-nan 1 return1-n THEN
  arg0 0f float32<= IF float32-negative-infinity 1 return1-n THEN
  ( log2 start's with the float's exponent )
  arg0 float32-exponent int32->float32
  ( zero exponent and calculate the fraction's log2 )
  arg0 0 float32-set-exponent float32-log2-series
  ( log2[y] = exponent + log2[fraction] )
  local0 float32-add set-arg0
end

( Any base log: )
def float32-logn
  arg1 float32-log2 arg0 float32-log2 float32-div set-arg0
end

( Factorial: )

def float32-factorial
  arg0 0f float32<=
  IF 1f
  ELSE 1f arg0 1f float32-add 1f float32-stepper ' float32-mul 1f fun-reduce/3
  THEN set-arg0
end

( Exponentials: )

( Repeated product: )
( todo could reuse and combine to half iterations )

def float32-pow-loop
  arg0 1f float32> IF
    arg2 arg1 float32-mul set-arg2
    arg0 1f float32-sub set-arg0 repeat-frame
  ELSE
    arg2 3 return1-n
  THEN
end

( todo +/-1, 0 special cases of N )
( todo fractional exponents, exp can use fractional exponents: x^y = e^[ln[x]*y];  x^[1/n] = e^[ln[x]/n] )

def float32-pow
  arg0 0f float32< IF arg1 arg0 float32-negate float32-pow float32-invert 2 return1-n THEN
  arg0 0f float32<= IF 1f 2 return1-n THEN
  arg0 1f float32<= IF arg1 2 return1-n THEN
  arg1 dup arg0 float32-pow-loop 2 return1-n
end

( To powers of e: )

( exp where the step function does the work: )

def float32-exp-stepper ( n done? last-term-place x -- term done? )
  ( .s nl arg3 write-float32 space arg2 write-hex-uint space arg1 peek write-float32 space arg0 write-float32 nl )
  arg0 arg3 float32-div
  arg1 peek float32-mul dup arg1 poke
  set-arg3 2 return0-n
end

def float32-exp-series
  ( sum[x^k/k!, k, 0, infinity] )
  ( 1 + x^2/2! + x^3/3! ... => y + y * x/k )
  ' float32-exp-stepper arg0 1f fun-power-series ' float32-add 1f fun-reduce/3 set-arg0
end

def float32-exp
  arg0 0f float32-equals? IF 1f 1 return1-n THEN
  arg0 0f float32<= IF arg0 float32-negate ELSE arg0 THEN
  float32-exp-series
  arg0 0f float32<= IF float32-invert THEN set-arg0
end

( Hyperbolic: see https://en.m.wikipedia.org/wiki/Taylor_series )

def float32-sinh-stepper ( n done? last-term-place xx -- value done? )
  ( arg3 write-float32 space arg2 write-float32 space arg1 peek write-float32 space arg0 write-float32 nl )
  ( x^3/3! * x^2/[5*4] => x^5/5! => y + y * x^2/[[2k+1]*2k] )
  arg3 2 int32->float32 float32-mul
  dup 1f float32-add float32-mul
  arg0 swap float32-div
  arg1 peek float32-mul dup arg1 poke
  set-arg3 2 return0-n
end

def float32-sinh
  ( sum[x^[2n+1] / [2n+1]!, n, 0, inf] => x + x^3/3! + x^5/5! ... )
  ( With x=0.5: 0.5 + [0.5]^3/3! + [0.5]^5/5! ... = 0.5 + 0.125/6 + 0.03125/120 => last * [0.5]^2/[2n*[2n+1]] )
  ' float32-sinh-stepper arg0 float32-square arg0 fun-power-series
  ' float32-add arg0 fun-reduce/3 set-arg0
end

def float32-cosh-stepper ( n done? last-term-place xx -- value done? )
  ( arg3 write-float32 space arg2 write-float32 space arg1 peek write-float32 space arg0 write-float32 nl )
  ( x^2/2 * x^2/4*3 => x^4/4! makes the step: y + y * x/[[2k-1]*2k] )
  arg3 2 int32->float32 float32-mul
  dup 1f float32-sub float32-mul
  arg0 swap float32-div
  arg1 peek float32-mul dup arg1 poke
  set-arg3 2 return0-n
end

def float32-cosh
  ( sum[x^[2n] / [2n]!, n, 0, inf] => x + x^2/2! + x^4/4! ... )
  ' float32-cosh-stepper arg0 float32-square 1f fun-power-series
  ' float32-add 1f fun-reduce/3 set-arg0
end

def float32-tanh
  ( sinh/cosh )
  arg0 float32-sinh
  arg0 float32-cosh
  float32-div set-arg0
end

def float32-atanh
  ( sum[x^[2n+1] / [2n+1], n, 0, inf] )
end

( Trigonometry: calculated with the hyperbolic adders but with a negated square to oscillate each term between positive and negative. )

def float32-sin
  ( sum[-1^n * x^[2n+1] / [2n+1]!, n, 0, inf] => x - x^3/3! + x^5/5! ... )
  ' float32-sinh-stepper arg0 float32-square float32-negate arg0 fun-power-series
  ' float32-add arg0 fun-reduce/3 set-arg0
end

def float32-cos
  ( sum[-1^n * x^[2n] / [2n]!, n, 0, inf] => x - x^2/2! + x^4/4! ... )
  ' float32-cosh-stepper arg0 float32-square float32-negate 1f fun-power-series
  ' float32-add 1f fun-reduce/3 set-arg0
end

def float32-tan
  ( todo optimize with its own series )
  ( sin/cos = O/H * H/A = O/A )
  arg0 float32-sin
  arg0 float32-cos
  float32-div set-arg0
end

def float32-atan
  ( sum[-1^n * x^[2n+1] / [2n+1], n, 0, inf] )
end


( Output: )

( todo take the fd, into a string )

def write-float32/2 ( n decimals )
  ( the sign )
  arg1 float32-sign IF s" -" write-string/2 THEN
  arg1 float32-abs
  ( special cases )
  dup float32-infinity float32-equals? IF s" Inf" write-string/2 2 return0-n THEN
  dup float32-nan float32-equals? IF s" NaN" write-string/2 2 return0-n THEN
  ( integer part )
  dup float32->int32 dup write-uint
  2dup int32->float32 float32-equals? UNLESS
    ( the decimal to 8 digits in output-base )
    s" ." write-string/2
    ( todo arg for fd & total number of digits )
    int32->float32 float32-sub
    output-base peek arg0 int-pow int32->float32 float32-mul
    float32->int32 arg0 write-padded-uint
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

( Test cases: )

def test-logs-fn
  arg0 write-float32 space
  arg0 float32-ln-1
  ( arg0 float32-ln+1 )
  arg0 float32-log2
  arg0 float32-ln
  ( write-float32 space ) write-float32 space write-float32 space write-float32 nl
  1 return0-n
end

def map-float32-range ( init max step fn )
  arg3 arg0 exec-abs
  arg3 arg1 float32-add set-arg3
  arg3 arg2 float32< IF repeat-frame ELSE exit-frame THEN
end

def test-exp-float32
  -1 exp-float32 float32->int32 0 assert-equals
  0 exp-float32 float32->int32 1 assert-equals
  1 exp-float32 float32->int32 2 assert-equals
  2 exp-float32 float32->int32 7 assert-equals
  3 exp-float32 float32->int32 20 assert-equals
  9 exp-float32 float32->int32 8193 assert-equals
  10 exp-float32 float32->int32 59874 assert-equals
end
