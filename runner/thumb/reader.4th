( Character classification: )

defcol is-space?
  swap int32 0x20 equals? swap
endcol

defcol newline?
  swap int32 0x0A equals? swap
endcol

defcol whitespace?
  over newline? IF int32 1
  ELSE
    over is-space? IF int32 1 ELSE int32 0 THEN
  THEN
  rot drop
endcol

defcol not-whitespace?
  swap whitespace? not swap
endcol

( Token Reader: )

defcol reader-null-fn
  int32 -1 swap
endcol

defcol make-reader
  int32 0 swap
  int32 0 swap
  int32 0 swap
  int32 0 swap
  int32 0 swap
  int32 0 swap
  int32 0 swap
  literal reader-null-fn swap
  here cell-size + swap
endcol

defcol reader-buffer
  swap cell-size int32 7 * + swap
endcol

defcol reader-buffer-length
  swap cell-size int32 6 * + swap
endcol

defcol reader-length
  swap cell-size int32 5 * + swap
endcol

defcol reader-offset
  swap cell-size int32 4 * + swap
endcol

defcol reader-reader-next
  swap cell-size int32 3 * + swap
endcol

defcol reader-reader-data
  swap cell-size int32 2 * + swap
endcol

defcol reader-reader-finalizer
  swap cell-size int32 1 * + swap
endcol

defcol reader-reader-fn
  swap cell-size int32 0 * + swap
endcol

( todo read return 0 on EOF, not -1; could use 0 for length on eof but need a flag for the first read. )
( todo reader stack: pop off when EOF reached )

def reader-read-more
  arg0 reader-reader-fn peek null? IF int32 -1 return1 THEN
  arg0
  arg0 reader-buffer peek
  arg0 reader-buffer-length peek
  arg0 reader-reader-fn peek exec
  dup int32 0 equals? IF drop int32 -1 THEN
  dup arg0 reader-length poke
  int32 0 arg0 reader-offset poke
  return1
end

def reader-top-up
  arg0 reader-length peek negative? IF return1 THEN
  arg0 reader-offset peek
  int<= IF arg0 reader-read-more return1 THEN
  int32 0 return1
end

def reader-peek-byte ( reader -- byte )
  arg0 reader-top-up negative? IF set-arg0 return THEN
  arg0 reader-buffer peek
  arg0 reader-offset peek
  string-peek set-arg0
end

defcol reader-inc-offset!
  swap reader-offset dup peek int32 1 + swap poke
endcol

def reader-read-byte ( reader -- byte )
  arg0 reader-peek-byte
  negative? IF set-arg0 return THEN
  arg0 reader-inc-offset!
  set-arg0
end

def reader-skip-until/3 ( fn reader bytes-read ++ last-byte )
  arg1 reader-peek-byte negative? IF return1 THEN
  dup arg2 exec-abs IF return1 ELSE drop THEN
  arg1 reader-inc-offset!
  arg0 int32 1 + set-arg0
  repeat-frame
end

def reader-skip-until ( fn reader -- bytes-read last-byte )
  arg1 arg0 int32 0 reader-skip-until/3
  set-arg0
  set-arg1
end

def reader-read-until/5 ( ptr max-length fn reader bytes-read ++ last-byte )
  ( don't overfill )
  arg3 arg0 int<= IF int32 0 return1 THEN
  ( read a byte, return on EOF )
  arg1 reader-peek-byte negative? IF return1 THEN
  ( call the predicate )
  dup arg2 exec-abs IF return1 THEN
  ( store the byte )
  int32 4 argn arg0 string-poke
  ( inc counter )
  arg1 reader-inc-offset!
  arg0 int32 1 + set-arg0
  repeat-frame
end

def reader-read-until ( ptr max-length fn reader -- ptr bytes-read last-byte )
  arg3 arg2 arg1 arg0 int32 0 reader-read-until/5
  set-arg1 set-arg2
  drop-locals end-frame
  drop swap drop exit
end

def reader-next-token ( ptr max-length reader -- ptr length last-byte )
  pointer not-whitespace? arg0 reader-skip-until negative? IF
    set-arg0
    int32 0 set-arg1
    return
  THEN
  int32 2 dropn
  arg2 arg1 pointer whitespace? arg0 reader-read-until
  set-arg0
  2dup null-terminate
  set-arg1
end

def reader-skip-tokens-until/4 ( ptr size fn reader )
  arg3 arg2 arg0 reader-next-token negative? UNLESS
    drop arg1 exec-abs UNLESS
      int32 2 dropn repeat-frame
    THEN
  THEN
end
  
def reader-skip-tokens-until ( fn reader )
  int32 128 stack-allot
  int32 128
  arg1
  arg0
  reader-skip-tokens-until/4
end

def is-digit?
  arg0 int32 57 int32 48 in-range? return1
end

def is-lower-alpha?
  arg0 int32 122 int32 97 in-range? return1
end

def is-upper-alpha?
  arg0 int32 90 int32 65 in-range? return1
end

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

10 defvar> input-base

def parse-int-base ( string index -- base index )
  ( Input base )
  arg1 arg0 string-peek int32 48 equals? UNLESS
    input-base peek
    arg0
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
  arg1 int32 0 string-peek int32 45 equals? IF
    arg0 int32 1 int<= IF
      int32 0 set-arg1
      int32 0 set-arg0
      return
    THEN
    
    arg1 int32 1 + arg0 int32 1 - parse-uint IF
      negate
      int32 1 set-arg0
    ELSE
      int32 0 set-arg0
    THEN
  ELSE
    arg1 arg0 parse-uint
    set-arg0
  THEN
  set-arg1
end
