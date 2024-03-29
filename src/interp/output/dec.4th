( Arbitrary radix: )

10 defvar> output-base

( todo cap number digits to buffer size, will require useless divide[s] or divide by radix )
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

( Writers: )

def write-uint/2 ( n fd )
  arg1 uint->string arg0 write-string/3
  return0
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
  return0
end

defcol write-int
  swap current-output peek write-int/2
  int32 2 dropn
endcol

defcol error-int
  swap current-error peek write-int/2
  int32 2 dropn
endcol

def write-int-sp arg0 write-int space 1 return0-n end
def error-int-sp arg0 error-int espace 1 return0-n end

def dec 10 output-base poke end
def hex 16 output-base poke end
def bin 2 output-base poke end

( Zero padded number output: )

def uint->padded-string/3 ( n out-ptr out-max -- out-ptr length )
  arg2 arg1 arg0 output-base peek arg0 48 uint->string/6
  arg1 arg0 null-terminate
  set-arg2 arg0 set-arg1 1 return0-n
end

def uint->padded-string ( n digits -- string length )
  arg0 1 + stack-allot
  arg1 over arg0 uint->padded-string/3
  exit-frame
end

def write-padded-uint/3 ( n digits fd )
  arg2 arg1 uint->padded-string arg0 write-string/3
  3 return0-n
end

def write-padded-uint ( n digits )
  arg1 arg0 current-output peek write-padded-uint/3
  2 return0-n
end
