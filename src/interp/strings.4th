( String operations: )

( todo byte-string-equals? and compare and any other words should eat their arguments )
( todo string-index-of to be superseded by string-index-of-str )
( todo string-contains? using index-of needs partial-first )

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

def byte-string-equals-loop ( a-str b-str length )
  arg0 int32 0 uint> UNLESS int32 1 return1 THEN
  arg2 peek-byte
  arg1 peek-byte
  equals? UNLESS int32 0 return1 THEN
  arg0 int32 1 - set-arg0
  arg1 int32 1 + set-arg1
  arg2 int32 1 + set-arg2
  repeat-frame
end

def byte-string-equals?/3 ( a-str b-str length )
  arg2 arg1 equals? IF int32 1 return1 THEN
  arg2 0 equals? IF int32 0 return1 THEN
  arg1 0 equals? IF int32 0 return1 THEN
  arg0 0 equals? IF int32 1 return1 THEN
  ' byte-string-equals-loop tail-0
end

def byte-string0-equals?/3 ( a-str b-str length )
  arg2 arg1 arg0 byte-string-equals?/3 IF
    drop peek-byte
    swap peek-byte
    equals?
  ELSE int32 0
  THEN return1
end

def clean-byte-string-equals?/3
  arg2 arg1 arg0 byte-string-equals?/3 3 return1-n
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

def clean-copy-byte-string/3 ( src dest length -- )
  arg2 arg1 arg0 copy 3 return0-n
end

( Combining strings: )

def string-append/6 ( dest max-len front front-len back back-len -- dest len )
  4 argn arg2 min
  4 argn arg2 - 2 - arg0 min
  ( copy the back first if it's in the destination )
  arg1 5 argn dup 4 argn + swap in-range? IF
    local1 0 int> IF
      arg1 5 argn arg2 + local1 clean-copy-byte-string/3
    THEN
    arg3 5 argn local0 clean-copy-byte-string/3
  ELSE
    arg3 5 argn local0 clean-copy-byte-string/3
    local1 0 int> IF
      arg1 5 argn arg2 + local1 clean-copy-byte-string/3
    THEN
  THEN
  local1 local0 +
  5 argn over null-terminate
  5 return1-n
end

def string-append/4 ( dest max-len front back -- dest len )
  arg3 arg2
  arg1 arg1 string-length
  arg0 arg0 string-length
  string-append/6
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

def string-index-of/4 ( ptr len predicate offset -- index || -1 )
  arg0 arg2 int<= UNLESS -1 4 return1-n THEN
  arg3 arg0 string-peek arg1 exec-abs IF arg0 4 return1-n THEN
  arg0 int32 1 + set-arg0
  drop-locals repeat-frame
end

def string-index-of ( ptr len predicate -- index )
  0 ' string-index-of/4 tail+1
end

def string-index-of-str/4 ( ptr len predicate[ str len -- yes? ] offset -- index true || false )
  arg0 arg2 int<= UNLESS false 4 return1-n THEN
  arg3 arg0 + arg2 arg0 - arg1 exec-abs IF arg0 true 4 return2-n THEN
  arg0 int32 1 + set-arg0
  drop-locals repeat-frame
end

def string-index-of-str ( ptr len predicate -- index true || false )
  0 ' string-index-of-str/4 tail+1
end

( toda test when substring exceeds length )

def string-rindex-of/4 ( ptr len predicate[ str len -- yes? ] offset -- index true || false )
  arg0 0 uint> UNLESS false 4 return1-n THEN
  arg0 1 - set-arg0
  arg3 arg0 + arg2 arg0 - arg1 exec-abs IF arg0 true 4 return2-n THEN
  drop-locals repeat-frame
end

def string-rindex-of ( ptr len predicate[str len -- yes? ] -- index true || false )
  arg1 ' string-rindex-of/4 tail+1
end

def string-contains?/5 ( string str-length needle ndl-length index -- index || -1 )
  arg3 arg0 - arg1 uint< IF -1 5 return1-n THEN
  4 argn arg0 + arg2 arg1 byte-string-equals?/3
  IF arg0 5 return1-n
  ELSE 3 dropn arg0 arg3 uint< IF arg0 1 + set-arg0 repeat-frame THEN
  THEN
end

def string-contains? ( string needle -- yes? )
  arg1 dup string-length
  arg0 dup string-length
  0 string-contains?/5
  negative? IF false ELSE true THEN 2 return1-n
end

( String utility functions: )

def advance-string-len ( ptr length max -- ptr+length max-length )
  arg2 arg1 +
  arg0 arg1 -
  3 return2-n
end

def fill ( ptr num-bytes value -- )
  arg1 0 int> UNLESS 3 return0-n THEN
  arg1 1 - set-arg1
  arg0 arg2 arg1 poke-off-byte
  repeat-frame
end

def string-align-right ( out out-size str str-n padding-char -- out out-size )
  arg3 arg1 uint< IF
    arg2 4 argn arg3 copy
  ELSE
    arg2 4 argn arg3 + arg1 - arg1 copy
    4 argn arg3 arg1 - arg0 fill
  THEN 3 return0-n
end

def pad-addr ( addr alignment )
  arg1 arg0 1 - + arg0 uint-div arg0 int-mul
  2 return1-n
end

def move-string-right ( str len max-len -- new-str len )
  arg2 arg0 + arg1 - 1 - cell-size - cell-size pad-addr
  arg2 over arg1 copy
  dup arg1 null-terminate
  arg1 3 return2-n
end
