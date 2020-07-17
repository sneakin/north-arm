defcol break
  int32 0x47 peek
endcol

( Messages: )

" BOOM" string-const> boom-s

defcol boom
  int32 4 boom-s int32 1 write drop
endcol

" Hello!" string-const> hello-s

defcol hello
  int32 6 hello-s int32 1 write drop
endcol

" Crap!" string-const> crap-s

defcol crap
  int32 5 crap-s int32 1 write drop
endcol

" What?" string-const> what-s

defcol what
  int32 5 what-s int32 1 write drop
endcol

" Boo!" string-const> boo-s

defcol boo
  int32 4 boo-s int32 1 write drop
endcol

" Not Found." string-const> not-found-s

defcol not-found
  int32 10 not-found-s int32 1 write drop
endcol

" 
" string-const> nl-s

defcol nl
  int32 1 nl-s int32 1 write drop
endcol

( String operations: )

defcol write-string/2 ( string length -- )
  rot int32 1 write drop
endcol

( fixme "boo" == "boot"? Need to check lengths on both. Checking for 0 byte at end works, but not perfect. )

def byte-string-equals?/3 ( a-str b-str length )
  arg2 peek-byte
  arg1 peek-byte
  equals? UNLESS int32 0 return1 THEN
  arg0 int32 0 int<= IF int32 1 return1 THEN
  int32 1 arg0 - set-arg0
  int32 1 arg1 + set-arg1
  int32 1 arg2 + set-arg2
  repeat-frame
end

def string-equals?/3 ( a-str b-str length )
  arg0 cell-size int< IF
    arg2 arg1 arg0 byte-string-equals?/3 return1
  THEN
  arg2 peek
  arg1 peek
  equals? UNLESS int32 0 return1 THEN
  cell-size arg0 - set-arg0
  cell-size arg1 + set-arg1
  cell-size arg2 + set-arg2
  repeat-frame
end

defcol string-poke ( value string index )
  rot +
  swap rot swap poke-byte
endcol

defcol null-terminate
  rot int32 0 rot string-poke
endcol

( Dictionary access: )

defcol dict-entry-name
  exit exit ( fixme compiling-read and empties, revmap too? )
endcol

defcol dict-entry-link
  swap
  cell-size int32 3 * +
  swap
endcol

def dict-lookup ( ptr length dict-entry ++ found? )
  arg0 null? IF int32 0 return1 THEN
  ( arg0 dict-entry-name peek cs + arg1 write-string/2 )
  arg0 dict-entry-name peek cs + arg2 arg1 string-equals?/3 IF
    int32 1 return1
  THEN
  int32 3 dropn
  arg0 dict-entry-link peek
  dup null? IF int32 0 return1 THEN
  cs + set-arg0
  repeat-frame
end

defcol lookup ( ptr length -- dict-entry found? )
  rot swap
  dict dict-lookup
  swap 2swap int32 2 dropn rot
endcol

( Numbers: )

defcol negative?
  over int32 0 int< swap
endcol

defcol one
  int32 1 swap
endcol

defcol zero
  int32 0 swap
endcol


( Hexadecimal output: )

defcol hex-digit
  swap int32 0xF logand
  dup int32 10 int< IF
    int32 48
  ELSE
    int32 10 swap -
    int32 65
  THEN
  + swap
endcol

def uint->hex-string/4 ( n out-ptr counter print-always? )
  ( start with the highest nibble )
  arg3 int32 0xF0000000 logand int32 28 bsr
  ( past leading zeroes? )
  arg0 UNLESS
    dup int32 0 equals? UNLESS
      int32 1 set-arg0
    THEN
  THEN
  arg0 IF
    ( write a digit )
    hex-digit arg2 poke-byte
    arg2 int32 1 + set-arg2
  ELSE
    ( leading zero )
    drop
  THEN
  ( advance the counters & repeat )
  arg1 int32 7 int< IF
    arg1 int32 1 + set-arg1
    arg3 int32 4 bsl set-arg3
    ( N is zero )
    arg1 int32 7 equals? IF int32 1 set-arg0 THEN
    repeat-frame
  THEN
  return
end

def uint->hex-string ( n out-ptr -- out-ptr length )
  arg1 arg0 int32 0 int32 0 uint->hex-string/4
  int32 2 dropn
  arg0 dup set-arg1
  swap - set-arg0
  arg1 arg0 int32 1 + null-terminate
  return
end

def int->hex-string ( n out-ptr -- out-ptr length )
  arg1 negative? IF
    negate
    int32 45 arg0 poke-byte
    arg0 int32 1 +
  ELSE
    arg0
  THEN
  int32 0 int32 0 uint->hex-string/4
  int32 2 dropn
  arg0 dup set-arg1
  swap - set-arg0
  arg1 arg0 int32 1 + null-terminate
  return
end

def write-hex-uint/1 ( n )
  int32 12 stack-allot ( need 9 bytes for a 32 bit number, 10 with minus. )
  arg0 over uint->hex-string
  write-string/2
  return
end

defcol write-hex-uint
  swap write-hex-uint/1
  drop
endcol

def write-hex-int/1 ( n )
  int32 12 stack-allot ( need 9 bytes for a 32 bit number, 10 with minus. )
  arg0 over int->hex-string
  write-string/2
  return
end

defcol write-hex-int
  swap write-hex-int/1
  drop
endcol

( Input: )

defcol read-token ( ptr len -- ptr read-length )
  over int32 4 overn int32 0 read
  negative? UNLESS
    int32 1 swap -
    int32 4 overn over null-terminate
  THEN
  rot drop
endcol

( Interpretation loop: )

defcol prompt
  offset32 20 int32 7 write-string/2
  exit
  s" Forth> "
endcol

def interp
  nl prompt
  arg1 arg0 read-token negative? IF what return THEN
  2dup write-string/2 nl
  lookup IF exec-abs ELSE not-found drop THEN
  dup write-hex-uint
  repeat-frame
end
