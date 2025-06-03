( 64 bit integer output: )

( todo no function performs padding w/ right alignment )
( todo prepend the output number prefix )

( Convert a uint64 into a string / byte seq. )
def uint64->byte-seq/6 ( out-str out-size lo hi radix n -- out-str length remainder-lo remainder-hi )
  arg3 arg2 0LL int64-equals?
  arg0 0 uint> and UNLESS
    arg0 4 argn uint< IF
      ( extract the digit )
      arg3 arg2 arg1 uint64-divmod32
      ( store the digit )
      ascii-digit 5 argn arg0 string-poke
      ( update the number )
      set-arg2 set-arg3
      ( next digit )
      arg0 1 + set-arg0 repeat-frame
    THEN
  THEN
  ( fix up the string and return w/ updated lengths and number )
  5 argn arg0 reverse-bytes!
  arg0 4 set-argn 2 return0-n
end

( Return a rough estimate of the number of digits to hold a max value in the radix. )
def uint64->string-allot-size ( radix -- max-bytes )
  64
  arg0 4 uint< UNLESS
    arg0 16 uint< IF 1 ELSE 2 THEN bsr
  THEN output-number-prefix-length + 2 + return1-1
end

( Create a new string from a uint64. )
def uint64->string/3 ( lo hi radix ++ out-str length )
  arg0 uint64->string-allot-size dup stack-allot-zero
  dup local0 arg2 arg1 arg0 0 uint64->byte-seq/6 2 dropn
  2dup null-terminate
  exit-frame
end

( Create a new string from a int64. )
def int64->string/3 ( lo hi radix ++ out-str length )
  arg2 arg1 int64-negative?
  arg0 uint64->string-allot-size
  0 over stack-allot-zero set-local2
  local0 IF ( prepend minus sign and negate number )
    0x2D local2 0 string-poke
    local2 1 + local1
    arg2 arg1 int64-negate
  ELSE
    local2 local1
    arg2 arg1
  THEN
  arg0 0 uint64->byte-seq/6 2 dropn
  2dup null-terminate
  local0 IF 1 + THEN swap drop local2 swap
  exit-frame
end

( Writers: )

( Write each 32 bit half as individual values. )
def write-split-uint64 ( lo hi -- )
  arg0 write-uint
  s" :" write-string/2
  arg1 write-uint
  2 return0-n
end

( Write each 32 bit half as individual values in hexadecimal. )
def write-split-hex-uint64 ( lo hi -- )
  output-base @ hex
  arg1 arg0 write-split-uint64
  local0 output-base !
  2 return0-n
end

( Write an uint64 in hexadecimal. )
def write-hex-uint64 ( lo hi -- )
  arg0 IF arg1 arg0 16 uint64->string/3 write-string/2
       ELSE arg1 write-hex-uint
       THEN 2 return0-n
end

( Write an uint64 in ~output-base~. )
def write-uint64 ( lo hi -- )
  arg0 IF arg1 arg0 output-base @ uint64->string/3 write-string/2
       ELSE arg1 write-uint
       THEN
end

( Write an int64 in ~output-base~. )
def write-int64 ( lo hi -- )
  arg1 arg0 output-base @ int64->string/3 write-string/2
  2 return0-n
end

( Write an int64 in hexadecimal. )
def write-hex-int64 ( lo hi -- )
  output-base @ hex
  arg1 arg0 write-int64
  local0 output-base !
  2 return0-n
end

( Helpful aliases: )

DEFINED? defalias> IF
  defalias> .Q write-uint64
  defalias> .q write-int64
  defalias> .Qh write-hex-uint64
  defalias> .qh write-hex-int64
THEN
