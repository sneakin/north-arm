( Decompiling words: )

def dict-contains?
  arg0 dict dict-contains?/2 IF int32 1 return1 THEN
  arg0 immediates peek cs + dict-contains?/2 return1
end

defcol write-dict-entry-name
  swap dict-entry-name peek cs + write-string
endcol

34 defconst> dquote

DEFINED? NORTH-COMPILE-TIME IF
  0 defvar> decompile-string-fn
ELSE
  0 var> decompile-string-fn
THEN

def write-quoted-string
  dquote write-byte space
  arg0 dup string-length
  decompile-string-fn @ dup IF
    dup *code-size* uint< IF cs + THEN exec-abs
  ELSE drop
  THEN write-string/2 dquote write-byte
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

def decompile-op-codes ( word -- )
  arg0 dict-entry-code peek cs + 0xFFFFFFFE logand
  dup peek cell-size + cmemdump ( todo needs ,uint32 after op codes. )
  1 return0-n
end

DEFINED? NORTH-COMPILE-TIME IF
  0 defvar> decompile-op-fn
ELSE
  0 var> decompile-op-fn
THEN

def decompile-op
  s" defop " write-string/2 arg0 write-dict-entry-name nl space space
  decompile-op-fn @ IF
    s" ( " write-string/2
    arg0 decompile-op-codes
    s" )" write-string/2 nl
    arg0 decompile-op-fn @ dup IF
      dup *code-size* uint< IF cs + THEN exec-abs
    ELSE drop
    THEN
  ELSE
    arg0 decompile-op-codes
  THEN
  s" endop" write-string/2 nl
  arg0 dict-entry-data peek dup IF
    s" data[ " write-string/2
    cs + dup string-length cmemdump
    s" ]" write-string/2 nl
  THEN
end

def decompile-colon-data
  arg0 peek int32 0 equals? IF return0 THEN
  arg0 peek cs +
  dup dict-contains? IF
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
  ELSE s" !!ERROR!!" write-string/2 space
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
  dup arg0 dict-entry-code-word write-dict-entry-name
  s"  ( " write-string/2
  write-hex-uint
  s"  ) " write-string/2
end

def framed-definition?
  arg0 dict-entry-data peek
  dup IF cs + @ literal begin-frame equals?
      ELSE false
      THEN set-arg0
end

def decompile-colon
  arg0 dict-entry-data @ 0 equals? IF
    arg0 decompile-op
  ELSE
    arg0 framed-definition? dup IF
      s" def " write-string/2 arg0 write-dict-entry-name nl space space
      op-size
    ELSE
      s" defcol " write-string/2 arg0 write-dict-entry-name nl space space
      0
    THEN
    arg0 dict-entry-data peek dup IF cs + + decompile-colon-data THEN
    nl
    local0 IF s" end" ELSE s" endcol" THEN write-string/2 nl
  THEN
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

def decompile-const-offset
  arg0 dict-entry-data @ arg0 cs - equals? IF
    s" symbol> " write-string/2
    arg0 write-dict-entry-name nl
  ELSE
    arg0 s" const-offset>" decompile-inplace-var
  THEN
end

def decompile-data-var
  arg2 dict-entry-data peek cs + 1 seq-peek write-uint space
  arg1 arg0 write-string/2 space
  arg2 write-dict-entry-name
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

def dict-contains-values? ( word dict ++ yes? )
  arg0 UNLESS false return1 THEN
  arg1 arg0 dict-entry-equiv? IF true return1 THEN
  arg0 dict-entry-link @ dup IF cs + THEN set-arg0
  repeat-frame
end

def dict-entry-name-equals? ( word-a word-b -- yes? )
  arg0 dict-entry-name @ cs +
  arg1 dict-entry-name @ cs +
  string-equals? 2 return1-n
end

def maybe-decompile-immediate
  ( If immediate-only is every implemented, uncomment the lines. )
  ( arg0 dict dict-contains-values? rot 2 dropn )
  arg0 immediates @ cs + dict-contains-values? IF
    2dup dict-entry-name-equals? IF
      ( local0 IF s" immediate" ELSE s" immediate-only" THEN write-string/2 )
      s" immediate" write-string/2
    ELSE
      ( local0 IF s" immediate-as " ELSE s" immediate-only-as" THEN write-string/2 )
      s" immediate-as " write-string/2
      dup dict-entry-name @ cs + write-string
    THEN 2 dropn
  THEN nl
  1 return0-n
end

def decompile ( entry )
  arg0 IF
    arg0 dict-entry-code-word CASE
      ' do-col WHEN arg0 decompile-colon ;;
      ' do-proper WHEN arg0 decompile-proper ;;
      ' do-const WHEN arg0 decompile-const ;;
      ' do-const-offset WHEN arg0 decompile-const-offset ;;
      ' do-var WHEN arg0 s" var>" decompile-data-var ;;
      ' do-inplace-var WHEN arg0 s" inplace-var>" decompile-inplace-var ;;
      ' do-data-var WHEN arg0 s" var>" decompile-data-var ;;
        arg0 is-op?
	IF arg0 decompile-op
	ELSE arg0 decompile-unknown-entry
	THEN
    ESAC
    arg0 maybe-decompile-immediate
  THEN
end
