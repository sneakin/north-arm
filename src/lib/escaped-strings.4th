( todo \" )
( todo is stack and data space wasetd unescaping? )

0x5C const> char-back-slash
0x22 const> char-dquote

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
    char-back-slash ( \ ) WHEN char-back-slash 1 ;;
    101 ( e ) WHEN 0x1B 1 ;;
    110 ( n ) WHEN 0xA 1 ;;
    114 ( r ) WHEN 0xD 1 ;;
    116 ( t ) WHEN 9 1 ;;
    48 ( 0 ) WHEN 0 1 ;;
    char-dquote ( " ) WHEN char-dquote 1 ;;
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
  dup char-back-slash equals? IF
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


( Escaping: )

def escape-string/6 ( in-str length out-str out-length in-idx out-idx -- out-str out-length )
  arg0 arg2 uint< UNLESS arg3 arg0 6 return2-n THEN
  arg1 4 argn uint< UNLESS arg3 arg0 2dup null-terminate 6 return2-n THEN
  5 argn arg1 peek-off-byte
  ( < 32 )
  dup 32 uint< IF
    dup CASE
      char-back-slash ( \ ) WHEN char-back-slash ;;
      0x1B ( e ) WHEN 101 ;;
      0xA ( n ) WHEN 110 ;;
      0xD ( r ) WHEN 114 ;;
      9 ( t ) WHEN 116 ;;
      0 ( 0 ) WHEN 48 ;;
      -1
    ENDCASE
    dup -1 equals? UNLESS
      char-back-slash arg3 arg0 poke-off-byte
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
    dup char-back-slash ( \ ) equals?
    over char-dquote ( " ) equals?
    or IF
      char-back-slash arg3 arg0 poke-off-byte
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
      char-back-slash arg3 arg0 poke-off-byte
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
      char-back-slash ( \ ) WHEN char-back-slash ;;
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
    dup char-back-slash ( \ ) equals?
    swap char-dquote ( " ) equals?
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

( Decompiler hook: )

' NORTH-COMPILE-TIME defined? IF
  out' decompile-string-fn IF
    out' escape-string/2 out' decompile-string-fn set-out-var!
  THEN
ELSE
  ' decompile-string-fn defined? IF
    ' escape-string/2 decompile-string-fn !
  THEN
THEN


( Readers: )

def char-code
  ( reads a single character or an escape sequence, and returns the ASCII value. )
  next-token dup IF unescape-string/2 over peek-byte ELSE 0 THEN return1
end

( fixme POSTPONE failed to work with char-code )
def [char-code]
  literal uint32 ' char-code exec-abs return2
end immediate-as char-code

def read-until-unescaped-char-fn ( char [ end-char esc-char escape? ] -- done? )
  arg1 CASE
    ( escape )
    arg0 1 seq-peek OF
      ( is escaped? )
      arg0 0 seq-peek UNLESS
	1 arg0 0 seq-poke			 
	false 2 return1-n
      THEN
    ENDOF
    ( terminal )
    arg0 2 seq-peek OF
      ( is escaped? )
      arg0 0 seq-peek UNLESS
	true 2 return1-n
      THEN
    ENDOF
  ENDCASE
  ( is escaped? )
  arg0 0 seq-peek IF 0 arg0 0 seq-poke THEN
  false 2 return1-n
end

def read-until-unescaped-char ( str len char -- str len last-byte )
  arg0 char-back-slash 0 here ' read-until-unescaped-char-fn swap partial-first
  arg2 arg1 3 overn read-until
  set-arg0 set-arg1
end

def read-escaped-string/2 ( str len -- str len )
  arg1 arg0 char-dquote read-until-unescaped-char drop 2 return2-n
end

defcol etmp" ( ++ token-buffer-ptr bytes-read )
  ( eat leading space )
  the-reader peek reader-read-byte drop
  ( read the string )
  string-buffer peek token-buffer-max char-dquote read-until-unescaped-char
  drop
  unescape-string/2 2dup null-terminate
  ( update the string-buffer )
  dup string-buffer-length poke
  swap rot
  ( eat the terminal quote )
  the-reader peek reader-read-byte drop
endcol immediate

def dallot-byte-string/2
  dhere
  arg1 local0 arg0 copy
  local0 arg0 null-terminate
  local0 arg0 + 1 + cell-size pad-addr dmove
  local0 arg0 2 return2-n
end

def ec" ( ++ ...bytes len )
  POSTPONE etmp" allot-byte-string/2 swap drop exit-frame
end

def ed" ( -- ptr len )
  POSTPONE etmp" dallot-byte-string/2 return2
end

def es" ( -- ptr len )
  POSTPONE etmp" dallot-byte-string/2 return2
end

def e" ( ++ ...bytes ptr )
  POSTPONE etmp" allot-byte-string/2 drop exit-frame
end

defcol [es"]
  literal cstring swap
  POSTPONE es" swap cs - rot
  literal int32 rot swap
endcol immediate-as s"

def [e"]
  literal cstring
  POSTPONE es" drop cs - return2
end immediate-as "

def .e"
  POSTPONE etmp" write-string/2
end

: [.e"]
  [es"] literal write-string/2
;

( todo POSTPONE needs a like word that uses dict for the source. )

' NORTH-COMPILE-TIME defined? IF
  defalias> top-s" s"
  defalias> top" " 
  defalias> [top-tmp"] tmp" out-immediate-as top-tmp"
  defalias> [top-s"] [s"] out-immediate-as top-s"
  defalias> [top"] ["] out-immediate-as top"
  defalias> tmp" etmp" out-immediate
  defalias> d" ed"
  defalias> s" es"
  defalias> " e"
  defalias> ." .e"
  defalias> [."] [.e"] out-immediate-as ."
ELSE
  ' top-s" defined? UNLESS
    alias> top-s" s"
    alias> top" "
  THEN
  ' [top-s"] defined? UNLESS
    alias> [top-tmp"] tmp" immediate-as top-tmp"
    alias> [top-s"] [s"] immediate-as top-s"
    alias> [top"] ["] immediate-as top"
    alias> tmp" etmp" immediate
    alias> d" ed"
    alias> s" es"
    alias> " e"
    alias> ." .e"
    alias> [."] [.e"] immediate-as ."
  THEN
THEN
