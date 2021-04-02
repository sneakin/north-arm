( Structures: )

( todo binary output structures )

( struct: point2d
    inherits: numeric
    field: x int32 0
    field: y int32 0

  alloc-point2d
  3 over point-2d-x !
  -3 over point-2d-y !
  dup type-of point2d assert-equals
  dup byte-size 8 assert-equals
  dup point2d-x @ 3 assert-equals
  dup point2d-y @ -3 assert-equals
)

def next-word
  next-token negative? IF 0 ELSE dict dict-lookup UNLESS 0 THEN THEN return1
end

def next-type
  next-word dup
  IF dict-entry-data peek
     dup type kind-of? IF return1 THEN
  THEN
  ( todo error )
  null return1
end

( Structure defining words: )

( The last struct that was defined: )
null var> *this-struct*

( Creahes a new dictionary entry with a struct as a value. )
def make-struct
  arg1 arg0 error-line/2
  arg1 arg0 create does-const
  arg1 new-struct dup dict dict-entry-data poke
  *this-struct* poke
  exit-frame
end

( Starts a new struct definition. )
def struct: ( : name )
  ( generate type )
  next-token allot-byte-string/2 make-struct exit-frame
end

( Structure field definitions: )

def generate-struct-accessor-name
  arg0 struct-name peek dup write-line
  arg1 struct-field-name peek dup write-line
  0
  local0 string-length local1 string-length + 3 + ( fixme one too many )
  dup stack-allot-zero set-local2
  local2 local3 local0 " -" string-append/4 write-line/2
  local2 local3 local2 local1 string-append/4 2dup write-line/2
  exit-frame
end

def does-field-accessor
  arg1 pointer field-accessor does
  arg0 arg1 dict-entry-data poke
end

def generate-struct-accessor
  arg1 arg0 generate-struct-accessor-name
  create arg1 does-field-accessor drop
  exit-frame
end

def struct-create-field ( name name-length type struct )
  ( create the field )
  0
  struct-field allot-struct set-local0
  arg3 local0 value-of struct-field-name poke
  arg1 local0 value-of struct-field-type poke
  local0 value-of struct-field-type peek value-of dup IF struct-byte-size peek local0 value-of struct-field-byte-size poke ELSE drop THEN
  arg0 struct-byte-size peek local0 value-of struct-field-offset poke
  ( add field to struct type )
  local0 arg0 struct-add-field
  ( increase type's byte size )
  arg0 struct-byte-size peek
  local0 value-of struct-field-byte-size peek +
  arg0 struct-byte-size poke
  ( generate accessor )
  local0 value-of arg0 generate-struct-accessor
  local0 exit-frame
end

( todo initializers for structs and each field )

( Add a new field to the current structure. )
def field: ( : name type )
  next-token allot-byte-string/2
  next-type
  *this-struct* peek value-of
  struct-create-field
  exit-frame
end


def inherits: ( : type )
  0
  ( read type )
  next-type dup UNLESS s" Warning: Unknown type " error-line/2 return THEN
  set-local0
  local0 *this-struct* peek value-of type-super poke
  ( add field )
  local0 value-of type-name peek
  dup string-length
  local0
  *this-struct* peek value-of
  struct-create-field
  ( todo add multiple inheritance to struct: type, offset )
  exit-frame
end
