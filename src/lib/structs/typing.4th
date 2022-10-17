( Boot strap types: )

0 const> null
( Base structure to define a type: )
( struct: type
pointer<string> field: name
value field: byte-size
type field: super
value field: data
)

" type"
null swap
null swap
4 cell-size * swap
here 0 here swap drop dup const> type

( The type returned for null values: )
( struct: null-type
    value field: data
)

(
" null-type"
null swap
null swap
cell-size swap
here type cons const> null-type
)

( Returns the value of a structure reference. )
def value-of
  arg0 cdr set-arg0
end  

def type-name arg0 cell-size 0 * + set-arg0 end
def type-byte-size arg0 cell-size 1 * + set-arg0 end
def type-super arg0 cell-size 2 * + set-arg0 end
def type-data arg0 cell-size 3 * + set-arg0 end

( Allocate a new unnamed type: )
: make-type ( base-type byte-size ++ type )
  null rot swap " anon-type" here type cons
;

( Makes a new type, names it, and creates a constant in the dictionary: )
: type: ( base-type byte-size : name ++ ... )
  make-type const>
  dict dup dict-entry-name peek cs +
  swap dict-entry-data peek value-of type-name poke
;

null cell-size type: null-type

( Returns the type of a structure reference. )
def type-of
  arg0 IF arg0 car ELSE null-type THEN set-arg0
end

def type-super-of?
  arg1 arg0 equals? IF true 2 return1-n THEN
  arg1 UNLESS arg0 null-type equals? 2 return1-n THEN
  arg1 value-of type-super peek set-arg1 repeat-frame
end

def kind-of?
  arg1 type-of arg0 type-super-of? 2 return1-n
end

def byte-size
  arg0 type-of value-of dup IF type-byte-size peek ELSE 0 THEN set-arg0
end

( Getting byte size of values and types: )
def sizeof
  arg0 type kind-of?
  IF arg0 value-of type-byte-size @
  ELSE arg0 byte-size
  THEN 1 return1-n
end

def make-typed-pointer ( ptr type ++ instance )
  ' cons tail-0
end
