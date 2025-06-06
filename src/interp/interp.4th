( Input: )

64 defconst> token-buffer-max
0 defvar> token-buffer
0 defvar> token-buffer-length

0 defvar> prompt-here
0 defvar> the-reader

defcol fd-reader-fn ( reader ptr len -- reader ptr read-length )
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
  literal fd-reader-fn over reader-reader-fn poke
  exit-frame
end

def prompt-depth
  top-frame prompt-here peek int-sub cell-size int-div return1
end

defcol default-prompt
  prompt-here peek error-hex-uint
  s" :" error-string/2
  prompt-here peek peek error-int
  s"  > " error-string/2
endcol

( todo should be in the prompt reader )
0 defvar> prompt

defcol prompt-read ( reader buffer max-length )
  prompt @ dup IF exec-abs ELSE drop THEN
  ( fixme perfect spot for a tailcall / continue> )
  ' fd-reader-fn jump-data
endcol

defcol make-stdin-reader
  current-input peek swap ' make-fd-reader jump-data
endcol

( todo supply input and output fds )

def make-prompt-reader
  arg1 arg0 make-stdin-reader
  literal prompt-read over reader-reader-fn poke
  exit-frame
end

( the-reader procedures: )

defcol raw-read-line ( ptr len -- ptr read-length )
  over int32 4 overn current-input peek read
  negative? UNLESS
    int32 1 -
    int32 4 overn over null-terminate
  THEN
  rot drop
endcol

def read-line ( ptr len -- ptr read-length )
  arg1 arg0 the-reader peek reader-read-line
  drop 2 return2-n
end

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

( todo use a list to store the reader stack. no need for readers to know. )
( todo interp gets a reader argument, load uses a new reader and interp loop )
( todo store file name and count lines in readers )

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

def next-token/3 ( ptr size prompt-sp ++ length )
  arg0 prompt-here poke
  arg2 arg1 the-reader peek read-token
  negative? IF
    pop-the-reader
    IF int32 2 dropn repeat-frame
    ELSE int32 -1
    THEN
  THEN return1
end

def next-token/2
  arg1 arg0 args cell-size 2 * + next-token/3 set-arg0
end

def next-token
  token-buffer peek token-buffer-max args next-token/3
  rot 2 dropn
  dup token-buffer-length poke
  return2
end

def next-integer
  next-token negative? IF 0 return1 THEN
  parse-int return2
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

def skip-tokens-until
  arg0 the-reader peek reader-skip-tokens-until
end

( todo nested comments )

def ( ( bad emacs )
  int32 41 skip-until-char
  the-reader peek reader-read-byte
end out-immediate

def read-until
  arg2 arg1 arg0 the-reader peek reader-read-until
  set-arg0 set-arg1
end

def read-until-char
  arg0 pointer equals? make-noname
  arg2 arg1 int32 3 overn read-until
  set-arg0 set-arg1
end

1024 defconst> string-buffer-max
0 defvar> string-buffer
0 defvar> string-buffer-length

defcol tmp" ( ++ token-buffer-ptr bytes-read )
  ( eat leading space )
  the-reader peek reader-read-byte drop
  ( read the string )
  string-buffer peek string-buffer-max int32 34 read-until-char
  drop
  2dup null-terminate
  ( update the string-buffer )
  dup string-buffer-length poke
  swap rot
  ( eat the terminal quote )
  the-reader peek reader-read-byte drop
endcol

def " ( ++ ...bytes ptr )
  POSTPONE tmp"
  swap drop 1 + stack-allot
  string-buffer peek over string-buffer-length peek 1 + copy-byte-string/3
  int32 4 dropn
  here exit-frame
end

defalias> ["] "

def c" ( ++ ...bytes length )
  POSTPONE tmp"
  swap drop 1 + stack-allot
  string-buffer peek over string-buffer-length peek 1 + copy-byte-string/3
  int32 4 dropn
  string-buffer-length peek
  exit-frame
end out-immediate

def s" ( ++ ...bytes ptr length )
  ["]
  string-buffer-length peek
  exit-frame
end

( Interpreted conditions: )

def [if?]
  arg1 s" [IF]" string-equals?/3 return1
end

def [unless?]
  arg1 s" [UNLESS]" string-equals?/3 return1
end

def [else?]
  arg1 s" [ELSE]" string-equals?/3 return1
end

def [then?]
  arg1 s" [THEN]" string-equals?/3 return1
end

def [else-or-then?]
  arg1 arg0 [else?] rot swap [then?] rot int32 2 dropn or return1
end

def [if-or-unless?]
  arg1 arg0 [if?] rot swap [unless?] rot int32 2 dropn or return1
end

( todo literalizes? could search a list of words registered or a flag on a word. A post-word can set the flag and/or whenever next-word or a literalizing word is used. )

def literalizes?
  0
  pointer literal
  pointer int32
  pointer uint32
  pointer offset32
  pointer pointer
  pointer cstring
  pointer string
  pointer uint64
  pointer int64
  pointer float32
  pointer float64
  here 11 arg0 seq-include? 1 return1-n
end

def token-literalizes? ( str length -- yes? )
  0
  " '"
  " POSTPONE"
  " off'"
  " out'"
  " out-off'"
  " sys'"
  " DEFINED?"
  " SYS:DEFINED?"
  " OUT:DEFINED?"
  " literal"
  " int32"
  " uint32"
  " offset32"
  " pointer"
  " cstring"
  " string"
  " uint64"
  " int64"
  " float32"
  " float64"
  here 20 arg1 arg0 seq-include-string?/4 2 return1-n
end

def nested-skip-tokens-until/4 ( lead-fn term-fn inner-term-fn depth ++ )
  next-token
  negative? IF ( todo error ) return0 THEN
  2dup token-literalizes? IF
    next-token negative? IF return0 THEN
    drop-locals repeat-frame
  THEN
  over s" (" string-equals?/3 IF POSTPONE ( THEN 3 dropn
  2dup
  arg0 0 uint> IF arg1 ELSE arg2 THEN exec-abs
  IF arg0 0 uint> IF arg0 1 - set-arg0 ELSE return0 THEN THEN
  arg3 exec-abs IF arg0 1 + set-arg0 THEN
  drop-locals repeat-frame
end

defcol nested-skip-tokens-until ( lead-fn term-fn inner-term-fn -- )
  3 swapn rot swap 0 nested-skip-tokens-until/4 4 dropn
endcol

defcol skip-bracketed-conditional-tokens
  pointer [if-or-unless?]
  pointer [else-or-then?]
  pointer [then?]
  nested-skip-tokens-until
endcol

( todo does int32 get left behind for numbers as [IF] conditions? )

defcol [IF]
  swap UNLESS skip-bracketed-conditional-tokens THEN
endcol out-immediate

defcol [UNLESS]
  swap IF skip-bracketed-conditional-tokens THEN
endcol out-immediate

defcol [ELSE]
  pointer [if-or-unless?]
  pointer [then?]
  pointer [then?]
  nested-skip-tokens-until
endcol out-immediate

( fixme did/should the last token get eaten? THEN was leftover on an ELSE when the alias was used. )

defcol [THEN]
  ( no need to do anything besides not crash )
endcol out-immediate

tmp" src/interp/toplevel-if.4th" load/2

( Word lookups: )

def DEFINED? ( : word -- yes? )
  next-token defined?/2 return1
end

defcol not-found/2
  s" Not found: " error-string/2
  rot swap error-line/2
endcol

def token-not-found
  token-buffer peek token-buffer-length peek not-found/2
end

OUT:DEFINED? parse-float32 IF
  def interp-token/4 ( ptr length dict offset ++ value exec? )
    ( todo check the last byte for l, u, f, d )
    arg3 arg2 parse-int
    IF int32 0
    ELSE
      drop
      arg3 arg2 parse-float32
      IF int32 0
      ELSE drop arg3 arg2 arg1 arg0 dict-lookup/4 IF int32 1 ELSE int32 -1 THEN
      THEN
    THEN return2
  end
ELSE
  def interp-token/4 ( ptr length dict offset ++ value exec? )
    arg3 arg2 parse-int
    IF int32 0
    ELSE drop arg3 arg2 arg1 arg0 dict-lookup/4 IF int32 1 ELSE int32 -1 THEN
    THEN return2
  end
THEN

def interp-token ( ptr length -- value exec? )
  arg1 arg0 dict cs interp-token/4 set-arg0 set-arg1
end

def [']
  next-token interp-token
  negative? IF token-not-found int32 0 ELSE drop THEN
  return1
end

defalias> ' [']

( Word listing: )

def words-printer
  arg0 dict-entry-name peek cs + write-string space
end

def words
  dict pointer words-printer dict-map
end

( Interpretation loop: )

0 defvar> trace-eval

def interp
  next-token negative? IF int32 2 dropn exit-frame THEN
  trace-eval peek IF 2dup error-string/2 espace THEN
  interp-token
  negative? IF token-not-found int32 2 dropn
  ELSE IF exec-abs THEN
  THEN
  trace-eval peek IF s" => " error-string/2 dup error-hex-uint enl THEN
  repeat-frame
end

( File loading: )

def open-output-file/2 ( mode path -- fid )
  arg1 O_TRUNC O_CREAT logior O_WRONLY logior arg0 open 2 return1-n
end

def open-output-file ( path -- fid )
  0640 arg0 open-output-file/2 set-arg0
end

def open-input-file ( path -- fd )
  0 O_RDONLY arg0 open set-arg0
end

0 defvar> *current-file*

def current-file *current-file* @ return1 end
def [current-file] literal literal *current-file* @ return2 end out-immediate-as current-file
  
def load ( path ++ ... ok? )
  the-reader peek
  *current-file* @
  token-buffer-max stack-allot ( fixme this buffer gets made for each load, could reuse for file reads, or get rid of by reading whole files and tokenizing that memory making buffering only needed when reading streams )
  token-buffer-max
  INTERP-LOG-LOADS interp-logs? IF s" Loading " error-string/2 arg0 error-line THEN
  arg0 open-input-file negative? IF
    s" Error " error-string/2 error-int enl
    false return1-1
  THEN
  make-fd-reader
  ( try a read to trigger an error here on directories )
  dup reader-top-up negative? IF
    s" Error reading " error-string/2 error-int enl
    fd-reader-close
    false return1-1
  ELSE drop the-reader poke
  THEN
  arg0 *current-file* !
  interp ( todo return this? )
  the-reader peek fd-reader-close
  local0 the-reader poke
  local1 *current-file* !
  true exit-frame
end

def load/2
  ' load droptail-1
end

def load-string/2
  INTERP-LOG-LOADS interp-logs? IF s" Loading string: " error-string/2 arg1 arg0 error-line/2 THEN
  the-reader peek
  *current-file* @
  arg1 arg0 make-string-reader the-reader poke
  " <string>" *current-file* !
  interp
  local0 the-reader poke
  local1 *current-file* !
  exit-frame
end

def load-string
  arg0 string-length ' load-string/2 tail+1
end

defcol ,h over error-hex-uint endcol
defcol .h swap error-hex-uint endcol
defcol ,i over error-int endcol
defcol .i swap error-int endcol

512 1024 * defvar> *interp-data-stack-size*
256 defvar> *interp-return-stack-size*

def north-init-stacks!
  return-stack peek UNLESS *interp-return-stack-size* @ proper-init THEN
  dhere UNLESS *interp-data-stack-size* @ data-init-stack THEN
  exit-frame
end

def interp-init
  north-init-stacks!
  *init-dict* *dict* poke
  ( token-buffer )
  token-buffer peek UNLESS
    int32 0 token-buffer-length poke
    token-buffer-max stack-allot token-buffer poke
  THEN
  ( string-buffer )
  string-buffer peek UNLESS
    int32 0 string-buffer-length poke
    string-buffer-max stack-allot string-buffer poke
  THEN
  ( stdin reader )
  the-reader peek UNLESS ( todo push a new one always? )
    token-buffer-max stack-allot token-buffer-max make-prompt-reader the-reader poke
  THEN
  ' default-prompt prompt poke
  s" core-init" dict dict-lookup IF exec-abs THEN
  exit-frame
end

def banner
  copyright error-line
end

def about
  copyright write-string nl
  s"  Build Time:" write-string/2 tab NORTH-BUILD-TIME write-time-stamp nl
  s"     Builder:" write-string/2 tab NORTH-BUILDER write-string nl
  s"     Git Ref:" write-string/2 tab NORTH-GIT-REF write-string nl
  s" Binary Size:" write-string/2 tab *program-size* write-int nl
  *program-sha256* cs uint> IF s"     SHA-256:" write-string/2 tab *program-sha256* write-string nl THEN
  nl
  s"   Platform:" write-string/2 tab NORTH-PLATFORM write-string nl
  s"       Bits:" write-string/2 tab NORTH-BITS write-int nl
  s"  Cell size:" write-string/2 tab cell-size write-int nl
end

def interp-boot
  interp-init banner interp exit-frame
end
