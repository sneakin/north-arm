DEFINED? defvar> IF
  10 defvar> int32-precision
  0x7FFFFFFF defconst> INT32-MAX
  -0x7FFFFFFF defconst> INT32-MIN
  0xFFFFFFFF defconst> UINT32-MAX
ELSE
  10 var> int32-precision
  0x7FFFFFFF const> INT32-MAX
  -0x7FFFFFFF const> INT32-MIN
  0xFFFFFFFF const> UINT32-MAX
THEN

def sign-extend-from ( value bit -- extended )
  arg1 1 arg0 bsl logand
  IF 1 arg0 1 + bsl 1 - ( bit-mask ) lognot arg1 logior
  ELSE arg1
  THEN 2 return1-n
end

def sign-extend-byte
  arg0 7 sign-extend-from set-arg0
end

def int32-odd?
  arg0 1 logand set-arg0
end

def int32-even?
  arg0 int32-odd? not set-arg0
end

def int32-factorial-loop
  arg1 1 uint> IF
    arg1 arg0 int-mul set-arg0
    arg1 1 int-sub set-arg1
    repeat-frame
  THEN arg0 2 return1-n
end

def int32-factorial
  arg0 0 int<= IF 1 ELSE arg0 1 int32-factorial-loop THEN set-arg0
end

def slow-exp-int32-loop ( exponent acc limit counter -- result )
  ( sum[x^k/k!, k, 0, infinity] )
  arg0 write-int space arg3 write-int space arg2 write-int nl
  arg0 arg1 uint< IF
    arg3 arg0 int-pow arg0 int32-factorial uint-div arg2 int-add set-arg2
    arg0 1 + set-arg0
    repeat-frame
  ELSE arg2 4 return1-n
  THEN
end

def slow-exp-int32
  arg0 0 int< IF 0 1 return1-n THEN
  arg0 1 int< IF 1 1 return1-n THEN
  arg0 2 int< IF 2 1 return1-n THEN
  arg0 0 int32-precision peek 0 slow-exp-int32-loop set-arg0
end

def exp-int32-loop ( x acc numer denom limit counter -- result )
  ( sum[x^k/k!, k, 0, infinity] )
  ( pow and factorial build up in the loop )
  arg0 write-int space arg3 write-int space arg2 write-int space 4 argn write-int nl
  arg0 arg1 uint< IF
    arg3 5 argn int-mul set-arg3
    arg2 arg0 int-mul set-arg2
    arg3 arg2 uint-div
    4 argn int-add 4 set-argn
    arg0 1 + set-arg0 repeat-frame
  ELSE 4 argn 6 return1-n
  THEN
end

( A very rough estimate: )
def exp-int32
  arg0 0 int< IF 0 1 return1-n THEN
  arg0 1 int< IF 1 1 return1-n THEN
  arg0 2 int< IF 2 1 return1-n THEN
  arg0 1 1 1 int32-precision peek 1 exp-int32-loop 1 return1-n
end

def dotimes
  arg0 0 uint> IF
    arg0 1 - set-arg0
    arg0 arg1 exec-abs
    repeat-frame
  ELSE
    exit-frame
  THEN
end

def int32-seq-gen
  arg0 1 return1-n
end

def int32-seq
  pointer int32-seq-gen arg0 dotimes
  here arg0 exit-frame
end

( todo swap place and n so it reads as an op on place? )

def inc!/2 ( place n -- value+n )
  arg1 peek arg0 + dup arg1 poke
  2 return1-n
end

def inc! ( place -- value+1 ) arg0 1 inc!/2 set-arg0 end

def dec!/2 ( place n -- value-n )
  arg1 peek arg0 - dup arg1 poke
  2 return1-n
end

def dec! ( place -- n-1 ) arg0 1 dec!/2 set-arg0 end  

def pinc! ( place )
  arg0 peek 1 + dup arg0 poke
  set-arg0
end

def wrapped-inc!/3 ( place max amount -- wrapped? )
  arg2 dup @ arg0 +
  dup arg1 int>=
  IF arg1 - true
  ELSE false
  THEN rot ! 3 return1-n
end

def wrapped-inc! ( place max -- wrapped? )
  arg1 arg0 1 wrapped-inc!/3 2 return1-n
end

def wrapped-dec!/3 ( place max amount -- wrapped? )
  arg2 dup @ arg0 -
  dup 0 int<
  IF arg1 + true
  ELSE false
  THEN rot ! 3 return1-n
end

def wrapped-dec! ( place max -- wrapped? )
  arg1 arg0 1 wrapped-dec!/3 2 return1-n
end

def under? ( value limit -- value yes? )
  arg1 arg0 uint< set-arg0
end

def counter-fn
  0 here ' inc! swap partial-first exit-frame
end

def uint32-stepper ( min max )
  arg1 here 0 0
  ' under? arg0 partial-first set-local2
  ' pinc! local1 partial-first
  local2 compose
  exit-frame
end

def fun-factorial-int32
  1 arg0 1 + uint32-stepper ' int-mul 1 fun-reduce/3 set-arg0
end

NORTH-STAGE 0 equals?
IF true ELSE
  SYS:DEFINED? builder-target-bits IF
    builder-target-bits @
  ELSE NORTH-BITS
  THEN 32 equals? ( fixme the host or target? )
THEN IF
  s[ src/lib/math/32/int32.4th ] load-list
THEN
