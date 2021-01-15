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

defcol ffi-callback-with ( word code-word -- ...assembly ptr )
  .s
  ( allot 8 less args+return cells )
  0 rot 0 rot
  0 rot 0 rot
  0 rot 0 rot
  0 rot 0 rot
  0 rot
  here cell-size 2 * + rot
  ( needs to return a call to an op that'll push args & jump to the next word. )
  here .s drop
  swap dict-entry-code peek cs + 1 -
  3 overn cell-size 9 * copy-byte-string/3 3 dropn
  swap 1 + swap .s
endcol

defcol ffi-callback ( word arity returns -- ...assembly ptr )
  rot ffi-callback-for rot 2 dropn
  swap ' ffi-callback-with jump-data
endcol
