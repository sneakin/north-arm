( load-core )
( tmp" src/lib/assert.4th" drop load )

( Float32 tests: )

def assert-float32-equals
  arg1 arg0 float32-equals? dup assert
  UNLESS
    arg1 float32->int32 write-hex-int space
    arg0 float32->int32 write-hex-int nl
  THEN
end

def assert-float32-pred ( a b r op )
  arg3 int32->float32
  arg2 int32->float32
  arg0 exec-abs
  arg1 assert-equals
end

def test-float32-equals
  3 3 1 ' float32-equals? assert-float32-pred
  3 4 0 ' float32-equals? assert-float32-pred
  3 2 0 ' float32-equals? assert-float32-pred
end

def test-float32-zero
  0 int32->float32 float32-zero? 1 assert-equals
  3 int32->float32 float32-zero? 0 assert-equals
  -3 int32->float32 float32-zero? 0 assert-equals
end

def test-float32<=>
  3 3 0 ' float32<=> assert-float32-pred
  3 4 1 ' float32<=> assert-float32-pred
  3 2 -1 ' float32<=> assert-float32-pred
end

def assert-float32-op ( a b r op )
  arg3 int32->float32
  arg2 int32->float32
  arg0 exec-abs
  arg1 int32->float32 assert-float32-equals
end

def test-float32-math
  3 3 6 ' float32-add assert-float32-op
  3 -2 1 ' float32-add assert-float32-op
  3 3 0 ' float32-sub assert-float32-op
  4 3 1 ' float32-sub assert-float32-op
  3 3 9 ' float32-mul assert-float32-op
  3 3 1 ' float32-div assert-float32-op
  6 3 2 ' float32-div assert-float32-op

  2 int32->float32 float32-negate -2 int32->float32 assert-float32-equals
  -3 int32->float32 float32-negate 3 int32->float32 assert-float32-equals

  4 int32->float32 float32-abs 4 int32->float32 assert-float32-equals
  -5 int32->float32 float32-abs 5 int32->float32 assert-float32-equals

  9 int32->float32 float32-sqrt 3 int32->float32 assert-float32-equals
end

def test-float32-conv
  -3 int32->float32 float32->int32 -3 assert-equals
  3 int32->float32 float32->int32 3 assert-equals

  -3 uint32->float32 float32->uint32 -1 assert-equals ( precision lost )
  0xFFFFFFFD uint32->float32 100 int32->float32 float32-div
  float32->uint32 0x28F5C28 assert-equals
  3 uint32->float32 float32->uint32 3 assert-equals
end

def test-float32
  test-float32-equals
  test-float32-zero
  test-float32<=>
  test-float32-math
  test-float32-conv
end

( Float64 )

def assert-float64-equals
  arg3 arg2 arg1 arg0 float64-equals? dup assert
  UNLESS
    arg3 arg2 float64->int32 write-hex-int space
    arg1 arg0 float64->int32 write-hex-int nl
  THEN
end

def assert-float64-pred ( a b r op )
  arg3 int32->float64
  arg2 int32->float64
  arg0 exec-abs
  arg1 assert-equals
end

def test-float64-equals
  3 3 1 ' float64-equals? assert-float64-pred
  3 4 0 ' float64-equals? assert-float64-pred
  3 2 0 ' float64-equals? assert-float64-pred
end

def test-float64-zero
  0 int32->float64 float64-zero? 1 assert-equals
  3 int32->float64 float64-zero? 0 assert-equals
  -3 int32->float64 float64-zero? 0 assert-equals
end

def test-float64<=>
  3 3 0 ' float64<=> assert-float64-pred
  3 4 1 ' float64<=> assert-float64-pred
  3 2 -1 ' float64<=> assert-float64-pred
end

def assert-float64-op ( a b r op )
  arg3 int32->float64
  arg2 int32->float64
  arg0 exec-abs
  arg1 int32->float64 assert-float64-equals
end

def test-float64-math
  3 3 6 ' float64-add assert-float64-op
  3 -2 1 ' float64-add assert-float64-op
  3 3 0 ' float64-sub assert-float64-op
  4 3 1 ' float64-sub assert-float64-op
  3 3 9 ' float64-mul assert-float64-op
  3 3 1 ' float64-div assert-float64-op
  6 3 2 ' float64-div assert-float64-op

  2 int32->float64 float64-negate -2 int32->float64 assert-float64-equals
  -3 int32->float64 float64-negate 3 int32->float64 assert-float64-equals

  4 int32->float64 float64-abs 4 int32->float64 assert-float64-equals
  -5 int32->float64 float64-abs 5 int32->float64 assert-float64-equals

  9 int32->float64 float64-sqrt 3 int32->float64 assert-float64-equals
end

def test-float64-conv
  -3 int32->float64 float64->int32 -3 assert-equals
  3 int32->float64 float64->int32 3 assert-equals

  0xFFFFFFFD uint32->float64 100 int32->float64 float64-div
  float64->uint32 0x28F5C28 assert-equals ( fixme rounded up? )
  -3 uint32->float64 float64->uint32 -3 assert-equals
  3 uint32->float64 float64->uint32 3 assert-equals

  3 int32->float32 float32->float64 3 int32->float64 assert-float64-equals
  3 int32->float64 float64->float32 3 int32->float32 assert-float32-equals
  0xFFFFFFFD uint32->float64 100 int32->float64 float64-div
  float64->float32 float32->uint32 0x28F5C28 assert-equals
end

def test-float64
  test-float64-equals
  test-float64-zero
  test-float64<=>
  test-float64-math
  test-float64-conv
end

def test-float32.2
  ( set vector length )
  vfpscr
  dup 2 15 bsl logior dup vfpscr!
  ( assert it changed )
  vfpscr assert-equals
  ( make our addends )
  3 int32->float32 4 int32->float32
  ( add the pair to itself )
  2dup 2dup float32-add-2
  8 int32->float32 assert-float32-equals 2 dropn
  6 int32->float32 assert-float32-equals 2 dropn
  ( add the pair 3 times )
  2dup 2dup float32-add-2 float32-add-2
  12 int32->float32 assert-float32-equals 2 dropn
  9 int32->float32 assert-float32-equals 2 dropn
  ( restore the vector length )
  local0 vfpscr!
end

def test-float
  test-float32
  test-float64
end
