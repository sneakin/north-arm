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
