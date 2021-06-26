0 defvar> current-input
1 defvar> current-output
2 defvar> current-error

( Output: )

" Hello!" string-const> hello-s

defcol hello
  int32 6 hello-s current-output peek write drop
endcol

"  " string-const> space-s

defcol space
  int32 1 space-s current-output peek write drop
endcol

" 
" string-const> nl-s

defcol nl
  int32 1 nl-s current-output peek write drop
endcol

def write-string/2
  arg0 arg1 current-output peek write drop
end

def write-string
  arg0 string-length arg0 current-output peek write drop
end

( Hexadecimal output: )

defcol hex-digit
  swap int32 0xF logand
  dup int32 10 int< IF
    int32 48
  ELSE
    int32 10 -
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
  - set-arg0
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
  - set-arg0
  arg1 arg0 int32 1 + null-terminate
  return
end

def write-hex-uint/1 ( n )
  int32 12 stack-allot ( need 9 bytes for a 32 bit number, 10 with minus. )
  arg0 over uint->hex-string write-string/2
  return
end

defcol write-hex-uint
  swap write-hex-uint/1
  drop
endcol

( Word listing: )

( Iteration: )

def dict-map/4 ( dict origin state fn )
  arg3 null? UNLESS
    arg1 arg3 arg0 exec-abs set-arg1
    arg3 dict-entry-link peek
    dup null? UNLESS
      arg2 + set-arg3
      repeat-frame
    THEN
  THEN
end

def dict-map ( dict fn )
  arg1 cs int32 0 arg0 dict-map/4
end

def write-byte
  arg0 1 write-string/2
end

def tab 9 write-byte end

defcol write-tabbed-hex-uint
  swap dup write-hex-uint tab
  0x100000 uint< IF tab THEN
endcol

def words-printer
  arg0 cs -
  dup write-tabbed-hex-uint space
  arg0 dict-entry-name peek cs + write-string nl
end

def words
  dict pointer words-printer dict-map
end

def read-uint32
  op-size stack-allot
  op-size over current-input peek read
  op-size equals?
  IF peek op-mask logand 1 return2
  ELSE 0 return1
  THEN
end

def runner-loop
  read-uint32 IF exec repeat-frame ELSE bye ( return ) THEN
end

defcol jump-data
  drop
  dict-entry-data peek jump-cs
end

def runner-boot
  read-uint32
  IF exec ' runner-loop jump-data
  ELSE words bye
  THEN
end
