( Fields of a structure: )

( struct: struct-field
field: name pointer<string>
field: type type
field: offset value
field: byte-size value
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

def struct-get-field-loop
  arg0 null? IF 0 return1 THEN
  arg2 arg0 car value-of struct-field-name peek arg1 byte-string-equals?/3 IF
    arg0 car return1
  THEN
  arg0 cdr set-arg0 repeat-frame
end

def struct-get-field ( name len struct -- field )
  arg0 null? IF null 3 return1-n THEN
  arg2 arg1 arg0 struct-fields peek struct-get-field-loop
  dup null? IF drop arg0 type-super peek value-of set-arg0 repeat-frame
	    ELSE 3 return1-n
	    THEN
end

( todo error if argument is not a struct )
( todo look for fields in supers )

: next-struct-field ( struct : field -- struct-field )
  ( dup type kind-of? UNLESS s" Not a struct" error-line/2 drop false THEN )
  next-token negative? IF
    ( todo error ) s" No field" write-line/2
    3 dropn false
  ELSE ( look up slot of ToS type / last word's return, emit code to add offset )
    3 overn value-of struct-get-field dup null? UNLESS
      swap drop true
    ELSE
      s" Bad field" error-line/2
      2 dropn false
    THEN
  THEN
;

: . ( direct-ptr struct : field -- slot-addr )
  next-struct-field IF
    value-of struct-field-offset peek
    int-add
  THEN
;

: -> ( typed-ptr struct : field -- slot-addr )
  swap value-of swap .
;

: [.] ( struct-entry : field -- code... )
  exec next-struct-field IF
    value-of struct-field-offset peek
    literal int32 swap
    literal int-add
  THEN
; immediate-as .

: [->] ( struct-entry : field -- code... )
  literal value-of swap [.]
; immediate-as ->

( Struct field definitions: )

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

( Struct fields: )
" name"
cell-size swap
cell-size 0 * swap
pointer<any> swap
here struct-field cons struct value-of struct-add-field

" byte-size"
cell-size swap
cell-size 1 * swap
uint<32> swap
here struct-field cons struct value-of struct-add-field

" super"
cell-size swap
cell-size 2 * swap
pointer<any> swap
here struct-field cons struct value-of struct-add-field

" fields"
cell-size swap
cell-size 3 * swap
pointer<any> swap
here struct-field cons struct value-of struct-add-field

( Creating struct fields: )

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
  arg0 struct . byte-size peek
  local0 struct-field -> byte-size peek +
  arg0 struct . byte-size poke
  local0 exit-frame
end
