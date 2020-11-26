def test-uint32-cmp
  3 4 uint< 1 assert-equals
  3 0xFFFFFFFF uint< 1 assert-equals
  4 3 uint< 0 assert-equals
  0xFFFFFFFF 3 uint< 0 assert-equals
  0x7FFFFFFF 0x80000000 uint< 1 assert-equals

  3 3 uint<= 1 assert-equals
  3 4 uint<= 1 assert-equals
  3 0xFFFFFFFF uint<= 1 assert-equals
  4 3 uint<= 0 assert-equals
  0xFFFFFFFF 3 uint<= 0 assert-equals
  0x7FFFFFFF 0x80000000 uint<= 1 assert-equals
end

def test-uint32-div
  44 3 uint-div 14 assert-equals
  0xFFFFFFF 3 uint-div 0x5555555 assert-equals
  0xFFFFFFFF 3 uint-div 0x55555555 assert-equals
  0x80000000 0x8000 uint-div 0x10000 assert-equals
  0x80000000 2 uint-div 0x40000000 assert-equals
  0x80000000 1 uint-div 0x80000000 assert-equals
  0xFFFFFFFF 0x80000000 uint-div 1 assert-equals
  3 0xFFFFFFFF uint-div 0 assert-equals
end

def test-uint32-mod
  44 3 uint-mod 2 assert-equals
  0xFFFFFFF 3 uint-mod 0 assert-equals
  0x80000000 3 uint-mod 2 assert-equals
  0xFFFFFFFF 3 uint-mod 0 assert-equals
  0xFFFFFFFE 3 uint-mod 2 assert-equals
  0xFFFFFFFF 0x80000000 uint-mod 0x7FFFFFFF assert-equals
  3 0xFFFFFFFF uint-mod 3 assert-equals
  10 30 uint-mod 10 assert-equals
end

def test-uint32
  test-uint32-cmp
  test-uint32-div
  test-uint32-mod
end
