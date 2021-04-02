( Structure type to hold base structure list and field list: )

( struct: struct
field: base type
field: fields list
)

( todo add struct-fields for struct and struct-field )

" struct"
null swap
type swap
4 cell-size * swap
here type cons const> struct

def struct-name
  arg0 type-name set-arg0
end

def struct-byte-size
  arg0 type-byte-size set-arg0
end

def struct-fields
  arg0 cell-size 3 * + set-arg0
end

def struct-add-field
  arg1 arg0 struct-fields push-onto
  exit-frame
end

( Structure allocation:
  Structures are passed by pointers to a cons cell of a type structure and data.
  This necessitates the use of value-of before accessors. )
def allot-struct
  arg0 value-of struct-byte-size peek stack-allot-zero
  arg0 cons exit-frame
end

( Creating instances of structs: )
def new-struct
  struct allot-struct
  arg0 over value-of struct-name poke
  exit-frame
end
