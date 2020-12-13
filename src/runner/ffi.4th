  ( todo fix up a CASE for the interpreter; or make jump-rel & if-jump consistent on cell-size multiplier )

0
' ffi-callback-3
' ffi-callback-2
' ffi-callback-1
' ffi-callback-0
here const> ffi-callbacks-0

0
' ffi-callback-3-1
' ffi-callback-2-1
' ffi-callback-1-1
' ffi-callback-0-1
here const> ffi-callbacks-1

def ffi-callback-for ( returns num-args -- calling-word )
  arg1 IF ffi-callbacks-1 ELSE ffi-callbacks-0 THEN
  arg0 4 uint< IF cell-size arg0 * + THEN
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
