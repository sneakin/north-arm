tmp" src/lib/assert.4th" load/2
tmp" src/lib/structs.4th" load/2
tmp" src/tests/lib/structs/assert.4th" load/2

def test-struct-type
  struct s" struct" type cell-size 4 * 4 assert-type
  ( fields )
  struct s" name" pointer<any> 0 cell-size assert-struct-field
  struct s" byte-size" uint<32> cell-size cell-size assert-struct-field
  struct s" super" pointer<any> cell-size 2 * cell-size assert-struct-field
  struct s" fields" pointer<any> cell-size 3 * cell-size assert-struct-field
end

def test-allot-struct
  0
  struct allot-struct set-local0
  locals here - struct value-of type-byte-size peek int>= assert
  locals here - struct value-of type-byte-size peek 3 * int< assert
  local0 struct cons null 0 null 0 0 assert-struct
end

def test-make-instance
  0
  struct make-instance set-local0
  locals here - struct value-of type-byte-size peek int>= assert
  local0 null 0 null 0 0 assert-struct
end

def test-new-struct
  0
  " test-struct" new-struct set-local0
  locals here - struct value-of type-byte-size peek int>= assert
  local0 s" test-struct" null 0 0 assert-struct
end

def test-struct-add-field
  0
  " test-struct" new-struct set-local0
  124 local0 value-of struct-add-field
  local0 value-of struct-fields peek car 124 assert-equals
end

def test-struct-create-field
  0 0 0
  " test-struct" new-struct set-local0
  local0 s" test-struct" null 0 0 assert-struct
  s" alpha" pointer<any> local0 value-of struct-create-field set-local1
  s" beta" pointer<any> local0 value-of struct-create-field set-local2
  local0 s" test-struct" null 8 2 assert-struct
  local0 s" alpha" pointer<any> 0 cell-size assert-struct-field
  local0 s" beta" pointer<any> cell-size cell-size assert-struct-field
end

def test-struct
  test-struct-type
  test-allot-struct
  test-make-instance
  test-new-struct
  test-struct-add-field
  test-struct-create-field
end
