NORTH-STAGE 1 + defconst> NORTH-STAGE

( Input: )

128 defconst> token-buffer-max
0 defvar> token-buffer
0 defvar> token-buffer-length

0 defvar> prompt-here
0 defvar> the-reader

defcol prompt
  prompt-here peek peek error-hex-uint enl
  s" Forth> " error-string/2
endcol

defcol prompt-read ( reader buffer max-length )
  prompt
  ( fixme perfect spot for a tailcall )
  ( todo store fd in reader data )
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
end

def s" ( ++ ...bytes length )
  ["]
  string-buffer-length peek
  exit-frame
end

( Interpreted conditions: )

def else?
  arg1 s" ELSE" string-equals?/3 return1
end

def then?
  arg1 s" THEN" string-equals?/3 return1
end

def else-or-then?
  arg1 arg0 else? rot swap then? rot int32 2 dropn or return1
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

( Word lookups: )

defcol not-found/2
  s" Not found: " error-string/2
  rot swap error-line/2
endcol

def token-not-found
  token-buffer peek token-buffer-length peek not-found/2
end

def interp-token/4 ( ptr length dict offset ++ value exec? )
  arg3 arg2 parse-int
  IF int32 0
  ELSE drop arg3 arg2 arg1 arg0 dict-lookup/4 IF int32 1 ELSE int32 -1 THEN
  THEN return2
end

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

def open-input-file ( path -- fd )
  0 0 arg0 open set-arg0
end

def load
  the-reader peek
  token-buffer-max stack-allot
  token-buffer-max
  s" Loading " error-string/2 arg0 error-line
  arg0 open-input-file negative? IF return THEN
  make-fd-reader the-reader poke
  interp
  local0 the-reader poke
  exit-frame
end


defcol ,h over error-hex-uint endcol

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
  exit-frame
end

def interp-boot
  interp-init interp bye
end
