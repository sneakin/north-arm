( Numbers: )

defcol one
  int32 1 swap
endcol

defcol zero
  int32 0 swap
endcol

defcol minmax rot 2dup int< IF swap THEN rot endcol
defcol maxmin rot 2dup int> IF swap THEN rot endcol
defcol min rot minmax drop swap endcol
defcol max rot maxmin drop swap endcol

def in-range? ( n max min )
  arg2 arg1 int<=
  arg2 arg0 int>= and return1
end

defcol uminmax rot 2dup uint< IF swap THEN rot endcol
defcol umaxmin rot 2dup uint> IF swap THEN rot endcol
defcol umin rot uminmax drop swap endcol
defcol umax rot umaxmin drop swap endcol

def uint-in-range? ( n max min )
  arg2 arg1 uint<=
  arg2 arg0 uint>= and return1
end

def bit-mask
  1 arg0 bsl 1 int-sub set-arg0
end

( todo optimize by counting down? divide & conquer? )


def badlog2-uint-loop ( n log -- log )
  arg1 1 uint<= IF arg0 2 return1-n THEN
  arg1 1 bsr set-arg1
  arg0 1 int-add set-arg0 repeat-frame
end

def badlog2-shift-for-precision ( bits-shifted n ++ )
  arg0 1 uint> arg0 0x10000 uint< and IF
    arg1 1 int-add set-arg1
    arg0 dup int-mul set-arg0
    repeat-frame
  THEN
end

def badlog2-uint ( n -- log2ish )
  0 arg0 badlog2-shift-for-precision 0 badlog2-uint-loop
  local0 absr return1-1
end

def badlog2-ufixed16 ( n -- log2ish )
  0 arg0 badlog2-shift-for-precision 0 badlog2-uint-loop
  16 local0 int-sub bsl return1-1
end

def badlog2-int ( n -- log2ish )
  1 arg0 int<=
  IF arg0 badlog2-uint
  ELSE 0 ( " range error" error )
  THEN return1-1
end

def badlogn-uint->fixed16 ( n e -- log_e_N )
  arg1 badlog2-ufixed16
  arg0 badlog2-uint
  uint-div 2 return1-n
end

DEFINED? fixed16-ceil IF
def badlogn-uint ( n e -- log_e_N )
  arg1 arg0 badlogn-uint->fixed16 fixed16-ceil 2 return1-n
end
ELSE
def badlogn-uint ( n e -- log_e_N )
  arg1 arg0 badlogn-uint->fixed16
  ( fixed16-ceil )
  dup 0xFFFF logand 0x0 uint> IF 0x10000 int-add THEN
  16 absr 2 return1-n
end
THEN

( todo optimize by recursively apply exponent/2 )

def uint-pow-loop
  arg0 1 uint> IF
    arg2 arg1 int-mul set-arg2
    arg0 1 int-sub set-arg0 repeat-frame
  ELSE
    arg2 3 return1-n
  THEN
end

def uint-pow
  arg0 0 uint<= IF 1 2 return1-n THEN
  arg0 1 uint<= IF arg1 2 return1-n THEN
  arg1 dup arg0 uint-pow-loop 2 return1-n
end

def int-pow
  arg0 0 int< IF 0 2 return1-n THEN
  arg0 0 int<= IF 1 2 return1-n THEN
  arg0 1 int<= IF arg1 2 return1-n THEN
  arg0 0xFFFFFFFF arg1 badlogn-uint int> IF 0 2 return1-n THEN ( todo error or big math )
  arg1 dup arg0 uint-pow-loop 2 return1-n
end
