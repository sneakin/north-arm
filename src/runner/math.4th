( Numbers: )

defcol one
  int32 1 swap
endcol

defcol zero
  int32 0 swap
endcol

defcol minmax rot 2dup int> IF swap THEN swap rot endcol
defcol min rot minmax drop swap endcol
defcol max rot minmax swap drop endcol

def in-range? ( n max min )
  arg2 arg1 int<=
  arg2 arg0 int>= and return1
end

defcol cell/
  swap int32 2 bsr swap
endcol

( todo optimize by counting down? divide & conquer? )

def badlog2-uint-loop
  arg1 1 uint<= IF arg0 2 return1-n THEN
  arg1 1 bsr set-arg1
  arg0 1 int-add set-arg0 repeat-frame
end

defcol badlog2-uint swap 0 badlog2-uint-loop swap endcol

defcol badlog2-int
  swap 0 over int<
  IF badlog2-uint
  ELSE 0 ( " range error" error )
  THEN swap
endcol

def badlogn-uint
  arg1 badlog2-uint arg0 badlog2-uint uint-div 2 return1-n
end

( todo optimize by recursively apply exponent/2 )

def int-pow-loop
  arg0 1 uint> IF
    arg2 arg1 int-mul set-arg2
    arg0 1 int-sub set-arg0 repeat-frame
  ELSE
    arg2 3 return1-n
  THEN
end

def int-pow
  arg0 0 int< IF 0 2 return1-n THEN
  arg0 0 int<= IF 1 2 return1-n THEN
  arg0 1 int<= IF arg1 2 return1-n THEN
  arg0 0xFFFFFFFF arg1 badlogn-uint int> IF ( todo error or big math ) 0 2 return1-n THEN
  arg1 dup arg0 int-pow-loop 2 return1-n
end
