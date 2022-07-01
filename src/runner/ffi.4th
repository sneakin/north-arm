( FFI helpers: )

( Lookup tables of callers: )

0
' ffi-callback-4-0
' ffi-callback-3-0
' ffi-callback-2-0
' ffi-callback-1-0
' ffi-callback-0-0
here const> ffi-callbacks-0

0
' ffi-callback-4-1
' ffi-callback-3-1
' ffi-callback-2-1
' ffi-callback-1-1
' ffi-callback-0-1
here const> ffi-callbacks-1

def ffi-callback-for ( returns num-args -- calling-word )
  arg1 IF ffi-callbacks-1 ELSE ffi-callbacks-0 THEN
  arg0 5 uint< IF arg0 ELSE 4 THEN cell-size * + THEN
  peek return1
end

def ffi-callback-with ( word code-word -- ...assembly ptr )
  ( returns a call to an op that'll push args & jump to the next word. )
  0
  ( copy code-word's code into a new buffer )
  ( todo get the length from the sequence )
  3 11 + cell-size * stack-allot-zero set-local0
  arg0 dict-entry-code peek cs + ( 1 - )
  local0 cell-size 11 * copy-byte-string/3 3 dropn
  ( FFI callbacks expect dict, cs, and word to call after the copied code. )
  arg1 local0 13 seq-poke
  cs local0 12 seq-poke
  dict local0 11 seq-poke
  ( offset for thumb and exit )
  local0 1 + exit-frame
end

defcol ffi-callback ( word arity returns -- ...assembly ptr )
  rot ffi-callback-for rot 2 dropn
  swap ' ffi-callback-with jump-data
endcol
