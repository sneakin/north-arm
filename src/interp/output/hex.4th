( Hexadecimal output: )

0 defvar> hex-output-prefix
0 defvar> hex-output-prefix-length

def set-hex-output-prefix
  arg1 hex-output-prefix !
  arg0 hex-output-prefix-length !
  2 return0-n
end

def get-hex-output-prefix
  hex-output-prefix @
  hex-output-prefix-length @
  return2
end

defcol ascii-digit
  swap ( int32 0xF logand )
  dup int32 10 int< IF
    int32 48
  ELSE
    int32 10 -
    dup int32 26 int< IF
      int32 65
    ELSE
      int32 26 -
      dup int32 26 int< IF
	int32 97
      ELSE
	drop int32 63 swap exit
      THEN
    THEN
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
    ascii-digit arg2 poke-byte
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
  return0
end

def uint->hex-string ( n out-ptr -- out-ptr length )
  arg1 arg0 int32 0 int32 0 uint->hex-string/4
  int32 2 dropn
  arg0 dup set-arg1
  - set-arg0
  arg1 arg0 int32 1 + null-terminate
  return0
end

def int->hex-string ( n out-ptr -- out-ptr length )
  arg1 negative? IF
    int32 45 arg0 poke-byte
    negate
    arg0 int32 1 +
  ELSE
    arg0
  THEN
  int32 0 int32 0 uint->hex-string/4
  int32 2 dropn
  arg0 dup set-arg1
  - set-arg0
  arg1 arg0 int32 1 + null-terminate
  return0
end

def write-hex-uint-no-prefix/2 ( n fd )
  int32 12 stack-allot ( need 9 bytes for a 32 bit number, 10 with minus. )
  arg1 over uint->hex-string arg0 write-string/3
  return0
end

def write-hex-uint/2 ( n fd )
  arg1 IF hex-output-prefix @ dup IF hex-output-prefix-length @ arg0 write-string/3 ELSE drop THEN THEN
  ' write-hex-uint-no-prefix/2 tail-0
end

defcol write-hex-uint-no-prefix
  swap current-output peek write-hex-uint-no-prefix/2
  int32 2 dropn
endcol

defcol write-hex-uint
  swap current-output peek write-hex-uint/2
  int32 2 dropn
endcol

defcol error-hex-uint
  swap current-error peek write-hex-uint/2
  int32 2 dropn
endcol

def write-hex-int-no-prefix/2 ( n fd )
  int32 12 stack-allot ( need 9 bytes for a 32 bit number, 10 with minus. )
  arg1 over int->hex-string arg0 write-string/3
  return0
end

def write-hex-int/2 ( n fd )
  arg1 IF hex-output-prefix @ dup IF hex-output-prefix-length @ arg0 write-string/3 ELSE drop THEN THEN
  ' write-hex-int-no-prefix/2 tail-0
end

defcol write-hex-int-no-prefix
  swap current-output peek write-hex-int-no-prefix/2
  int32 2 dropn
endcol

defcol write-hex-int
  swap current-output peek write-hex-int/2
  int32 2 dropn
endcol

defcol error-hex-int
  swap current-error peek write-hex-int/2
  int32 2 dropn
endcol

def write-hex-int-sp arg0 write-hex-int space 1 return0-n end
def error-hex-int-sp arg0 error-hex-int espace 1 return0-n end

defalias> write-int write-hex-int
defalias> write-uint write-hex-uint
defalias> error-int error-hex-int
defalias> error-uint error-hex-uint

defcol write-hex-uint8
  swap dup
  4 bsr 0xF logand write-hex-uint-no-prefix
  0xF logand write-hex-uint-no-prefix
endcol

def write-cell-lsb
  arg0 dup write-hex-uint8 
  8 bsr dup write-hex-uint8
  8 bsr dup write-hex-uint8
  8 bsr dup write-hex-uint8
end
