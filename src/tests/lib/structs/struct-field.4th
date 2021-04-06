tmp" src/lib/assert.4th" load/2
tmp" src/lib/structs.4th" load/2
tmp" src/tests/lib/structs/assert.4th" load/2

def test-struct-field-type
  struct-field s" struct-field" null cell-size 4 * 4 assert-type
  ( fields )
  struct-field s" name" pointer<any> 0 cell-size assert-struct-field
  struct-field s" type" pointer<any> cell-size cell-size assert-struct-field
  struct-field s" offset" value cell-size 2 * cell-size assert-struct-field
  struct-field s" byte-size" value cell-size 3 * cell-size assert-struct-field
end

def test-struct-field-instance
  0 struct-field make-instance set-local0
  local0 value-of struct-field-name peek null assert-equals
  local0 value-of struct-field-type peek null assert-equals
  local0 value-of struct-field-offset peek 0 assert-equals
  local0 value-of struct-field-byte-size peek 0 assert-equals
end

def test-struct-get-field
  0
  s" offset" struct-field value-of struct-get-field set-local0
  local0 assert
  local0 value-of struct-field-name peek s" offset" assert-byte-string-equals/3
  ( field from a base type )
  s" data" struct value-of struct-get-field set-local0
  local0 assert
  local0 value-of struct-field-name peek s" data" assert-byte-string-equals/3
end

def test-struct-field-dot
  0
  struct-field make-instance set-local0
  local0 value-of struct-field . name local0 value-of assert-equals
  local0 value-of struct-field . offset local0 value-of cell-size 2 * + assert-equals
  ( super fields )
  struct make-instance set-local0
  local0 value-of struct . data local0 value-of cell-size 3 * + assert-equals
end

def test-struct-field-arrow
  0
  struct-field make-instance set-local0
  local0 struct-field -> name local0 value-of assert-equals
  local0 struct-field -> offset local0 value-of cell-size 2 * + assert-equals
  ( super fields )
  struct make-instance set-local0
  local0 struct -> data local0 value-of cell-size 3 * + assert-equals
end

def test-struct-field
  test-struct-field-type
  test-struct-field-instance
  test-struct-get-field
  test-struct-field-dot
  test-struct-field-arrow
end
