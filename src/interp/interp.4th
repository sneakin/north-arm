( Input: )

128 defconst> token-buffer-max
0 defvar> token-buffer
0 defvar> token-buffer-length

0 defvar> prompt-here
0 defvar> the-reader

defcol prompt
  prompt-here peek peek write-hex-uint nl
  " Forth> " write-string/2
endcol

defcol prompt-read
  prompt
  ( fixme perfect spot for a tailcall )
  over int32 4 overn current-input peek read
  rot drop
endcol

( todo input token stream that is a list of ops )
( todo supply input and output fds )

def make-prompt-reader
  make-reader
  arg0 over reader-buffer-length poke
  arg1 over reader-buffer poke
  literal prompt-read over reader-reader-fn poke
  exit-frame
end

defcol read-fd ( reader ptr len -- reader ptr read-length )
  over int32 4 overn int32 6 overn reader-reader-data peek read
  rot drop
endcol

defcol fd-reader-close
  swap reader-reader-data peek close drop
endcol

def make-fd-reader
  make-reader
  arg2 over reader-buffer poke
  arg1 over reader-buffer-length poke
  arg0 over reader-reader-data poke
  literal fd-reader-close over reader-reader-finalizer poke
  literal read-fd over reader-reader-fn poke
  exit-frame
end

def make-stdin-reader
  arg1 arg0 current-input peek make-fd-reader
  exit-frame
end

( File loading: )

def open-input-file ( path -- fd )
  0 0 arg0 open set-arg0
end

def load
  token-buffer-max stack-allot
  token-buffer-max
  arg0 open-input-file negative? IF return THEN
  make-fd-reader
  the-reader peek over reader-next poke
  the-reader poke
  exit-frame
end

( the-reader procedures: )

defcol read-line ( ptr len -- ptr read-length )
  over int32 4 overn current-input peek read
  negative? UNLESS
    int32 1 swap -
    int32 4 overn over null-terminate
  THEN
  rot drop
endcol

defcol read-token ( ptr len reader -- ptr read-length )
  int32 4 overn int32 4 overn int32 4 overn reader-next-token
  negative? IF
    drop dup int32 0 equals? IF drop int32 -1 THEN
  ELSE
    drop over over null-terminate
  THEN
  ( ptr len reader -- ptr len )
  int32 4 set-overn
  drop swap drop
endcol

def pop-the-reader
  the-reader peek
  dup reader-close
  reader-next peek dup IF
    the-reader poke
    int32 1 return1
  ELSE
    int32 0 return1
  THEN
end

( todo raise errors from next-token; pop reader first )
( todo simplify compiling-read & merge with compiler.4th's )

def next-token/2
  arg1 arg0 the-reader peek read-token
  negative? IF
    pop-the-reader
    IF int32 2 dropn repeat-frame
    ELSE int32 -1 set-arg0
    THEN
  ELSE set-arg0
  THEN
end

def next-token
  token-buffer peek token-buffer-max next-token/2
  dup token-buffer-length poke
  return2
end

( will need exec-abs to thread call )
def make-noname ( data-ptr fn )
  alloc-dict-entry
  pointer do-col dict-entry-code peek over dict-entry-code poke
  literal exit
  literal swap
  arg0 cs -
  arg1 literal literal
  literal swap
  here cs - int32 8 overn dict-entry-data poke
  int32 7 overn exit-frame
end

def skip-until
  arg0 the-reader peek reader-skip-until
end

def skip-until-char
  arg0 pointer equals? make-noname skip-until
end

( todo nested comments )

def (
  int32 41 skip-until-char
  the-reader peek reader-read-byte
end

def read-until
  arg2 arg1 arg0 the-reader peek reader-read-until
  set-arg0 set-arg1
end

def read-until-char
  arg0 pointer equals? make-noname
  arg2 arg1 int32 3 overn read-until
  set-arg0 set-arg1
end

0 defvar> string-buffer
0 defvar> string-buffer-length

defcol tmp" ( ++ token-buffer-ptr bytes-read )
  ( eat leading space )
  the-reader peek reader-read-byte drop
  ( read the string )
  string-buffer peek token-buffer-max int32 34 read-until-char
  drop
  2dup null-terminate
  ( update the string-buffer )
  dup string-buffer-length poke
  swap rot
  ( eat the terminal quote )
  the-reader peek reader-read-byte drop
endcol

def c" ( ++ ...bytes length )
  POSTPONE tmp"
  swap drop 1 + stack-allot
  string-buffer peek over string-buffer-length peek copy-byte-string/3
  int32 4 dropn
  string-buffer-length peek
  exit-frame
end

( Interpreted conditions: )

def else?
  arg1 " ELSE" string-equals?/3 return1
end

def then?
  arg1 " THEN" string-equals?/3 return1
end

def else-or-then?
  arg1 arg0 else? rot swap then? rot int32 2 dropn or return1
end

def skip-tokens-until
  arg0 the-reader peek reader-skip-tokens-until
end

defcol IF
  swap UNLESS pointer else-or-then? skip-tokens-until drop THEN
endcol

defcol UNLESS
  swap IF pointer else-or-then? skip-tokens-until drop THEN
endcol

defcol ELSE
  pointer then? skip-tokens-until drop
endcol

defcol THEN
  ( no need to do anything besides not crash )
endcol

( Definitions: )

48 defconst> new-dict-entry-name-max

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
  2dup write-string/2 nl
  ( then... )
  create exit-frame
end

0 defvar> compiling
0 defvar> compiling-state
0 defvar> compiling-immediates
0 defvar> compiling-dict
0 defvar> compiling-offset

defcol end-compile
  int32 0 compiling poke
endcol

def lookup ( ptr length -- dict-entry found? )
  arg1 arg0 dict dict-lookup
  set-arg0 set-arg1
endcol

def [']
  next-token
  lookup
  IF return1
  ELSE not-found nl int32 0 return1
  THEN
end

defalias> ' [']

0 out' end-compile ' endcol copies-entry-as
out' end-compile ' end copies-entry-as
out' end-compile ' ; copies-entry-as
out' ( ' ( copies-entry-as
out' c" ' c" copies-entry-as
defvar> immediates

-1 defconst> COMPILING-ERROR
0 defconst> COMPILING-INT
1 defconst> COMPILING-WORD
2 defconst> COMPILING-IMMED

( todo decouple dict from everything )

def interp-token/4 ( ptr length dict offset ++ value exec? )
  arg3 arg2 parse-int
  IF int32 0
  ELSE drop arg3 arg2 arg1 arg0 dict-lookup/4 IF int32 1 ELSE int32 -1 THEN
  THEN return2
end

def interp-token ( ptr length -- value exec? )
  arg1 arg0 dict cs interp-token/4 set-arg0 set-arg1
end

( todo dict-lookup with offset )

def compile-lookup ( ptr length -- value exec? )
  arg1 arg0 compiling-dict peek compiling-offset peek interp-token/4
  set-arg0 set-arg1
end

( todo apply offset in reversal )

def compile-token
  arg1 arg0 compiling-immediates peek dict-lookup
  IF cs - COMPILING-IMMED
  ELSE
    arg1 arg0 compile-lookup
    IF compiling-offset peek - COMPILING-WORD
    ELSE COMPILING-INT
    THEN
  THEN set-arg0 set-arg1
end

defcol cell/
  swap int32 2 bsr swap
endcol

defcol locals-byte-size
  here locals swap - swap
endcol

def literalizes?
  arg0 pointer literal equals? IF int32 1 set-arg0 return THEN
  arg0 pointer int32 equals? IF int32 1 set-arg0 return THEN
  arg0 pointer offset32 equals? IF int32 1 set-arg0 return THEN
  arg0 pointer pointer equals? IF int32 1 set-arg0 return THEN
  int32 0 set-arg0
end

( punt literalizes? could search a list of words registered, or flagged on a word, whenever next-word or a literalizing word is used. )

def compiling-read/2 ( buffer max-length ++ list-words num-words )
  here prompt-here poke
  arg1 arg0 next-token/2 negative? IF int32 2 dropn locals-byte-size cell/ exit-frame THEN
  compile-token CASE
    COMPILING-IMMED WHEN exec ;;
    COMPILING-INT WHEN over cs + literalizes? UNLESS literal int32 swap THEN ;;
    negative? IF not-found int32 2 dropn ELSE drop THEN
  ESAC
  compiling peek IF repeat-frame ELSE locals-byte-size cell/ exit-frame THEN
end

def compiling-init
  immediates peek cs + compiling-immediates poke
  dict compiling-dict poke
  cs compiling-offset poke
end

def compiling-read
  int32 1 compiling poke
  token-buffer peek token-buffer-max compiling-read/2
  exit-frame
end

def reverse-loop ( start ending )
  arg1 arg0 uint>= IF return THEN
  ( swap values )
  arg1 peek arg0 peek
  arg1 poke arg0 poke
  ( loop towards the middle )
  arg1 cell-size + set-arg1
  arg0 cell-size - set-arg0
  repeat-frame
end

def reverse ( ptr length )
  arg1 arg1 arg0 1 - cell-size * + reverse-loop
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
  arg0 literal return does-col>/2
  literal begin-frame
  here cs - arg0 dict-entry-data poke
  exit-frame
end

def def
  create> does-frame> exit-frame
end

( Debugging aids: )

defcol print-caller-args
  arg3 write-hex-int nl
  arg2 write-hex-int nl
  arg1 write-hex-int nl
  arg0 write-hex-int nl nl
endcol

def print-args
  arg3 write-hex-int nl
  arg2 write-hex-int nl
  arg1 write-hex-int nl
  arg0 write-hex-int nl nl
end

( Decompiling words: )

def dict-contains?
  arg0 dict dict-contains?/2 IF int32 1 return1 THEN
  arg0 immediates peek dict-contains?/2 return1
end

def decompile-loop
  arg0 peek int32 0 equals? IF nl return THEN
  arg0 peek cs +
  dup dict-contains? UNLESS nl return THEN
  dup dict-entry-name peek cs + write-string space
  literalizes? IF
    arg0 op-size +
    dup set-arg0
    peek write-hex-uint space
  THEN
  arg0 op-size + set-arg0
  repeat-frame
end

def decompile ( entry )
  arg0 IF
    " does> " write-string/2
    arg0 dict-entry-code peek write-hex-uint nl
    arg0 dict-entry-data peek
    dup IF cs + decompile-loop THEN
  THEN
end

def memdump/2 ( ptr num-bytes )
  arg1 peek write-hex-uint space
  arg1 cell-size + set-arg1
  arg0 cell-size int>= IF
    arg0 cell-size - set-arg0
    repeat-frame
  ELSE
    nl
  THEN
end

defcol memdump
  rot swap memdump/2
  int32 2 dropn
endcol

def dump-stack
  args write-hex-uint nl
  args 64 memdump nl
end

( Word listing: )

def words-printer
  arg0 dict-entry-name peek cs + write-string space
end

def words
  dict pointer words-printer dict-map
end

def iwords
  immediates peek cs + pointer words-printer dict-map
end

( Interpretation loop: )

0 defvar> trace-eval

def interp
  here prompt-here poke
  next-token negative? IF what return THEN
  trace-eval peek IF 2dup nl write-string/2 space THEN
  interp-token
  negative? IF not-found int32 2 dropn
  ELSE IF exec-abs THEN
  THEN
  trace-eval peek IF dup write-hex-uint THEN
  repeat-frame
end

defcol ,h over write-hex-uint endcol

def load-comp
  " ./src/interp/boot/load.4th" drop load
  exit-frame
end

def load-ops
  " ./src/interp/boot/load-ops.4th" drop load
  exit-frame
end

0 defvar> initial-dict

def interp-init
  dict initial-dict poke
  ( token-buffer )
  int32 0 token-buffer-length poke
  token-buffer-max stack-allot token-buffer poke
  ( string-buffer )
  int32 0 string-buffer-length poke
  token-buffer-max stack-allot string-buffer poke
  ( stdin reader )
  token-buffer-max stack-allot token-buffer-max make-prompt-reader the-reader poke
  ( compiler )
  compiling-init
  exit-frame
end

def interp-boot
  interp-init interp bye
end
