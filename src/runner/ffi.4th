( FFI helpers: )

( Lookup tables of callers: )

0
' ffi-callback-4-0
' ffi-callback-3-0
' ffi-callback-2-0
' ffi-callback-1-0
' ffi-callback-0-0
here
' NORTH-COMPILE-TIME defined? [IF]
6 ,seq-pointer to-out-addr
[THEN] const> ffi-callbacks-0

0
' ffi-callback-4-1
' ffi-callback-3-1
' ffi-callback-2-1
' ffi-callback-1-1
' ffi-callback-0-1
here
' NORTH-COMPILE-TIME defined? [IF]
6 ,seq-pointer to-out-addr
[THEN] const> ffi-callbacks-1

' NORTH-COMPILING-TIME defined? [IF]
  def ffi-callback-for ( returns num-args -- calling-word )
    arg1 IF ffi-callbacks-1 ELSE ffi-callbacks-0 THEN
    cs +
    arg0 5 uint< IF arg0 ELSE 4 THEN cell-size * + THEN
peek cs + return1
  end
[ELSE]
  def ffi-callback-for ( returns num-args -- calling-word )
    arg1 IF ffi-callbacks-1 ELSE ffi-callbacks-0 THEN
    arg0 5 uint< IF arg0 ELSE 4 THEN cell-size * + THEN
peek return1
  end
[THEN]

NORTH-BUILD-TIME 1659768556 uint< [IF]

def ffi-callback-with ( word code-word -- ...assembly ptr )
  ( returns a call to an op that'll push args & jump to the next word. )
  0
  arg0 dict-entry-code peek cs + 0xFFFFFFFE logand
  ( copy code-word's code into a new buffer )
  3 11 + cell-size * stack-allot-zero set-local0
  local1 local0 11 cell-size * copy-byte-string/3 3 dropn
  ( after the copied code, FFI callbacks expect dict, cs, and a word to call. )
  arg1 local0 12 seq-poke
  cs local0 11 seq-poke
  dict local0 10 seq-poke
  ( offset for thumb and exit )
  local0 1 + exit-frame ( todo as a seqn )
end

[ELSE]

def ffi-callback-with ( word code-word -- ...assembly ptr )
  ( returns a call to an op that'll push args & jump to the next word. )
  0
  arg0 dict-entry-code peek cs + 0xFFFFFFFE logand
  ( copy code-word's code into a new buffer )
  3 cell-size * local1 peek + stack-allot-zero set-local0
  local1 cell-size + local0 local1 peek copy-byte-string/3 3 dropn
  ( after the copied code, FFI callbacks expect dict, cs, and a word to call. )
  local1 peek cell-size / set-local1 ( padded in ops so no need to round up )
  arg1 local0 local1 2 + seq-poke
  cs local0 local1 1 + seq-poke
  dict local0 local1 seq-poke
  ( offset for thumb and exit )
  local0 1 + exit-frame ( todo as a seqn )
end

[THEN]

defcol ffi-callback ( word arity returns -- ...assembly ptr )
  rot ffi-callback-for rot 2 dropn
  swap ' ffi-callback-with jump-data
endcol
