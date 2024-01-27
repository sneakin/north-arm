( todo needs cross-immediates for s" and " )

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
  arg2 arg0 int-add peek-byte
  CASE
    0x5C ( \ ) WHEN 0x5C 1 ;;
    101 ( e ) WHEN 0x1B 1 ;;
    110 ( n ) WHEN 0xA 1 ;;
    114 ( r ) WHEN 0xD 1 ;;
    116 ( t ) WHEN 9 1 ;;
    48 ( 0 ) WHEN 0 1 ;;
    120 ( x ) WHEN
      arg2 arg0 + 1 + 2 parse-hex-uint drop 3
    ;;
    117 ( u ) WHEN
      arg2 arg0 + 1 + 4 parse-hex-uint drop 5
    ;;
    85 ( U ) WHEN
      arg2 arg0 + 1 + 8 parse-hex-uint drop 9
    ;;
    1
  ESAC
  ( todo raise error )
  arg0 + swap 3 return2-n
end

def unescape-string/4 ( string length out-idx in-idx -- string new-length )
  arg0 arg2 int>= IF
    arg1 arg0 int< IF arg3 arg1 null-terminate THEN
    arg1 3 return1-n
  THEN
  arg3 arg0 int-add peek-byte
  dup 0x5C equals? IF
    ( unescape char )
    arg3 arg2 arg0 1 int-add decode-char-escape
    ( todo wide chars )
    arg3 arg1 int-add poke-byte set-arg0
    arg1 1 int-add set-arg1
  ELSE
    ( copy the byte down )
    arg1 arg0 int< IF arg3 arg1 int-add poke-byte ELSE drop THEN
    arg1 1 int-add set-arg1
    arg0 1 int-add set-arg0
  THEN repeat-frame
end

def unescape-string/2 ( string length -- string new-length )
  arg1 arg0 0 0 unescape-string/4 return1-1
end

( todo POSTPONE needs a like word that uses dict for the source. )
' NORTH-COMPILE-TIME defined?
IF defalias> top-s" s"
ELSE alias> top-s" s"
THEN

def es"
  top-s" unescape-string/2 return2
end

defcol [es"]
  literal cstring swap
  POSTPONE es" swap cs - rot
  literal int32 rot swap
endcol
' NORTH-COMPILE-TIME defined?
IF out-immediate-as s"
ELSE immediate-as s"
THEN

def e"
  top-s" unescape-string/2 drop return1
end

def [e"]
  literal cstring
  POSTPONE e" cs - return2
end
' NORTH-COMPILE-TIME defined?
IF out-immediate-as "
ELSE immediate-as "
THEN

def char-code
  ( reads a single character or an escape sequence, and returns the ASCII value. )
  next-token dup IF unescape-string/2 over peek-byte ELSE 0 THEN return1
end

( Escaping: )

def escape-string/6 ( in-str length out-str out-length in-idx out-idx -- out-str out-length )
  arg1 4 argn uint< UNLESS arg3 arg0 6 return2-n THEN
  arg0 arg2 uint< UNLESS arg3 arg0 6 return2-n THEN
  5 argn arg1 peek-off-byte
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
      0x5C arg3 arg0 poke-off-byte
      arg3 arg0 1 + poke-off-byte
      arg0 2 + set-arg0
      arg1 1 + set-arg1
      repeat-frame
    ELSE drop
    THEN
  THEN
  ( printable )
  dup 128 32 in-range? IF
    3 dropn
    arg3 arg0 poke-off-byte
    arg0 1 + set-arg0
  ELSE
    3 dropn
    s" \\x" arg3 arg0 + swap copy
    dup 4 bsr 0xF logand ascii-digit arg3 arg0 2 + poke-off-byte
    0xF logand ascii-digit arg3 arg0 3 + poke-off-byte
    arg0 4 + set-arg0
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
    arg0 1 + set-arg0
  ELSE
    3 dropn
    arg0 4 + set-arg0
  THEN
  arg1 1 + set-arg1
  repeat-frame
end

def escape-string-space-needed/2 ( in-str length -- size )
  arg1 arg0 0 0 escape-string-space-needed/4 2 return1-n
end

def escape-string/2 ( str len ++ escaped-str new-len )
  ( count unprintable bytes: at most 4 bytes per )
  arg1 arg0 escape-string-space-needed/2
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
    out-off' escape-string/2 out' decompile-string-fn dict-entry-data @ from-out-addr data-var-init-value !
  THEN
ELSE
  ' decompile-string-fn defined IF
    ' escape-string/2 decompile-string-fn !
  THEN
THEN
