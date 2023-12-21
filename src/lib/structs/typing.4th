( Boot strap types: )

( fixme review value-of calls. may need to be value-ptr )
( todo a @cs that adds cs when the pointer is in the code segment )

' NORTH-COMPILE-TIME defined? [IF]
0 defconst> null
[ELSE]
0 const> null
[THEN]

( fixme does type-data need storage? only used by struct as the first offset. )

( Base structure to define a type: )
( struct: type
pointer<string> field: name
value field: byte-size
type field: super
value field: data
)

' NORTH-COMPILE-TIME defined? [IF]
  type defconst-offset> type
[ELSE]
  " type"
  null swap
  null swap
  4 cell-size * swap
  here 0 here swap drop dup
  const> type
[THEN]

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

def as-code-pointer ( offset-or-ptr -- ptr )
  arg0 dup IF dup code-offset? IF cs + set-arg0 THEN THEN
end

( Returns the value of a structure reference. )
def value-of-raw
  arg0 as-code-pointer cdr set-arg0
end  

def value-of
  arg0 value-of-raw dup as-code-pointer set-arg0
end  

def type-name arg0 cell-size 0 * + set-arg0 end
def type-byte-size arg0 cell-size 1 * + set-arg0 end
def type-super arg0 cell-size 2 * + set-arg0 end
def type-data arg0 cell-size 3 * + set-arg0 end

( Allocate a new unnamed type: )
def make-type ( base-type byte-size ++ type )
  null arg1 arg0 " anon-type" here type cons exit-frame
end

( Makes a new type, names it, and creates a constant in the dictionary: )
' NORTH-COMPILE-TIME defined? [IF]
  def const> ( value : name ++ word )
    create>
    dup ' do-const does
    arg0 over dict-entry-data !
    exit-frame
  end
[THEN]

def type: ( base-type byte-size : name ++ ... )
  arg1 arg0 make-type const>
  dict dup dict-entry-name peek cs +
  swap dict-entry-data peek value-of type-name poke
  exit-frame
end

' NORTH-COMPILE-TIME defined? [IF]
  ( type: that also outputs to the data stack )
  alias> sys-type: type:

  : create-out-type-entry
    s" Type: " error-string/2
    dup value-of type-name @ dup string-length 2dup error-line/2 create
    defconst-offset
  ;
  
  : type: ( base-type byte-size : name ++ ... )
    sys-type: dict exec-abs create-out-type-entry
  ;
[THEN]

null cell-size type: null-type

( Returns the type of a structure reference. )
def type-of
  arg0 IF arg0 car as-code-pointer ELSE null-type THEN set-arg0
end

def type-super-of?
  arg1 arg0 equals? IF true 2 return1-n THEN
  arg1 UNLESS arg0 null-type equals? 2 return1-n THEN
  arg1 value-of type-super peek as-code-pointer set-arg1 repeat-frame
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
