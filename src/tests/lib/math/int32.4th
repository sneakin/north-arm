s[ src/lib/math/int32.4th
   src/lib/math/int64.4th
] load-list

tmp" assert" defined?/2 [UNLESS]
  s[ src/lib/assert.4th src/lib/assertions/int.4th ] load-list
[THEN]

def test-uint-add3
  0 0 0 uint-add3 0LL assert-int64
  1 0 1 uint-add3 2 0 assert-int64
  1 1 1  uint-add3 3 0 assert-int64
  1 -1 1 uint-add3 1 1 assert-int64
  1 -1 -1 uint-add3 -1 1 assert-int64
  -1 -1 -1 uint-add3 -3 2 assert-int64
  0x7FFFFFFF dup dup uint-add3 0x7FFFFFFD 1 assert-int64
  0 0x7FFFFFFF 0x10 uint-add3 0x8000000F 0 assert-int64
  2 0x7FFFFFFF dup uint-add3 0 1 assert-int64
end

def test-uint-addc
  0 0 uint-addc 0LL assert-int64
  1 1 uint-addc 2 0 assert-int64
  -1 1 uint-addc 0 1 assert-int64
  -1 -1 uint-addc -2 1 assert-int64
  0x7FFFFFFF 0x10 uint-addc 0x8000000F 0 assert-int64
  0x7FFFFFFF dup uint-addc 0xFFFFFFFE 0 assert-int64
  0x80000000 dup uint-addc 0 1 assert-int64
end

def test-int-add3
  0 0 0 int-add3 0 0 assert-int64
  1 0 1 int-add3 2 0 assert-int64
  1 1 1 int-add3 3 0 assert-int64
  1 -1 1 int-add3 1LL assert-int64
  1 -1 -1 int-add3 -1LL assert-int64
  1 -1 -2 int-add3 -2 -1 assert-int64
  -1 -1 -1 int-add3 -3 -1 assert-int64 ( here: 0 hi )
  0 0 -1 int-add3 -1LL assert-int64
  0 -1 0 int-add3 -1LL assert-int64
  -1 0 0 int-add3 -1LL assert-int64 ( here: 0 hi )
  0x7FFFFFFF dup dup int-add3 0x7FFFFFFD 1 assert-int64
  -0x7FFFFFFF dup dup int-add3 -0x7FFFFFFD -2 assert-int64
  0 0x7FFFFFFF 0x10 int-add3 0x8000000F 0 assert-int64
  0 -0x7FFFFFFF -0x10 int-add3 -0x8000000F -1 assert-int64
  2 0x7FFFFFFF dup int-add3 0 1 assert-int64
  -2 -0x7FFFFFFF dup int-add3 0 -1 assert-int64 ( here: 0 hi )
end

def test-int-addc
  0 0 int-addc 0LL assert-int64
  1 1 int-addc 2 0 assert-int64
  -1 1 int-addc 0LL assert-int64
  -1 -1 int-addc -2 -1 assert-int64
  0x7FFFFFFF 0x10 int-addc 0x8000000F 0 assert-int64
  -0x7FFFFFFF -0x10 int-addc -0x8000000F -1 assert-int64
  -0x7FFFFFFF dup int-addc -0xFFFFFFFE -1 assert-int64
  0x7FFFFFFF dup int-addc 0xFFFFFFFE 0 assert-int64
  -0x80000000 dup int-addc 0 -1 assert-int64
end

def test-uint-mulc
  0 0 uint-mulc 0LL assert-int64
  -1 -1 uint-mulc 1 0xFFFFFFFE assert-int64
  0x1234 0x100000 uint-mulc 0x23400000 0x1 assert-int64
  0x100000 0x1234 uint-mulc 0x23400000 0x1 assert-int64
  0xFFFF 0xFFFF uint-mulc 0xFFFE0001 0 assert-int64
  0xFFFFFFFF 0xFFFF uint-mulc 0xFFFF0001 0xFFFE assert-int64
  0xFFFF 0xFFFFFFFF uint-mulc 0xFFFF0001 0xFFFE assert-int64
  0xFFFFFFFF 0xFFFF0000 uint-mulc 0x00010000 0xFFFFEFFFF assert-int64
  0x7FFFFFFF 3 uint-mulc 0x7FFFFFFD 1 assert-int64
  0x80000001 3 uint-mulc 0x80000003 1 assert-int64
end

def test-int-mulc
  0 0 int-mulc 0LL assert-int64
  -1 -1 int-mulc 1LL assert-int64
  1 -1 int-mulc -1LL assert-int64
  -1 1 int-mulc -1LL assert-int64
  0x1234 0x100000 int-mulc 0x23400000 0x1 assert-int64
  0x100000 0x1234 int-mulc 0x23400000 0x1 assert-int64
  0xFFFF 0xFFFF int-mulc 0xFFFE0001 0 assert-int64
  0x0FFFFFFF 0xFFFF int-mulc 0xEFFF0001 0x0FFF assert-int64
  0xFFFF 0x0FFFFFFF int-mulc 0xEFFF0001 0x0FFF assert-int64
  0x0FFFFFFF 0x0FFF0000 int-mulc 0xF0010000 0xffefff assert-int64
  -1 -65536 int-mulc 65536 0 assert-int64
  -65536 -1 int-mulc 65536 0 assert-int64
  65536 -1 int-mulc -65536 -1 assert-int64
  0x7FFFFFFF 3 int-mulc 0x7FFFFFFD 1 assert-int64
  -0x7FFFFFFF 3 int-mulc -0x7FFFFFFD -2 assert-int64
end

def test-exp-int32
  -1 exp-int32 0 assert-equals
  0 exp-int32 1 assert-equals
  1 exp-int32 2 assert-equals
  2 exp-int32 7 assert-equals
  3 exp-int32 20 assert-equals
  4 exp-int32 54 assert-equals
  9 exp-int32 8193 assert-equals
  10 exp-int32 59874 assert-equals
end

def test-int32
  test-uint-add3
  test-int-add3
  test-uint-addc
  test-int-addc
  test-uint-mulc
  test-int-mulc
  test-exp-int32
end
