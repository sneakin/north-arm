( Bit op syntax: create functions that fill in bit fields like ISA op codes. )

( todo multipliers / shifts )
( todo constants for fields > 1 )
( todo disassembly of a value to forth )
( todo auto writers to data stack )

: bit-op-constant ;
: bit-op-num-bits cell-size + ;
: bit-op-fields cell-size 2 * + ;
: bit-op-num-fields cell-size 3 * + ;

: make-bit-op
  0 0 0 0 here
;

def is-colon?
  arg0 58 equals? return1
end

def string-index-of-colon
  arg1 arg0 literal is-colon? string-index-of set-arg0 set-arg1
end

: bit-op-field-name cell-size 3 * + ;
: bit-op-field-name-length cell-size 2 * + ;
: bit-op-field-size cell-size + ;
: bit-op-field-offset ;

def parse-bit-op-field ( string length ++ name name-length size )
  ( fixme something does not like single byte names )
  0
  arg1 arg0 string-index-of-colon IF
    set-local0
    arg1 local0 allot-byte-string/2
    arg1 local0 + 1 + arg0 local0 - parse-int
    ( drop rot set-arg1 set-arg0 return1 )
    drop exit-frame
  ELSE 1 return1
  THEN
end

def bit-op-adjust-fields-loop ( field-size fields )
  arg0 IF
    arg1
    arg0 car
    dup bit-op-field-offset peek
    swap bit-op-field-size peek
    + - arg0 car bit-op-field-offset poke
    arg0 cdr set-arg0 repeat-frame
  THEN
end

def bit-op-adjust-fields ( bit-op )
  ( todo curry and map )
  arg0 bit-op-num-bits peek
  arg0 bit-op-fields peek
  bit-op-adjust-fields-loop
end

def read-bit-op/1 ( bit-op ++ bit-op )
  next-token negative? IF s" EOF reading bit-op" error-line/2 error THEN
  ( s" bit: " error-string/2 2dup error-line/2 )
  over s" ]" string-equals?/3 IF 5 dropn arg0 bit-op-adjust-fields exit-frame ELSE 3 dropn THEN
  over s" 0" string-equals?/3 IF
    5 dropn
    arg0 bit-op-num-bits dup peek 1 + swap poke
    arg0 bit-op-constant dup peek 1 bsl swap poke
    repeat-frame
  ELSE 3 dropn 
  THEN
  over s" 1" string-equals?/3 IF
    5 dropn
    arg0 bit-op-num-bits dup peek 1 + swap poke
    arg0 bit-op-constant dup peek 1 bsl 1 logior swap poke
    repeat-frame
  ELSE 3 dropn 
  THEN
  parse-bit-op-field
  ( s" Field: " error-string/2 3 overn 3 overn error-line/2 )
  arg0 bit-op-num-bits dup peek dup rot swap 4 overn + swap poke
  arg0 bit-op-constant dup peek 4 overn bsl swap poke
  arg0 bit-op-num-fields dup peek 1 + swap poke
  here arg0 bit-op-fields push-onto
  repeat-frame
end

: read-bit-op make-bit-op read-bit-op/1 ;

: mask-bits ( value max-bits -- masked-value )
  1 swap bsl 1 - logand
;

def eval-bit-op-fields-loop ( ...bit-values bit-op value field-list field-n )
  arg1 IF
    arg0 1 - set-arg0
    ( get and mask field's arg )
    arg0 4 + argn arg1 car bit-op-field-size peek mask-bits
    ( shift the value )
    arg1 car bit-op-field-offset peek bsl
    ( OR with the accumulated value )
    arg2 logior set-arg2
    ( update loop vars )
    arg1 cdr set-arg1
    repeat-frame
  THEN
end

: eval-bit-op-fields ( ...args bit-op value field-list num-fields -- ...args bit-op value )
  ( loop through the fields, ioring the next argument )
  eval-bit-op-fields-loop 2 dropn
;

: eval-bit-op ( ...args bit-op -- value )
  dup bit-op-constant peek
  over dup bit-op-fields peek
  swap bit-op-num-fields peek eval-bit-op-fields
  over bit-op-num-fields peek 1 + set-overn
  bit-op-num-fields peek 1 - dropn
;

: generate-bit-op
  literal proper-exit swap
  literal literal
  literal eval-bit-op rot swap
  here
;

def print-bit-op-field
  s" Field: " write-string/2 arg0 bit-op-field-name peek write-string
  s" :" write-string/2
  arg0 bit-op-field-size peek write-hex-uint
  s" @" write-string/2
  arg0 bit-op-field-offset peek write-hex-uint nl
end

def print-bit-op
  s" # bits:   " write-string/2 arg0 bit-op-num-bits peek write-hex-uint nl
  s" Constant: " write-string/2 arg0 bit-op-constant peek write-hex-uint nl
  s" # fields:   " write-string/2 arg0 bit-op-num-fields peek write-hex-uint nl
  arg0 bit-op-fields peek ' print-bit-op-field map-car
end

: bit-op[
  ( Reads a name and then a list of 0, 1, or a field name until a closing bracket. )
  create> does-proper
  read-bit-op ( print-bit-op ) generate-bit-op
  cs - dict dict-entry-data poke
;

