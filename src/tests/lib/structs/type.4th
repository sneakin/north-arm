' assert defined? UNLESS
  tmp" src/lib/assert.4th" load/2
THEN
' struct defined? UNLESS
  tmp" src/lib/structs.4th" load/2
THEN
' assert-type defined? UNLESS
  tmp" src/tests/lib/structs/assert.4th" load/2
THEN

def test-null-type
  null-type s" null-type" null cell-size 0 assert-type
end

def test-type-type
  type s" type" null cell-size 4 * 4 assert-type
  ( fields )
  type s" name" pointer<any> 0 cell-size assert-struct-field
  type s" byte-size" uint<32> cell-size cell-size assert-struct-field
  type s" super" pointer<any> cell-size 2 * cell-size assert-struct-field
  type s" data" pointer<any> cell-size 3 * cell-size assert-struct-field
end

def test-make-type
  0
  type 44 make-type set-local0
  local0 s" anon-type" type 44 0 assert-type
end

type 56 type: test-type-base
test-type-base 64 type: test-type-child
test-type-child 64 type: test-type-grand-child

def test-type-macro
  test-type-base s" test-type-base" type 56 0 assert-type
  test-type-child s" test-type-child" test-type-base 64 0 assert-type
  test-type-grand-child s" test-type-grand-child" test-type-child 64 0 assert-type
end

def test-type-super-of
  null null type-super-of? assert
  null null-type type-super-of? assert
  null-type null type-super-of? assert
  null-type null-type type-super-of? assert
  test-type-base type type-super-of? assert
  test-type-child test-type-base type-super-of? assert
  test-type-child type type-super-of? assert
  test-type-grand-child test-type-child type-super-of? assert
  test-type-grand-child test-type-base type-super-of? assert
end

def test-type-kind-of
  null null kind-of? assert
  null null-type kind-of? assert
  test-type-grand-child make-instance
  dup test-type-base kind-of? assert
end

def test-type-byte-size
  0 0
  type make-instance set-local0
  local0 byte-size cell-size 4 * assert-equals
  test-type-child make-instance set-local1
  local1 byte-size 64 assert-equals
end

def test-type
  test-null-type
  test-type-type
  test-make-type
  test-type-macro
  test-type-super-of
  test-type-kind-of
  test-type-byte-size
end
