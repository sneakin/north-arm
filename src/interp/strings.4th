( String operations: )

( Comparisons: )

( fixme "boo" == "boot"? Need to check lengths on both. Checking for 0 byte at end works, but not perfect. )

def byte-string-compare/3 ( a-str b-str length )
  arg0 int32 0 uint> UNLESS int32 0 3 return1-n THEN
  arg2 peek-byte
  arg1 peek-byte
  int<=> dup IF 3 return1-n ELSE drop THEN
  arg0 int32 1 - set-arg0
  arg1 int32 1 + set-arg1
  arg2 int32 1 + set-arg2
  repeat-frame
end

def byte-string-equals?/3 ( a-str b-str length )
  arg2 0 equals? arg1 0 equals? or IF
    arg2 arg1 equals? return1
  THEN
  arg0 int32 0 uint> UNLESS int32 1 return1 THEN
  arg2 peek-byte
  arg1 peek-byte
  equals? UNLESS int32 0 return1 THEN
  arg0 int32 1 - set-arg0
  arg1 int32 1 + set-arg1
  arg2 int32 1 + set-arg2
  repeat-frame
end

def byte-string0-equals?/3 ( a-str b-str length )
  arg2 arg1 arg0 byte-string-equals?/3 IF
    drop peek-byte
    swap peek-byte
    equals?
  ELSE int32 0
  THEN return1
end

def string-equals?/3 ( a-str b-str length )
  arg2 0 equals? arg1 0 equals? or IF
    arg2 arg1 equals? return1
  THEN
  arg0 cell-size int< IF
    arg2 arg1 arg0 byte-string0-equals?/3 return1
  THEN
  arg2 peek
  arg1 peek
  equals? UNLESS int32 0 return1 THEN
  arg0 cell-size - set-arg0
  cell-size arg1 + set-arg1
  cell-size arg2 + set-arg2
  repeat-frame
end

( String byte manipulation: )

def string-peek ( string index -- byte )
  arg1 IF arg1 arg0 peek-off-byte ELSE 0 THEN 2 return1-n
end

def string-poke ( value string index )
  arg1 IF arg2 arg1 arg0 poke-off-byte THEN 3 return0-n
end

( Lengths: )

defcol null-terminate ( str length -- )
  rot int32 0 rot string-poke
endcol

def string-length-loop
  arg1 arg0 string-peek int32 0 equals? IF return0 THEN
  arg0 int32 1 + set-arg0
  repeat-frame
end

def string-length ( ptr -- length )
  arg0 int32 0 string-length-loop
  set-arg0
end

( Comparison wrappers: )

def string-equals?
  arg1 string-length
  arg0 string-length over equals?
  IF arg1 arg0 rot string-equals?/3
  ELSE false
  THEN 2 return1-n
end

def byte-string-compare/4 ( a-str a-length b-str b-length -- ternary )
  arg3 arg1 arg2 arg0 min byte-string-compare/3
  ( result is 0 and if lengths differ )
  dup 0 equals? IF
    arg2 arg0 equals? UNLESS
      ( return 1 if arg3 shorter, -1 if arg1 is shorter )
      arg2 arg0 int< IF drop 1 ELSE drop -1 THEN
    THEN
  THEN 2 return1-n
end

def byte-string-compare/2
  arg1 dup string-length
  arg0 dup string-length
  byte-string-compare/4
  2 return1-n
end

def byte-string<
  arg1 arg0 byte-string-compare/2 0 int< 2 return1-n
end

def byte-string>
  arg1 arg0 byte-string-compare/2 0 int> 2 return1-n
end

( Copiers: )

def copy-byte-string/3 ( src dest length )
  arg2 arg1 arg0 copy
end

( Combining strings: )

def string-append/5 ( dest max-len front front-len back back-len -- dest len )
  4 argn arg2 min
  4 argn arg2 - 2 - arg0 min
  arg1 5 argn dup 4 argn + swap in-range? IF
    arg1 5 argn arg2 + local1 copy-byte-string/3 3 dropn
    arg3 5 argn local0 copy-byte-string/3 3 dropn
  ELSE
    arg3 5 argn local0 copy-byte-string/3 3 dropn
    arg1 5 argn arg2 + local1 copy-byte-string/3 3 dropn
  THEN
  local1 local0 +
  5 argn over null-terminate
  5 return1-n
end

def string-append/4 ( dest max-len front back -- dest len )
  arg3 arg2
  arg1 arg1 string-length
  arg0 arg0 string-length
  string-append/5
  3 return1-n
end

( Allocating fresh copies of strings: )

def allot-byte-string/2 ( str len ++ new-str len )
  arg0 int32 1 + stack-allot
  arg1 over arg0 copy-byte-string/3 int32 3 dropn
  arg0
  2dup null-terminate
  exit-frame
end

def allot-byte-string ( str ++ new-str len )
  arg0 arg0 string-length allot-byte-string/2 exit-frame
end


( String matching: )

def string-index-of/4 ( ptr len predicate position )
  arg0 arg2 int<= UNLESS int32 0 return1 THEN
  arg3 arg0 string-peek arg1 exec IF int32 1 return1 THEN
  arg0 int32 1 + set-arg0
  drop-locals repeat-frame
end

defcol string-index-of ( ptr len predicate -- index )
  int32 4 overn int32 4 overn int32 4 overn
  int32 0
  string-index-of/4 ( ptr len pred ra ptr len pred index match )
  int32 7 set-overn
  int32 7 set-overn
  int32 3 dropn
  swap drop
endcol

def string-contains?/5 ( string str-length needle ndl-length index ++ )
  arg3 arg0 - arg1 uint< IF -1 5 return1-n THEN
  4 argn arg0 + arg2 arg1 byte-string-equals?/3
  IF arg0 5 return1-n
  ELSE 3 dropn arg0 arg3 uint< IF arg0 1 + set-arg0 repeat-frame THEN
  THEN
end

def contains? ( string needle -- yes? )
  arg1 dup string-length
  arg0 dup string-length
  0 string-contains?/5
  negative? IF false ELSE true THEN 2 return1-n
end
