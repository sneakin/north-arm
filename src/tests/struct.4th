s[ src/lib/assert.4th ] load-list

struct: TestStruct
pointer<any> field: name
int<32> field: age

def test-struct
  TestStruct sizeof cell-size 4 + assert-equals
  TestStruct make-instance
  dup type-of TestStruct assert-equals
  dup TestStruct -> name @ 0 assert-equals
  dup TestStruct -> age @ 0 assert-equals
end
