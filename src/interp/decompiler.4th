( Decompiling words: )

def dict-contains?
  arg0 dict dict-contains?/2 IF int32 1 return1 THEN
  arg0 immediates peek cs + dict-contains?/2 return1
end

defcol write-dict-entry-name
  swap dict-entry-name peek cs + write-string
endcol

34 defconst> dquote

def write-quoted-string
  dquote write-byte space arg0 write-string ( todo escaping ) dquote write-byte
end

def write-dict-entry-name
  arg0 dict-entry-name peek cs + write-string
  1 return0-n
end

def decompile-literal-word ( value word offset -- )
  arg1 write-dict-entry-name space
  arg2 arg0 + dict dict-contains?/2
  IF write-dict-entry-name
  ELSE 2 dropn arg2 write-hex-uint
  THEN space
  3 return0-n
end

def decompile-colon-data
  arg0 peek int32 0 equals? IF return THEN
  arg0 peek cs +
  dup dict-contains? UNLESS return THEN
  dup literalizes? IF
    arg0 op-size + dup set-arg0 peek
    swap dup CASE
      ' cstring OF drop cs + write-quoted-string space ENDOF
      ' string OF drop write-quoted-string space ENDOF
      ' int32 OF drop write-int space ENDOF
      ' int64 OF
         write-dict-entry-name space
	 arg0 op-size + dup set-arg0 peek write-int64 space
      ENDOF
      ' uint64 OF
         write-dict-entry-name space
	 arg0 op-size + dup set-arg0 peek write-uint64 space
      ENDOF
      ' pointer OF cs decompile-literal-word ENDOF
      ' literal OF cs decompile-literal-word ENDOF
      drop write-dict-entry-name space write-hex-uint space
    ENDCASE
  ELSE write-dict-entry-name space
  THEN
  arg0 op-size + set-arg0
  repeat-frame
end

def dict-entry-code-word
  arg0 dict-entry-code peek 1 lognot logand
  ( hope for no data in from of the assembly... )
  dup IF cs + dict-entry-size - THEN set-arg0
end

def decompile-entry-code
  ( Calls a code word )
  s" does> " write-string/2
  arg0 dict-entry-code peek
  s" ( " write-string/2
  dup write-hex-uint
  s"  ) " write-string/2
  arg0 dict-entry-code-word write-dict-entry-name
end

def decompile-colon
  s" defcol " write-string/2 arg0 write-dict-entry-name nl space space
  arg0 dict-entry-data peek dup IF cs + decompile-colon-data THEN
  nl s" endcol" write-string/2
  nl
end

def decompile-proper
  s" : " write-string/2 arg0 write-dict-entry-name nl space space
  arg0 dict-entry-data peek dup IF cs + decompile-colon-data THEN
  nl s" ;" write-string/2
  nl
end

def decompile-inplace-var
  arg2 dict-entry-data peek write-uint space
  arg1 arg0 write-string/2 space
  arg2 write-dict-entry-name
  nl
end

def decompile-const
  arg0 dict-entry-data @ arg0 equals? IF
    s" symbol> " write-string/2
    arg0 write-dict-entry-name nl
  ELSE
    arg0 s" const>" decompile-inplace-var
  THEN
end

def decompile-data-var
  arg2 dict-entry-data peek cs + 1 seq-peek write-uint space
  arg1 arg0 write-string/2 space
  arg2 write-dict-entry-name
  nl
end

def decompile-op
  s" defop " write-string/2 arg0 write-dict-entry-name nl space space
  arg0 dict-entry-code peek cs + 0xFFFFFFFE logand
  dup peek cell-size + cmemdump ( todo needs ,uint32 after op codes. )
  s" endop" write-string/2
  arg0 dict-entry-data peek dup IF
    s" data[ " write-string/2
    cs + dup string-length cmemdump
    s" ]" write-string/2
  THEN
  nl
end

def decompile-unknown-entry
  s" create> " write-string/2
  arg0 write-dict-entry-name nl
  arg0 decompile-entry-code nl
  s" data> " write-string/2
  arg0 dict-entry-data peek write-hex-uint
  nl
end

def is-op? ( word -- yes? )
  arg0 dict-entry-code-word arg0 equals? set-arg0
end

def decompile ( entry )
  arg0 IF
    arg0 dict-entry-code-word CASE
      ' do-col WHEN arg0 decompile-colon ;;
      ' do-proper WHEN arg0 decompile-proper ;;
      ' do-const WHEN arg0 decompile-const ;;
      ' do-var WHEN arg0 s" var>" decompile-data-var ;;
      ' do-inplace-var WHEN arg0 s" inplace-var>" decompile-inplace-var ;;
      ' do-data-var WHEN arg0 s" var>" decompile-data-var ;;
        arg0 is-op?
	IF arg0 decompile-op
	ELSE arg0 decompile-unknown-entry
	THEN
    ESAC
  THEN
end
