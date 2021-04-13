( Natural log: )

def float32-ln-1-loop ( x xp acc n )
  ( Calculate the series for ln[1-x] = -sum[x^k/k, k, 1, infinity]. )
  ( arg3 write-float32 space arg2 write-float32 space arg1 write-float32 space arg0 write-int nl )
  arg0 float-precision peek uint< IF
    arg3 arg2 float32-mul dup set-arg2
    arg0 int32->float32 float32-div
    arg1 float32-add set-arg1
    arg0 1 + set-arg0 repeat-frame
  ELSE
    arg1 float32-negate set-arg1
  THEN
end

def float32-ln-1 ( x )
  ( range 0 <= x < 2 but expanded x>=2 with ln[x] = -ln[1/x]. )
  arg0 2 int32->float32 float32>=
  IF arg0 float32-invert float32-ln-1 float32-negate
  ELSE 1f arg0 float32-sub 1f 0f 1 float32-ln-1-loop drop
  THEN set-arg0
end

( ln[x+1]: )
	   
def float32-ln+1-loop ( x xp acc n )
  ( Calculate the series for ln[1+x] = sum[-1^[k-1]*x^k/k, k, 1, infinity]. )
  ( arg3 write-float32 space arg2 write-float32 space arg1 write-float32 space arg0 write-int nl )
  arg0 float-precision peek uint< IF
    arg3 arg2 float32-mul dup set-arg2
    arg0 int32->float32 float32-div
    arg0 int32-even? IF float32-negate THEN
    arg1 float32-add set-arg1
    arg0 1 + set-arg0 repeat-frame
  THEN
end

def float32-ln+1 ( x )
  ( range 0 <= x < 2 but expanded x>=2 with ln[x] = -ln[1/x]. )
  arg0 2 int32->float32 float32>=
  IF arg0 float32-invert float32-ln+1 float32-negate
  ELSE arg0 -1f float32-add 1f 0f 1 float32-ln+1-loop drop
  THEN set-arg0
end

( Factorial: )

def float32-factorial-loop
  arg1 1f float32> IF
    arg1 arg0 float32-mul set-arg0
    arg1 1f float32-sub set-arg1
    repeat-frame
  ELSE arg0 2 return1-n
end

def float32-factorial
  arg0 0f float32<= IF 1f ELSE arg0 1f float32-factorial-loop THEN set-arg0
end

( Manually writen exp: )

def exp-float32-loop ( x acc numer denom limit counter -- result )
  ( sum[x^k/k!, k, 0, infinity] )
  ( combine numer and denom w/ better factoring )
  ( arg0 write-int space arg3 write-float32 space arg2 write-float32 space 4 argn write-float32 nl   )
  arg0 arg1 uint< IF
    arg3 5 argn float32-mul set-arg3
    arg2 arg0 int32->float32 float32-mul set-arg2
    arg3 arg2 float32-div
    4 argn float32-add 4 set-argn
    arg0 1 + set-arg0 repeat-frame
  ELSE 4 argn 6 return1-n
  THEN
end

def exp-float32
  arg0 0f float32-equals? IF 1f 1 return1-n THEN
  arg0 0f float32<= IF arg0 float32-negate ELSE arg0 THEN
  1f 1f 1f float-precision peek 1 exp-float32-loop
  arg0 0f float32<= IF float32-invert THEN set-arg0
end
