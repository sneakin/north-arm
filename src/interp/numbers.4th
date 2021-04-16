( Number input: )

10 defvar> input-base

def char-to-digit ( char -- digit )
  arg0 is-digit? IF
    int32 48
  ELSE
    is-lower-alpha? IF
      int32 97
    ELSE
      is-upper-alpha? IF int32 65 ELSE int32 -1 set-arg0 return THEN
    THEN
    int32 10 -
  THEN
  - set-arg0
end

( todo handle overflow; base prefixes: 0x, 2#101; negatives )

def parse-uint-loop ( string length base offset n ++ valid? )
  arg3 arg1 uint<= IF int32 1 return1 THEN
  int32 4 argn arg1 string-peek char-to-digit
  negative? IF int32 0 return1 THEN
  dup arg2 int>= IF int32 0 return1 THEN
  arg0 arg2 * + set-arg0
  ( inc offset & repeat )
  arg1 int32 1 + set-arg1
  repeat-frame
end

( fixme length one short in base 8 from parsing max int )

def parse-int-base ( string index -- base index )
  ( Not 0... )
  arg1 arg0 string-peek int32 48 equals? UNLESS
    ( $N hexadecimal )
    arg1 arg0 string-peek int32 36 equals? IF
      int32 16
      arg0 int32 1 +
    ELSE
      ( Input base )
      input-base peek
      arg0
    THEN
  ELSE
    ( 0xN Hexadecimal )
    arg1 arg0 int32 1 + string-peek int32 120 equals? IF
      int32 16
      arg0 int32 2 +
    ELSE
      ( 0bN binary )
      arg1 arg0 int32 1 + string-peek int32 98 equals? IF
        int32 2
        arg0 int32 2 +
      ELSE ( 0N Octal )
        int32 8
        arg0 int32 1 +
      THEN
    THEN
  THEN

  return2
end

def parse-uint ( str length -- n valid? )
  arg1 arg0
  arg1 int32 0 parse-int-base 2swap int32 2 dropn
  int32 0 parse-uint-loop
  set-arg0 set-arg1
end

def parse-int ( str length -- n valid? )
  ( leading minus sign: )
  arg1 int32 0 string-peek int32 45 equals? IF
    ( no digits )
    arg0 int32 1 int<= IF
      int32 0 set-arg1
      int32 0 set-arg0
      return
    THEN
    ( read the number )
    arg1 int32 1 + arg0 int32 1 - parse-uint IF
      negate
      int32 1 set-arg0
    ELSE
      int32 0 set-arg0
    THEN
  ELSE
    ( read the number )
    arg1 arg0 parse-uint
    set-arg0
  THEN
  set-arg1
end
