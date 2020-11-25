( Numbers: )

defcol negative?
  over uint32 0x80000000 logand swap
endcol

defcol one
  int32 1 swap
endcol

defcol zero
  int32 0 swap
endcol

def in-range? ( n max min )
  arg2 arg1 int<=
  arg2 arg0 int>= and return1
end

defcol cell/
  swap int32 2 bsr swap
endcol
