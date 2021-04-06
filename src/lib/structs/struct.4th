( Structure type to hold base structure list and field list: )

( struct: struct
field: name pointer<string>
field: byte-size value
field: super type
field: fields list
)

( todo add struct-fields for struct and struct-field )

null type cell-size 4 * type: struct

def struct-name
  arg0 type-name set-arg0
end

def struct-byte-size
  arg0 type-byte-size set-arg0
end

def struct-super
  arg0 type-super set-arg0
end

def struct-fields
  arg0 type-data set-arg0
end

def struct-add-field
  arg1 arg0 struct-fields push-onto
  exit-frame
end

( Structure allocation:
  Structures are passed by pointers to a cons cell of a type structure and data.
  This necessitates the use of value-of before accessors. )
def allot-struct
  arg0 value-of struct-byte-size peek stack-allot-zero exit-frame
end

def make-instance ( type ++ ... instance )
  arg0 allot-struct
  arg0 cons exit-frame
end

( Creating instances of structs: )
def new-struct ( name ++ struct )
  struct make-instance
  arg0 over value-of struct-name poke
  exit-frame
end
