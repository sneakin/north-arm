( Debugging aid: )

defcol print-args
  arg3 write-hex-int nl
  arg2 write-hex-int nl
  arg1 write-hex-int nl
  arg0 write-hex-int nl nl
endcol

( Input: )

0 defvar> prompt-here

defcol prompt
  prompt-here peek peek write-hex-uint nl
  " Forth> " write-string/2
endcol

defcol stdin-read ( ptr len -- ptr read-length )
  over int32 4 overn int32 0 read
  rot drop
endcol

defcol prompt-read
  prompt
  ( fixme perfect spot for a tailcall )
  over int32 4 overn int32 0 read
  rot drop
endcol

defcol make-stdin-reader
  int32 0 swap
  int32 0 swap  
  literal stdin-read swap
  here cell-size + swap
endcol

defcol make-prompt-reader
  int32 0 swap
  int32 0 swap  
  literal prompt-read swap
  here cell-size + swap
endcol

defcol read-line ( ptr len -- ptr read-length )
  over int32 4 overn int32 0 read
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

0 defvar> the-reader

def next-token
  arg1 arg0 the-reader peek read-token
  set-arg0
end

def '
  int32 128 stack-allot
  int32 128 next-token lookup IF return1 ELSE not-found nl int32 0 return1 THEN
end

( will need exec-abs to thread call )
def make-noname ( data-ptr fn )
  alloc-dict-entry
  pointer do-col dict-entry-code peek over dict-entry-code poke
  literal exit
  literal swap
  cs arg0 -
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

0 defvar> token-buffer
128 defconst> token-buffer-max
0 defvar> token-buffer-length

defcol s"
  ( eat leading space )
  the-reader peek reader-read-byte drop
  ( read the string )
  token-buffer peek token-buffer-max int32 34 read-until-char
  drop
  2dup null-terminate
  ( update the string-buffer )
  dup token-buffer-length poke
  swap rot
  ( eat the terminal quote )
  the-reader peek reader-read-byte drop
endcol

def create
  ( read in the name )
  int32 16 stack-allot int32 16 next-token
  2dup write-string/2
  drop
  ( then... )
  make-dict-entry
  dict cs - over dict-entry-link poke
  ( make this the newest dictionary word )
  dup set-dict
  exit-frame
end

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

defcol ELSE
  pointer then? skip-tokens-until drop
endcol

defcol THEN
  ( no need to do anything besides not crash )
endcol

( Interpretation loop: )

0 defvar> trace-eval

def interp
  arg0 the-reader poke
  here prompt-here poke
  arg2 arg1 arg0 read-token negative? IF what int32 2 dropn return THEN
  trace-eval peek IF 2dup write-string/2 nl THEN
  2dup parse-int IF
    rot int32 2 dropn
  ELSE
    drop
    lookup IF exec-abs ELSE not-found drop THEN
  THEN
  trace-eval peek IF dup write-hex-uint THEN
  repeat-frame
end

defcol ,h over write-hex-uint endcol

def interp-boot
  int32 0 token-buffer-length poke
  int32 128 stack-allot token-buffer poke
  int32 128 stack-allot int32 128 make-prompt-reader
  int32 128 stack-allot
  int32 128 int32 35 overn
  interp
end