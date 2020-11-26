(
load-core
" src/lib/assert.4th" load
" src/runner/tests/int32.4th" load
" src/runner/tests/uint32.4th" load
)

def test-bsl-to-match
  13 4 bsl-to-match
  2 assert-equals
  16 assert-equals

  0x12345 5 bsl-to-match
  14 assert-equals
  0x14000 assert-equals

  ( with the unsigned MSB set: )
  0x80000000 0x100 bsl-to-match
  23 assert-equals
  0x80000000 assert-equals

  0x80000000 2 bsl-to-match
  30 assert-equals
  0x80000000 assert-equals

  0x80000000 1 bsl-to-match
  31 assert-equals
  0x80000000 assert-equals

  ( zeroes: )
  0x80000000 0 bsl-to-match
  32 assert-equals
  0 assert-equals

  0 0x80 bsl-to-match
  0 assert-equals
  0x80 assert-equals ( fixme? value of 1 makes more sense? )
end

def test-math-common
  test-int32
  test-uint32
  test-float
end

def test-math-hard
  arm-hard-divmod
  test-math-common
  arm-soft-divmod
end

def test-math-soft
  arm-soft-divmod
  test-math-common
end

def test-math
  test-bsl-to-match
  test-math-soft
  test-math-hard
end
