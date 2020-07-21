( String operations: )

def byte-string-equals?/3 ( a-str b-str length )
  arg2 peek-byte
  arg1 peek-byte
  equals? UNLESS int32 0 return1 THEN
  arg0 int32 0 int<= IF int32 1 return1 THEN
  int32 1 arg0 - set-arg0
  int32 1 arg1 + set-arg1
  int32 1 arg2 + set-arg2
  repeat-frame
end

def string-equals?/3 ( a-str b-str length )
  arg0 cell-size int< IF
    arg2 arg1 arg0 byte-string-equals?/3 return1
  THEN
  arg2 peek
  arg1 peek
  equals? UNLESS int32 0 return1 THEN
  cell-size arg0 - set-arg0
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
