( String and byte output: )

0 defvar> *debug*
defcol debug? *debug* peek swap endcol

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

defcol write-hex-uint8
  swap dup
  4 bsr 0xF logand write-hex-uint
  0xF logand write-hex-uint 
endcol

def write-cell-lsb
  arg0 dup write-hex-uint8
  8 bsr dup write-hex-uint8
  8 bsr dup write-hex-uint8
  8 bsr dup write-hex-uint8
end

( Arbitrary radix: )

10 defvar> output-base

( todo cap number digits to buffer size, will require useless divide[s] or divide by radix^missing )
( todo return with output adjusted to first digit and a length )

def uint->string/6 ( n out-ptr out-max radix digit padding -- output-start )
  arg1 0 equals? IF
    4 argn 6 return1-n
  ELSE
    ( zero without padding )
    5 argn 0 equals? arg0 0 equals? and IF
      arg1 1 - set-arg1
      0 ascii-digit 4 argn arg1 string-poke
      4 argn arg1 + 6 return1-n
    ELSE
      ( extract dgit from n )
      5 argn arg2 uint-divmod
      swap 5 set-argn
      ( reached zero? pad or bail; otherwise decode character )
      dup 0 equals?
      5 argn 0 equals? and
      IF arg0 IF drop arg0 ELSE 4 argn arg1 arg3 min + 6 return1-n THEN
      ELSE ascii-digit
      THEN
      ( store digit or padding )
      arg1 1 - set-arg1
      arg1 arg3 uint<= IF 4 argn arg1 string-poke THEN
      ( bail to prevent extra zero if not padding and N is zero )
      5 argn 0 equals? arg0 0 equals? and IF
	4 argn arg1 arg3 min + 6 return1-n
      THEN
      repeat-frame
    THEN
  THEN
end

def digit-count ( n radix -- count )
  arg1 0 equals?
  IF 1
  ELSE
    arg1 arg0 badlogn-uint
    arg0 over int-pow arg1 uint<= IF 1 + THEN
    dup UNLESS 1 + THEN
  THEN
  2 return1-n
end

def uint->string/4 ( n out-ptr out-max radix -- out-ptr length )
  arg3 arg0 digit-count
  arg3 arg2 arg1 arg0 local0 0 uint->string/6 set-arg3
  arg2 local0 null-terminate
  local0 arg3 arg2 - - set-arg2 2 return0-n
end

def uint->string-rad/2 ( n radix ++ string length )
  arg1 arg0 digit-count 1 +
  dup stack-allot
  arg1 over local0 arg0 uint->string/4
  exit-frame
end

def uint->string/3 ( n output out-max -- output length )
  arg2 arg1 arg0 output-base peek uint->string/4 set-arg0 set-arg1
end

def uint->string ( n ++ string length )
  arg0 output-base peek uint->string-rad/2 exit-frame
end

def int->string/4 ( n out-ptr out-max radix -- out-ptr length )
  arg3 negative? IF
    negate arg2 int32 1 + arg1 arg0 uint->string/4
    1 + set-arg2
    1 - int32 45 over poke-byte set-arg3
    2 return0-n
  ELSE
    arg2 arg1 arg0 uint->string/4
    set-arg2 set-arg3 2 return0-n
  THEN
end

def int->string-rad/2 ( n radix ++ string length )
  arg1 abs-int arg0 digit-count
  arg1 negative? swap drop IF 1 + THEN
  dup UNLESS 1 + THEN
  dup stack-allot
  arg1 over local0 arg0 int->string/4
  exit-frame
end

def int->string/3 ( n out-ptr out-max -- out-ptr length )
  arg2 arg1 arg0 output-base peek int->string/4 set-arg1 set-arg2 1 return0-n
end

def int->string ( n ++ string length )
  arg0 output-base peek int->string-rad/2 exit-frame
end

def write-uint/2 ( n fd )
  arg1 uint->string arg0 write-string/3
  return
end

defcol write-uint
  swap current-output peek write-uint/2
  int32 2 dropn
endcol

defcol error-uint
  swap current-error peek write-uint/2
  int32 2 dropn
endcol

def write-int/2 ( n fd )
  arg1 int->string arg0 write-string/3
  return
end

defcol write-int
  swap current-output peek write-int/2
  int32 2 dropn
endcol

defcol error-int
  swap current-error peek write-int/2
  int32 2 dropn
endcol
