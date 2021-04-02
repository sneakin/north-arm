( A base type for arrays of a contiguous memory region: )
struct: array-type
field: struct struct
field: element-type pointer<any>

def array-type-element-size
  arg0 value-of array-type-element-type peek value-of type-byte-size set-arg0
end

( Creates a nuw type for an array of the type argument. )
def make-array-type ( element-type number-of-elements )
  array-type allot-struct
  " array" over value-of struct-name poke
  arg1 value-of struct-byte-size peek arg0 * over value-of struct-byte-size poke
  arg1 over value-of array-type-element-type poke
  exit-frame
end
