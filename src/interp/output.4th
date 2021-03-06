( String and byte output: )

def write-string/3 ( string length fd -- )
  arg1 arg2 arg0 write
end

defcol write-string/2 ( string length -- )
  rot current-output peek write drop
endcol

defcol write-string
  swap dup string-length write-string/2
endcol

defcol write-line/2
  rot swap write-string/2 nl
endcol

defcol write-line
  swap write-string nl
endcol

defcol write-byte ( byte )
  swap here int32 1 write-string/2
  drop
endcol

defcol error-string/2
  rot current-error peek write drop
endcol

defcol error-string
  swap dup string-length error-string/2
endcol

defcol error-byte
  swap here int32 1 error-string/2
  drop
endcol

defcol error-line/2
  rot swap error-string/2 enl
endcol

defcol error-line
  swap dup string-length error-line/2
endcol

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

def write-hex-uint/2 ( n fd )
  int32 12 stack-allot ( need 9 bytes for a 32 bit number, 10 with minus. )
  arg1 over uint->hex-string arg0 write-string/3
  return
end

defcol write-hex-uint
  swap current-output peek write-hex-uint/2
  int32 2 dropn
endcol

defcol error-hex-uint
  swap current-error peek write-hex-uint/2
  int32 2 dropn
endcol

def write-hex-int/2 ( n fd )
  int32 12 stack-allot ( need 9 bytes for a 32 bit number, 10 with minus. )
  arg1 over int->hex-string arg0 write-string/3
  return
end

defcol write-hex-int
  swap current-output peek write-hex-int/2
  int32 2 dropn
endcol

defcol error-hex-int
  swap current-error peek write-hex-int/2
  int32 2 dropn
endcol

defalias> write-int write-hex-int
defalias> write-uint write-hex-uint
