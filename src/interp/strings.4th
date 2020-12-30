( String operations: )

( fixme "boo" == "boot"? Need to check lengths on both. Checking for 0 byte at end works, but not perfect. )

def byte-string-equals?/3 ( a-str b-str length )
  arg2 peek-byte
  arg1 peek-byte
  equals? UNLESS int32 0 return1 THEN
  arg0 int32 0 int<= IF int32 1 return1 THEN
  arg0 int32 1 - set-arg0
  arg1 int32 1 + set-arg1
  arg2 int32 1 + set-arg2
  repeat-frame
end

def string-equals?/3 ( a-str b-str length )
  arg0 cell-size int< IF
    arg2 arg1 arg0 byte-string-equals?/3 return1
  THEN
  arg2 peek
  arg1 peek
  equals? UNLESS int32 0 return1 THEN
  arg0 cell-size - set-arg0
  cell-size arg1 + set-arg1
  cell-size arg2 + set-arg2
  repeat-frame
end

defcol string-peek ( string index -- byte )
  rot + peek-byte swap
endcol

defcol string-poke ( value string index )
  rot +
  swap rot swap poke-byte
endcol

defcol null-terminate
  rot int32 0 rot string-poke
endcol

def string-length-loop
  arg1 arg0 string-peek int32 0 equals? IF return THEN
  arg0 int32 1 + set-arg0
  repeat-frame
end

def string-length ( ptr -- length )
  arg0 int32 0 string-length-loop
  set-arg0
end

def copy-byte-string-finals/3 ( src dest length )
  arg0 int32 0 int<= IF return THEN
  arg2 peek-byte arg1 poke-byte
  arg0 int32 1 - set-arg0
  arg1 int32 1 + set-arg1
  arg2 int32 1 + set-arg2
  repeat-frame
end

def copy-byte-string/3 ( src dest length )
  arg0 cell-size int< IF
    arg2 arg1 arg0 copy-byte-string-finals/3 return
  THEN
  arg2 peek arg1 poke
  arg0 cell-size - set-arg0
  arg1 cell-size + set-arg1
  arg2 cell-size + set-arg2
  repeat-frame
end

def allot-byte-string/2
  arg0 int32 1 + stack-allot
  arg1 over arg0 copy-byte-string/3 int32 3 dropn
  arg0
  2dup null-terminate
  exit-frame
end

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
