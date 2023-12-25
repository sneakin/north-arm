( Fields of a structure: )

( struct: struct-field
pointer<string> field: name
type field: type
value field: offset
value field: byte-size
)

null null cell-size 4 * type: struct-field

def struct-field-name end

def struct-field-type
  arg0 cell-size + set-arg0
end

def struct-field-offset
  arg0 cell-size 2 * + set-arg0
end

def struct-field-byte-size
  arg0 cell-size 3 * + set-arg0
end

def struct-get-field-loop ( name len fields -- field )
  arg0 null? IF 0 return1 THEN
  arg2 arg0 car value-of struct-field-name peek as-code-pointer arg1 1 + byte-string-equals?/3 IF
    arg0 car as-code-pointer return1
  THEN
  arg0 cdr as-code-pointer set-arg0 repeat-frame
end

def struct-get-field ( name len struct -- field )
  arg0 null? IF null 3 return1-n THEN
  arg2 arg1 arg0 struct-fields as-code-pointer peek as-code-pointer struct-get-field-loop
  dup null? IF drop arg0 type-super as-code-pointer peek value-of set-arg0 repeat-frame
	    ELSE 3 return1-n
	    THEN
end

def struct-get-field-ptr/4 ( instance name len struct -- ptr )
  arg2 arg1 arg0 value-of struct-get-field dup null? IF
    s" No field" error-line/2
    0 4 return1-n
  ELSE
    value-of struct-field-offset peek
    arg3 value-of int-add 4 return1-n
  THEN
end

def struct-get-field-ptr ( instance name len -- ptr )
  arg2 arg1 arg0 arg2 type-of struct-get-field-ptr/4 3 return1-n
end

( todo error if argument is not a struct )
( todo look for fields in supers )

defproper next-struct-field ( struct : field -- struct-field )
  ( dup type kind-of? UNLESS s" Not a struct" error-line/2 drop false THEN )
  next-token negative? IF
    ( todo error ) s" No field" write-line/2
    3 dropn false
  ELSE ( look up slot of ToS type / last word's return, emit code to add offset )
    2dup 5 overn value-of struct-get-field dup null? UNLESS
      3 set-overn 2 dropn true
    ELSE
      drop
      s" Bad field: " error-string/2 error-line/2
      drop false
    THEN
  THEN
;

defproper . ( direct-ptr struct : field -- slot-addr )
  next-struct-field IF
    value-of struct-field-offset peek
    int-add
  THEN
;

defproper -> ( typed-ptr struct : field -- slot-addr )
  swap value-of swap POSTPONE .
;

' NORTH-COMPILE-TIME defined? IF
  alias> maybe-immediate-as out-immediate-as
ELSE
  alias> maybe-immediate-as immediate-as
THEN

defproper [.] ( struct-entry : field -- code... )
  exec next-struct-field IF
    value-of struct-field-offset peek
    literal int32 swap
    literal int-add
  THEN
; maybe-immediate-as .

defproper [->] ( struct-entry : field -- code... )
  literal value-of swap [.]
; maybe-immediate-as ->

( todo lookup fields after mapping output struct addr to runtime struct )

' NORTH-COMPILE-TIME defined? IF
  : map-out-struct-to-sys ( struct-entry -- sys-struct ok? )
    from-out-addr dict-entry-data @ true
  ;
  
  : [.] ( struct-entry : field -- code... )
    map-out-struct-to-sys IF
      next-struct-field IF
	value-of struct-field-offset peek
	out-off' int32 swap
	out-off' int-add
      THEN
    ELSE
      s" Output struct does not exist." error-line/2
    THEN
  ; cross-immediate-as .

  : [->] ( struct-entry : field -- code... )
    out-off' value-of swap [.]
  ; cross-immediate-as ->
THEN

( Struct field definitions: )

( ' NORTH-COMPILE-TIME defined? UNLESS )
" name"
cell-size swap
cell-size 0 * swap
pointer<any> swap
here struct-field cons struct-field value-of struct-add-field

" type"
cell-size swap
cell-size 1 * swap
pointer<any> swap
here struct-field cons struct-field value-of struct-add-field

" offset"
cell-size swap
cell-size 2 * swap
value swap
here struct-field cons struct-field value-of struct-add-field

" byte-size"
cell-size swap
cell-size 3 * swap
value swap
here struct-field cons struct-field value-of struct-add-field

( Type fields: )
' NORTH-COMPILE-TIME defined? UNLESS ( not needed with an pointer to the system's type )
" name"
cell-size swap
cell-size 0 * swap
pointer<any> swap
here struct-field cons type value-of struct-add-field

" byte-size"
cell-size swap
cell-size 1 * swap
uint<32> swap
here struct-field cons type value-of struct-add-field

" super"
cell-size swap
cell-size 2 * swap
pointer<any> swap
here struct-field cons type value-of struct-add-field

" data"
cell-size swap
cell-size 3 * swap
pointer<any> swap
here struct-field cons type value-of struct-add-field
THEN

( Creating struct fields: )

def struct-inc-byte-size ( amt struct -- )
  arg0 struct . byte-size arg1 inc!/2
  2 return0-n
end

def struct-create-field ( name name-length type struct )
  ( create the field )
  0
  struct-field make-instance set-local0
  arg3 local0 struct-field -> name poke
  arg1 local0 struct-field -> type poke
  local0 struct-field -> type peek value-of dup IF struct . byte-size peek local0 struct-field -> byte-size poke ELSE drop THEN
  arg0 struct . byte-size peek local0 struct-field -> offset poke
  ( add field to struct type )
  local0 arg0 struct-add-field
  ( increase type's byte size )
  local0 struct-field -> byte-size peek arg0 struct-inc-byte-size
  local0 exit-frame
end

( todo sizes need to be increased on the output struct )
