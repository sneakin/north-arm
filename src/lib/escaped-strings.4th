( todo \" )

defcol return1-1 drop set-arg0 return0 endcol  

def escape?
  arg0 0x1B equals? return1
end

def control-code?
  arg0 32 int< return1
end  

( todo remove once numbers.4th rebuilds )
def parse-hex-uint ( str length -- n valid? )
  arg1 arg0 16 0 0 parse-uint-loop 2 return2-n
end

def decode-char-escape ( string length index -- new-index char )
  arg0 arg1 uint< UNLESS arg0 0 3 return2-n THEN
  arg2 arg0 int-add peek-byte
  CASE
    0x5C ( \ ) WHEN 0x5C 1 ;;
    101 ( e ) WHEN 0x1B 1 ;;
    110 ( n ) WHEN 0xA 1 ;;
    114 ( r ) WHEN 0xD 1 ;;
    116 ( t ) WHEN 9 1 ;;
    48 ( 0 ) WHEN 0 1 ;;
    0x22 ( " ) WHEN 0x22 1 ;;
    120 ( x ) WHEN
      arg0 2 + arg1 uint< UNLESS arg1 0 3 return2-n THEN
      arg2 arg0 + 1 + 2 parse-hex-uint drop 3
    ;;
    117 ( u ) WHEN
      arg0 4 + arg1 uint< UNLESS arg1 0 3 return2-n THEN
      arg2 arg0 + 1 + 4 parse-hex-uint drop 5
    ;;
    85 ( U ) WHEN
      arg0 8 + arg1 uint< UNLESS arg1 0 3 return2-n THEN
      arg2 arg0 + 1 + 8 parse-hex-uint drop 9
    ;;
    1
  ESAC
  ( todo raise error )
  arg0 + swap 3 return2-n
end

( todo output buffer )

def unescape-string/6 ( in-string in-length out-string out-length out-idx in-idx -- out-string new-length )
  arg1 arg2 uint< UNLESS
    arg3 arg1 6 return2-n
  THEN
  arg0 4 argn uint< UNLESS
    arg1 arg2 uint< IF arg3 arg1 null-terminate THEN
    arg3 arg1 6 return2-n
  THEN
  5 argn arg0 int-add peek-byte
  dup 0x5C equals? IF
    ( unescape char )
    arg0 1 + 4 argn uint< IF
      5 argn 4 argn arg0 1 + decode-char-escape
      ( todo wide chars )
      arg3 arg1 + poke-byte
      set-arg0
      arg1 1 + set-arg1
    ELSE
      arg1 arg2 uint< IF arg3 arg1 null-terminate THEN
      arg3 arg1 6 return2-n      
    THEN
  ELSE
    ( copy the byte down )
    arg1 arg2 uint< IF arg3 arg1 + poke-byte ELSE drop THEN
    arg1 1 int-add set-arg1
    arg0 1 int-add set-arg0
  THEN repeat-frame
end

def unescape-string/4 ( in-string in-length out-string out-length -- out-string new-length )
  arg3 arg2 arg1 arg0 0 0 unescape-string/6 4 return2-n
end

def unescape-string/2 ( string length -- string new-length )
  arg1 arg0 arg1 arg0 unescape-string/4 2 return2-n
end

( todo POSTPONE needs a like word that uses dict for the source. )
' NORTH-COMPILE-TIME defined? IF
  defalias> top-s" s"
  defalias> top" " 
ELSE
  ' top-s" defined? UNLESS
    alias> top-s" s"
    alias> top" "
  THEN
THEN

def es"
  POSTPONE top-s" unescape-string/2 return2
end

defcol [es"]
  literal cstring swap
  POSTPONE es" swap cs - rot
  literal int32 rot swap
endcol immediate-as s"

def e"
  POSTPONE top-s" unescape-string/2 drop return1
end

def [e"]
  literal cstring
  POSTPONE e" cs - return2
end immediate-as "

def char-code
  ( reads a single character or an escape sequence, and returns the ASCII value. )
  next-token dup IF unescape-string/2 over peek-byte ELSE 0 THEN return1
end

' NORTH-COMPILE-TIME defined? IF
  defalias> [top-s"] [s"] out-immediate-as top-s"
  defalias> [top"] ["] out-immediate-as top"
  defalias> s" es"
  defalias> " e"
ELSE
  ' [top-s"] defined? UNLESS
    alias> [top-s"] [s"] immediate-as top-s"
    alias> [top"] ["] immediate-as top"
    alias> s" es"
    alias> " e"
  THEN
THEN


( Escaping: )

def escape-string/6 ( in-str length out-str out-length in-idx out-idx -- out-str out-length )
  arg0 arg2 uint< UNLESS arg3 arg0 6 return2-n THEN
  arg1 4 argn uint< UNLESS arg3 arg0 2dup null-terminate 6 return2-n THEN
  5 argn arg1 peek-off-byte
  ( < 32 )
  dup 32 uint< IF
    dup CASE
      0x5C ( \ ) WHEN 0x5C ;;
      0x1B ( e ) WHEN 101 ;;
      0xA ( n ) WHEN 110 ;;
      0xD ( r ) WHEN 114 ;;
      9 ( t ) WHEN 116 ;;
      0 ( 0 ) WHEN 48 ;;
      -1
    ENDCASE
    dup -1 equals? UNLESS
      0x5C arg3 arg0 poke-off-byte
      arg0 1 + arg2 uint< IF
	arg3 arg0 1 + poke-off-byte
	arg0 2 + set-arg0
	arg1 1 + set-arg1
	drop repeat-frame
      ELSE
	arg3 arg0 1 + 6 return2-n
      THEN
    ELSE drop
    THEN
  THEN
  ( printable )
  dup 128 32 in-range? IF
    3 dropn
    dup 0x5C ( \ ) equals?
    over 0x22 ( " ) equals?
    or IF
      0x5C arg3 arg0 poke-off-byte
      arg0 1 + set-arg0
      arg0 arg2 uint< IF
	arg3 arg0 poke-off-byte
	arg0 1 + set-arg0
      ELSE drop
      THEN
    ELSE
      arg3 arg0 poke-off-byte
      arg0 1 + set-arg0
    THEN
  ELSE
    3 dropn
    arg0 4 + arg2 uint< IF
      0x5C arg3 arg0 poke-off-byte
      0x78 arg3 arg0 1 + poke-off-byte
      dup 4 bsr 0xF logand ascii-digit arg3 arg0 2 + poke-off-byte
      0xF logand ascii-digit arg3 arg0 3 + poke-off-byte
      arg0 4 + set-arg0
    ELSE
      arg3 arg0 2dup null-terminate 6 return2-n
    THEN
  THEN
  arg1 1 + set-arg1
  repeat-frame
end

def escape-string/4 ( in-str length out-str out-length -- out-str out-length )
  arg3 arg2 arg1 arg0 0 0 escape-string/6 4 return2-n
end

def escape-string-space-needed/4 ( in-str length in-idx size -- size )
  arg1 arg2 uint< UNLESS arg0 4 return1-n THEN
  arg3 arg1 peek-off-byte
  ( < 32 )
  dup 32 uint< IF
    CASE
      0x5C ( \ ) WHEN 0x5C ;;
      0x1B ( e ) WHEN 101 ;;
      0xA ( n ) WHEN 110 ;;
      0xD ( r ) WHEN 114 ;;
      9 ( t ) WHEN 116 ;;
      0 ( 0 ) WHEN 48 ;;
      -1
    ENDCASE
    dup -1 equals? UNLESS
      arg0 2 + set-arg0
      arg1 1 + set-arg1
      repeat-frame
    ELSE drop
    THEN
  THEN
  ( printable )
  dup 128 32 in-range? IF
    3 dropn
    dup 0x5C ( \ ) equals?
    swap 0x22 ( " ) equals?
    or IF 2 ELSE 1 THEN arg0 + set-arg0
  ELSE
    4 dropn
    arg0 4 + set-arg0
  THEN
  arg1 1 + set-arg1
  repeat-frame
end

def escape-string-space-needed/2 ( in-str length -- size )
  arg1 arg0 0 0 escape-string-space-needed/4 2 return1-n
end

def escape-string/2 ( str len ++ escaped-str new-len )
  arg1 arg0 escape-string-space-needed/2
  dup arg0 equals? IF return0 THEN
  dup stack-allot-zero
  arg1 arg0 3 overn local0 escape-string/4
  exit-frame
end

( Test:
256 stack-allot-zero var> s
es" hello\n\x02\e[1mworld\e[0m\n" 2dup write-line/2
2dup s @ 128 escape-string/4 2dup write-line/2
)

' NORTH-COMPILE-TIME defined? IF
  out' decompile-string-fn IF
    out' escape-string/2 out' decompile-string-fn set-out-var!
  THEN
ELSE
  ' decompile-string-fn defined? IF
    ' escape-string/2 decompile-string-fn !
  THEN
THEN
