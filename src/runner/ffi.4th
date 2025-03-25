( FFI helpers: )

( Lookup tables of callers: )

0
' ffi-callback-4-0
' ffi-callback-3-0
' ffi-callback-2-0
' ffi-callback-1-0
' ffi-callback-0-0
here
SYS:DEFINED? NORTH-COMPILE-TIME IF
  6 ,seq-pointer to-out-addr
THEN const> ffi-callbacks-0

0
' ffi-callback-4-1
' ffi-callback-3-1
' ffi-callback-2-1
' ffi-callback-1-1
' ffi-callback-0-1
here
SYS:DEFINED? NORTH-COMPILE-TIME IF
  6 ,seq-pointer to-out-addr
THEN const> ffi-callbacks-1

SYS:DEFINED? NORTH-COMPILE-TIME IF
  def ffi-callback-for ( returns num-args -- calling-word )
    arg1 IF ffi-callbacks-1 ELSE ffi-callbacks-0 THEN
    cs +
    arg0 4 min cell-size * + peek cs + return1
  end
ELSE
  def ffi-callback-for ( returns num-args -- calling-word )
    arg1 IF ffi-callbacks-1 ELSE ffi-callbacks-0 THEN
    arg0 4 min cell-size * + peek return1
  end
THEN

NORTH-BUILD-TIME 1659768556 int< IF

  def ffi-callback-with ( word code-word -- ...assembly ptr )
    ( returns a call to an op that'll push args & jump to the next word. )
    0
    arg0 dict-entry-code peek cs + 0xFFFFFFFE logand
    ( copy code-word's code into a new buffer )
    3 11 + cell-size * stack-allot-zero set-local0
    local1 local0 11 cell-size * copy-byte-string/3 3 dropn
    ( after the copied code the FFI callbacks expect ds, cs, and a word to call. )
    arg1 local0 12 seq-poke
    cs local0 11 seq-poke
    ds local0 10 seq-poke
    ( offset for thumb and exit )
    local0 NORTH-PLATFORM " thumb" string-contains? IF 1 + THEN exit-frame ( todo as a seqn )
  end

ELSE

  ( todo ARM assembly wordsbprevent ~and~ from working )
  SYS:DEFINED? NORTH-COMPILE-TIME not
  NORTH-BUILD-TIME 1705910557 int<= logand IF

    def interp-save-state ( ptr -- )
      ds arg0 2 seq-poke
      cs arg0 1 seq-poke
      dict arg0 0 seq-poke
      1 return0-n
    end
    
    def ffi-callback-with ( word code-word -- ...assembly ptr )
      ( returns a call to an op that'll push args & jump to the next word. )
      0
      arg0 dict-entry-code peek cs + 0xFFFFFFFE logand
      ( copy code-word's code into a new buffer )
      4 cell-size * local1 peek + cell-size pad-addr stack-allot-zero set-local0
      local1 cell-size + local0 local1 peek copy-byte-string/3 3 dropn
      ( after the copied code the FFI callbacks expect dict, cs, ds, and a word to call. )
      local1 peek ( cell-size pad-addr ) set-local1
      arg1 local0 local1 poke-off
      local1 cell-size + local0 + interp-save-state
      ( offset for thumb and exit )
      local0 NORTH-PLATFORM " thumb" string-contains? IF 1 + THEN exit-frame ( todo as a seqn )
    end

  ELSE
    
    def interp-save-state ( ptr -- )
      ds arg0 1 seq-poke
      cs arg0 0 seq-poke
      1 return0-n
    end
    
    def ffi-callback-with ( word code-word -- ...assembly ptr )
      ( returns a call to an op that'll push args & jump to the next word. )
      0
      arg0 dict-entry-code peek cs + 0xFFFFFFFE logand
      ( copy code-word's code into a new buffer )
      3 cell-size * local1 peek + cell-size pad-addr stack-allot-zero set-local0
      local1 cell-size + local0 local1 peek copy-byte-string/3 3 dropn
      ( after the copied code the FFI callbacks expect cs, ds, and a word to call. )
      local1 peek ( cell-size pad-addr ) set-local1
      arg1 local0 local1 poke-off
      local1 cell-size + local0 + interp-save-state
      ( offset for thumb and exit )
      local0 NORTH-PLATFORM " thumb" string-contains? IF 1 + THEN exit-frame ( todo as a seqn )
    end

  THEN
THEN

defcol ffi-callback ( word arity returns -- ...assembly ptr )
  rot ffi-callback-for rot 2 dropn
  swap ' ffi-callback-with jump-data
endcol
