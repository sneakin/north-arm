( Utility functions: )

defcol locals-byte-size
  here locals swap - swap
endcol

( Definitions: )

def copy-dict-entry
  arg0 dict-entry-link peek
  arg0 dict-entry-data peek
  arg0 dict-entry-code peek
  arg0 dict-entry-name peek
  here exit-frame
end

def create
  arg1 arg0 make-dict-entry
  dict cs - over dict-entry-link poke
  ( make this the newest dictionary word )
  dup set-dict
  exit-frame
end

def create>
  ( read in the name )
  next-token allot-byte-string/2
  2dup error-line/2
  ( then... )
  create exit-frame
end

0 defvar> compiling
0 defvar> compiling-state
0 defvar> compiling-immediates
0 defvar> compiling-dict
0 defvar> compiling-offset
0 defvar> compiling-literalizes-fn

defcol end-compile
  int32 0 compiling poke
endcol
out-immediate-as endcol
out-immediate-as end
out-immediate-as ;

output-immediates @ to-out-addr defvar> immediates

-1 defconst> COMPILING-ERROR
0 defconst> COMPILING-INT
1 defconst> COMPILING-WORD
2 defconst> COMPILING-IMMED

def compile-lookup ( ptr length -- value exec? )
  arg1 arg0 compiling-dict peek compiling-offset peek interp-token/4
  set-arg0 set-arg1
end

( todo apply offset in reversal, token lists so lookup is done on reversal? immediate lookup during read? )

def compile-token
  arg1 arg0 compiling-immediates peek dict-lookup
  IF cs - COMPILING-IMMED
  ELSE
    arg1 arg0 compile-lookup
    negative? IF
      0 COMPILING-ERROR
    ELSE
      IF compiling-offset peek - COMPILING-WORD
      ELSE COMPILING-INT
      THEN
    THEN
  THEN set-arg0 set-arg1
end

def literalizes?
  arg0 CASE
    pointer literal OF true ENDOF
    pointer int32 OF true ENDOF
    pointer uint32 OF true ENDOF
    pointer offset32 OF true ENDOF
    pointer pointer OF true ENDOF
    pointer cstring OF true ENDOF
    pointer string OF true ENDOF
    pointer uint64 OF true ENDOF
    pointer int64 OF true ENDOF
    pointer float32 OF true ENDOF
    pointer float64 OF true ENDOF
    false
  ENDCASE 1 return1-n
end

( punt literalizes? could search a list of words registered, or flagged on a word, whenever next-word or a literalizing word is used. )

def compiling-read/2 ( buffer max-length ++ list-words num-words )
  arg1 arg0 next-token/2 negative? IF int32 2 dropn locals-byte-size cell/ exit-frame THEN
  compile-token CASE
    COMPILING-IMMED WHEN exec ;;
    COMPILING-INT WHEN
      over compiling-offset peek + compiling-literalizes-fn peek exec-abs
      UNLESS
        s" int32" compile-token negative? IF s" int32" not-found/2 THEN
        drop swap
      THEN
    ;;
    negative? IF arg1 dup string-length not-found/2 int32 2 dropn ELSE drop THEN
  ESAC
  compiling peek IF repeat-frame ELSE locals-byte-size cell/ exit-frame THEN
end

def compiling-init
  immediates peek cs + compiling-immediates poke
  dict compiling-dict poke
  cs compiling-offset poke
  pointer literalizes? compiling-literalizes-fn poke
end

def compiling-read
  int32 1 compiling poke
  token-buffer peek token-buffer-max compiling-read/2
  exit-frame
end

defcol does ( word code -- )
  swap dict-entry-code peek
  swap rot dict-entry-code poke
endcol

def does-col
  arg0 pointer do-col does
end

def does-col>/2
  arg1 does-col
  compiling-init compiling-read
  arg0 swap
  int32 0 swap
  int32 2 +
  here cell-size + swap reverse
  int32 2 dropn
  here cs - arg1 dict-entry-data poke
  exit-frame
end

def does-col>
  arg0 literal exit does-col>/2
  exit-frame
end

def defcol
  create> does-col> exit-frame
end

def does-frame>
  arg0 literal return0 does-col>/2
  literal begin-frame
  here cs - arg0 dict-entry-data poke
  exit-frame
end

def def
  create> does-frame> exit-frame
end

def iwords
  immediates peek cs + pointer words-printer dict-map
end
