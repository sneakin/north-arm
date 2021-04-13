10 var> int32-precision

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
  ELSE arg0 2 return1-n
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

def inc! ( place )
  arg0 peek dup 1 + arg0 poke
  set-arg0
end

def pinc! ( place )
  arg0 peek 1 + dup arg0 poke
  set-arg0
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

def test-exp-int32
  -1 exp-int32 0 assert-equals
  0 exp-int32 1 assert-equals
  1 exp-int32 2 assert-equals
  2 exp-int32 7 assert-equals
  3 exp-int32 20 assert-equals
  4 exp-int32 54 assert-equals
  9 exp-int32 8193 assert-equals
  10 exp-int32 59874 assert-equals
end
