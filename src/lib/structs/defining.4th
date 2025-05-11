( Structures: )

( todo binary output structures )
( todo usage in [cross] compiling out )
( todo defconst-offset: best name? better to take string? )    
( todo initializers for structs and each field )
( todo have a list of inherited structs and the offset of the field's storage space )
( todomrename this inherits as include. also store the offset to thebfields for . and -> to lookup. )

( struct: point2d
    inherits: numeric
    int32 field: x
    int32 field: y

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
SYS:DEFINED? NORTH-COMPILE-TIME UNLESS
  null var> *this-struct*
ELSE
  null defvar> *this-struct*

  def does-const
    arg0 ' do-const does
    1 return0-n
  end
THEN

( Creates a new dictionary entry with a struct as a value. )
def create-struct ( name name-len ++ )
  arg1 arg0 create does-const
  arg1 new-struct dup dict dict-entry-data poke
  *this-struct* poke
  exit-frame
end

( Starts a new struct definition. )
def struct: ( : name )
  ( generate type )
  next-token allot-byte-string/2 create-struct exit-frame
end

SYS:DEFINED? NORTH-COMPILE-TIME IF
  NORTH-COMPILE-TIME @ UNLESS
    def struct: ( : name )
      ( generate type )
      next-token allot-byte-string/2 create-struct
      dict exec-abs create-out-type-entry
      exit-frame
    end
  THEN

  SYS:DEFINED? sys-struct: UNLESS
    alias> sys-struct: struct:
    : struct: sys-struct: dict exec-abs create-out-type-entry ;
  THEN
THEN

( Structure field definitions: )

def does-field-accessor
  arg1 pointer field-accessor does
  arg0 value-of arg1 dict-entry-data poke
end

def generate-struct-accessor-name
  arg0 struct -> name peek
  arg1 struct-field -> name peek
  0
  local0 string-length local1 string-length + 3 + ( fixme one too many )
  dup stack-allot-zero set-local2
  local2 local3 local0 " -" string-append/4 2 dropn
  local2 local3 local2 local1 string-append/4
  exit-frame
end

def generate-struct-accessor
  arg1 arg0 generate-struct-accessor-name
  create arg1 does-field-accessor drop
  exit-frame
end

( Add a new field to the current structure. )
def field: ( type : name )
  next-token allot-byte-string/2
  arg0
  *this-struct* peek value-of
  struct-create-field
  ( generate accessor )
  *this-struct* peek generate-struct-accessor
  exit-frame
end

def inherits: ( : type )
  0
  ( read type )
  next-type dup UNLESS s" Warning: Unknown type " error-line/2 return0 THEN
  set-local0
  local0 *this-struct* peek value-of type-super poke
  ( add field )
  local0 value-of type-name peek
  dup string-length
  local0
  *this-struct* peek value-of struct-create-field
  ( generate accessor )
  *this-struct* peek generate-struct-accessor
  ( todo add multiple inheritance to struct: type, offset )
  exit-frame
end
