( A base type for arrays of a contiguous memory region: )
struct: array-type
inherits: struct
field: element-type pointer<any>

def array-type-element-size
  arg0 array-type -> element-type peek type -> byte-size peek set-arg0
end

( Creates a nuw type for an array of the type argument. )
def make-array-type ( element-type number-of-elements )
  array-type make-instance
  " array" over struct -> name poke
  array-type over struct -> super poke
  arg1 struct -> byte-size peek arg0 * over struct -> byte-size poke
  arg1 over array-type -> element-type poke
  exit-frame
end
