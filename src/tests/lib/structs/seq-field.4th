tmp" src/lib/assert.4th" load/2
tmp" src/lib/structs.4th" load/2
tmp" src/tests/lib/structs/assert.4th" load/2

struct: test-struct
uint<8> 16 seq-field: name
uint<32> 4 seq-field: pos

def test-seq-field-type
  ( field types )
  s" name" test-struct value-of struct-get-field struct-field -> type peek
  dup array-type kind-of? assert
  dup array-type -> element-type peek uint<8> assert-equals
  type -> byte-size peek 16 assert-equals
  s" pos" test-struct value-of struct-get-field struct-field -> type peek
  dup array-type kind-of? assert
  dup array-type -> element-type peek uint<32> assert-equals
  type -> byte-size peek 16 assert-equals
end

def test-seq-field-instance
  0
  test-struct make-instance set-local0
  local0 byte-size 32 assert-equals
  ( name )
  " Omega" local0 test-struct -> name 5 copy-byte-string/3
  local0 test-struct -> name s" Omega" assert-byte-string-equals/3
  local0 value-of 0 test-struct-name-aref peek-byte 79 assert-equals
  local0 value-of 4 test-struct-name-aref peek-byte 97 assert-equals
  ( pos )
  1 2 3 4 here local0 test-struct -> pos cell-size 4 * copy-byte-string/3
  ( todo out of bounds )
  local0 value-of 0 test-struct-pos-aref peek 4 assert-equals
  local0 value-of 1 test-struct-pos-aref peek 3 assert-equals
  local0 value-of 2 test-struct-pos-aref peek 2 assert-equals
  local0 value-of 3 test-struct-pos-aref peek 1 assert-equals
end

def test-seq-field
  test-seq-field-type
  test-seq-field-instance
end
