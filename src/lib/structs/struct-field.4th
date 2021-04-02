( Fields of a structure: )

( struct: struct-field
field: name pointer<string>
field: type type
field: offset value
field: byte-size value
)

" struct-field"
null swap
struct swap
4 cell-size * swap
here struct cons const> struct-field

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
