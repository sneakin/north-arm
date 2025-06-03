( Arbitrary radix: )

10 defvar> output-base
0 defvar> output-number-prefix

4 defconst> output-number-prefix-length

( todo cap number digits to buffer size, will require useless divide[s] or divide by radix )

( The loop to convert an unsigned integer into a string. )
def uint->byte-seq/5 ( out out-size n radix digit -- out length remaining )
  arg0 0 equals? arg2 or IF
    arg0 arg3 uint< IF
      arg2 arg1 uint-divmod
      ascii-digit 4 argn arg0 string-poke
      set-arg2 arg0 1 + set-arg0 repeat-frame
    THEN
  THEN
  4 argn arg0 reverse-bytes! arg0 arg2 4 return2-n
end

( A very basic unsigned integer to a string / byte sequence. )
def uint->byte-seq/4 ( out out-size n radix -- out length remaining )
  0 ' uint->byte-seq/5 tail+1
end

( Converts an unsigned integer into a string possibly aligning the number right using the provided character of padding. )
def uint->string/6 ( n out-ptr out-max radix digit padding -- output-start )
  4 argn arg3 5 argn arg2 uint->byte-seq/4
  UNLESS ( right justify the number w/ padding )
    dup arg3 uint<
    arg0 and IF
      2dup over arg3 2swap arg0 string-align-right
      rot 2 dropn
    THEN
  THEN
  2dup null-terminate
  drop 6 return1-n
end

def uint->string-no-prefix/4 ( n out-ptr out-max radix -- out-ptr length )
  arg2 arg1 arg3 arg0 uint->byte-seq/4 drop
  2dup null-terminate
  4 return2-n
end

( Returns the prefix for a given radix. )
def radix-prefix ( radix -- str length )
  arg0 64 2 in-range? UNLESS s" ERR#" 1 return2-n THEN ( todo raise error )
  arg0 16 equals? IF s" 0x" 1 return2-n THEN
  arg0 8 equals? IF s" 0" 1 return2-n THEN
  arg0 2 equals? IF s" 0b" 1 return2-n THEN
  ( BB# )
  4 stack-allot
  arg0 over 4 10 uint->string-no-prefix/4
  char-code # 3 overn 3 overn string-poke
  1 + 2dup null-terminate
  exit-frame
end

def copy-output-number-prefix ( out-ptr out-max radix -- out-ptr length )
  output-number-prefix @ dup IF output-base @ equals? not THEN
  IF
    0 arg0 radix-prefix
    arg1 umin set-local0
    arg2 local0
    copy
    arg2 local0 3 return2-n
  THEN arg2 0 3 return2-n
end

( Converts an unsigned integer into a string possibly with a base prefix. )
def uint->string/4 ( n out-ptr out-max radix -- out-ptr length )
  arg3 IF arg2 arg1 arg0 copy-output-number-prefix ELSE arg2 0 THEN
  2dup arg1 advance-string-len arg3 arg0 uint->byte-seq/4
  drop
  2dup null-terminate
  local1 + arg2 swap 4 return2-n
end

cell-size 8 * defconst> bits-per-cell

( todo factor in the outputted number too? N < radix always 1 digit. )

( Return a rough size to hold the maximum value using the radix. )
def uint->string-allot-size ( radix -- max-bytes )
  bits-per-cell
  arg0 4 uint< UNLESS
    arg0 16 uint< IF 1 ELSE 2 THEN bsr
  THEN output-number-prefix-length + 2 + return1-1
end

( Create a new string of an unsigned integer as a string with the provided radix. )
def uint->string-rad/2 ( n radix ++ string length )
  arg0 uint->string-allot-size dup stack-allot-zero
  arg1 over local0 arg0 uint->string/4
  exit-frame
end

( Convert an unsigned integer into a string with ~output-base~. )
def uint->string/3 ( n output out-max -- output length )
  arg2 arg1 arg0 output-base peek uint->string/4 set-arg0 set-arg1
end

( Create a new string from an unsigned integer in ~output-base~. )
def uint->string ( n ++ string length )
  arg0 output-base peek uint->string-rad/2 exit-frame
end

( Converts an integer into a string possibly with a base prefix. )
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

( Create a new string of an integer as a string with the provided radix. )
def int->string-rad/2 ( n radix ++ string length )
  arg0 uint->string-allot-size dup stack-allot-zero
  arg1 over local0 arg0 int->string/4
  exit-frame
end

( Convert an integer into a string with ~output-base~. )
def int->string/3 ( n out-ptr out-max -- out-ptr length )
  arg2 arg1 arg0 output-base peek int->string/4 set-arg1 set-arg2 1 return0-n
end

( Create a new string from an integer in ~output-base~. )
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
  arg2 arg1 arg0 output-base peek arg0 char-code 0 uint->string/6
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
