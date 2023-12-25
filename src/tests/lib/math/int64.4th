( " src/lib/math/32/int32.4th" load
" src/lib/math/32/int64.4th" load )
tmp" assert" defined?/2 UNLESS
  s[ src/lib/assert.4th src/lib/assertions/int.4th ] load-list
THEN

def test-int64<
  0LL 1LL int64< assert
  1LL 0LL int64< assert-not
  1LL 1LL int64< assert-not
  0LL 0LL int64< assert-not
  -10 -1 0LL int64< assert
  -10 -1 -1LL int64< assert
  -1LL -10 -1 int64< assert-not
  -10 1 0LL int64< assert-not
  10 -1 0LL int64< assert
  0xE0000000 0 0LL int64< assert-not
  0LL 0xE0000000 0 int64< assert
end

def test-int64<=
  0LL 1LL int64<= assert
  1LL 0LL int64<= assert-not
  1LL 1LL int64<= assert
  0LL 0LL int64<= assert
  -10 -1 0LL int64<= assert
  -10 -1 -1LL int64<= assert
  -1LL -10 -1 int64<= assert-not
  -10 1 0LL int64<= assert-not
  10 -1 0LL int64<= assert
  0xE0000000 0 0LL int64<= assert-not
  0LL 0xE0000000 0 int64<= assert
end

def test-uint64<
  0LL 1LL uint64< assert
  1LL 0LL uint64< assert-not
  1LL 1LL uint64< assert-not
  0LL 0LL uint64< assert-not
  -10 -1 0LL uint64< assert-not
  -10 1 0LL uint64< assert-not
  -20 -1 -1LL uint64< assert
  0xE0000000 0 0LL uint64< assert-not
  0LL 0xE0000000 0 uint64< assert
  2 1 0xA01 0 uint64< assert-not
  2 1 0xA01 1 uint64< assert
end

def test-uint64<=
  0LL 1LL uint64<= assert
  1LL 0LL uint64<= assert-not
  1LL 1LL uint64<= assert
  0LL 0LL uint64<= assert
  -10 -1 0LL uint64<= assert-not
  -10 1 0LL uint64<= assert-not
  -10 1 -10 1 uint64<= assert
  -20 -1 -1LL uint64<= assert
  -20 -1 -20 -1 uint64<= assert
  0xE0000000 0 0LL uint64<= assert-not
  0LL 0xE0000000 0 uint64<= assert
  2 1 0xA01 0 uint64<= assert-not ( fixme 0xA00 caused segfault, decompile also stopped short. )
  2 1 0xA01 1 uint64<= assert
end

def test-int64-negate
  0LL int64-negate 0LL assert-int64
  -10 -1 int64-negate 10 0 assert-int64
  10 0 int64-negate -10 -1 assert-int64
  10 20 int64-negate -10 -21 assert-int64
  10 -10 int64-negate -10 9 assert-int64
  -10 9 int64-negate 10 -10 assert-int64
end

def test-uint64-add
  0LL 0LL uint64-add 0LL assert-int64
  1LL 1LL uint64-add 2 0 assert-int64
  0 1 0 1 uint64-add 0 2 assert-int64
  -1 0 1LL uint64-add 0 1 assert-int64
  -1LL -1LL uint64-add -2 -1 assert-int64
  0x80000000 0 2dup uint64-add 0 1 assert-int64
end

def test-int64-add
  0LL 0LL int64-add 0LL assert-int64
  1LL 1LL int64-add 2 0 assert-int64
  0 1 0 1 int64-add 0 2 assert-int64
  -1LL 1LL int64-add 0LL assert-int64
  -1 0 1LL int64-add 0 1 assert-int64
  -1LL -1LL int64-add -2 -1 assert-int64
  0x80000000 0 2dup int64-add 0 1 assert-int64
  -0x80000000 -1 2dup int64-add 0 -1 assert-int64
end

def test-int64-sub
  0LL 0LL int64-sub 0LL assert-int64
  1LL 1LL int64-sub 0LL assert-int64
  0 1 0 1 int64-sub 0LL assert-int64
  -1LL 1LL int64-sub -2 -1 assert-int64
  1LL -1LL int64-sub 2 0 assert-int64
  -1 0 1LL int64-sub 0xFFFFFFFE 0 assert-int64
  -1LL -1LL int64-sub 0LL assert-int64
  0x80000000 0 2dup int64-sub 0LL assert-int64
  -0x80000000 -1 2dup int64-sub 0LL assert-int64
  0 1 0x80000000 0 int64-sub 0x80000000 0 assert-int64
end

def test-uint64-mul
  -1LL -1LL uint64-mul 1LL assert-int64
  64 0 0xE0000000 0 uint64-mul 0 0x38 assert-int64
end

def test-uint64-mulc
  -1LL -1LL uint64-mulc
  0xFFFFFFFE 0xFFFFFFFF assert-int64
  1LL assert-int64
end

def test-int64-mul
  -1 -2 1LL int64-mul -1 -2 assert-int64
  -1LL 1LL int64-mul -1LL assert-int64
  -1LL -1LL int64-mul 1LL assert-int64
  1LL -1 -2 int64-mul -1 -2 assert-int64
  1LL 1LL int64-mul 1LL assert-int64
  1 1 1 1 int64-mul 1 2 assert-int64
  64 0 0xE0000000 0 int64-mul 0 0x38 assert-int64
end

def test-int64-bsl
  0x10203040 0x05060708 0 int64-bsl 0x10203040 0x05060708 assert-int64
  0x10203040 0x05060708 8 int64-bsl 0x20304000 0x06070810 assert-int64
  0x10203040 0x05060708 32 int64-bsl 0 0x10203040 assert-int64
  0x10203040 0x05060708 48 int64-bsl 0 0x30400000 assert-int64
  0x10203040 0x05060708 64 int64-bsl 0LL assert-int64
end

def test-int64-bsr
  0x10203040 0x05060708 0 int64-bsr 0x10203040 0x05060708 assert-int64
  0x10203040 0x05060708 8 int64-bsr 0x08102030 0x00050607 assert-int64
  0x10203040 0x05060708 32 int64-bsr 0x05060708 0 assert-int64
  0x10203040 0x05060708 48 int64-bsr 0x0506 0 assert-int64
  0x10203040 0x05060708 64 int64-bsr 0LL assert-int64
end

def test-int64-absr
  0x10203040 0x05060708 0 int64-absr 0x10203040 0x05060708 assert-int64
  0x10203040 0x05060708 8 int64-absr 0x08102030 0x00050607 assert-int64
  0x10203040 0x05060708 32 int64-absr 0x05060708 0 assert-int64
  0x10203040 0x05060708 48 int64-absr 0x0506 0 assert-int64
  0x10203040 0x05060708 64 int64-absr 0LL assert-int64

  0x10203040 -0x05060708 0 int64-absr 0x10203040 -0x05060708 assert-int64
  0x10203040 -0x05060708 8 int64-absr 0xF8102030 -0x00050608 assert-int64 ( absr doesn't round towards zeros )
  0x10203040 -0x05060708 32 int64-absr -0x05060708 -1 assert-int64
  0x10203040 -0x05060708 48 int64-absr -0x0507 -1 assert-int64 ( absr doesn't round towards zeros )
  0x10203040 -0x05060708 64 int64-absr -1LL assert-int64
end

def test-uint64-divmod32
  0x1000 0x2000 4 uint64-divmod32 0 assert-equals 0x400 0x800 assert-int64
  0x1002 0x2000 4 uint64-divmod32 2 assert-equals 0x400 0x800 assert-int64
  0x1002 0x2002 4 uint64-divmod32 2 assert-equals 0x80000400 0x800 assert-int64
  0x1002 0x2002 0x1000 uint64-divmod32 2 assert-equals 0x200001 0x2 assert-int64
  0x1002 0x2345 0x1000 uint64-divmod32 2 assert-equals 0x34500001 0x2 assert-int64
  0x1002 0x2345 0xFFFFFFFF uint64-divmod32 0x3347 assert-equals 0x2345 0 assert-int64
  0xFFFFFFFF 0xFFFFFFFF 0xFFFFFFFF uint64-divmod32 0 assert-equals 0x1 0x1 assert-int64
  0x1234 0x10002345 -1 uint64-divmod32 0x10003579 assert-equals 0x10002345 0 assert-int64
  0xFFFF0000 0xFFFF -1 uint64-divmod32 0 assert-equals 0x10000 0 assert-int64
  0x80004000 0x20001000 0x90000000 uint64-divmod32 0x50004000 assert-equals 0x38e3aaab 0 assert-int64
  0x80000001 0x20000000 0xA00 uint64-divmod32 1 assert-equals 0x33400000 0x33333 assert-int64
end

def test-uint64-div32
  0x1000 0x2000 4 uint64-div32 0x400 0x800 assert-int64
  0x1002 0x2000 4 uint64-div32 0x400 0x800 assert-int64
  0x1002 0x2002 4 uint64-div32 0x80000400 0x800 assert-int64
  0x1002 0x2002 0x1000 uint64-div32 0x200001 0x2 assert-int64
end

def test-uint64-divmod
  0x1234 0x4567 0 1 uint64-divmod 0x1234 0 assert-int64 0x4567 0 assert-int64
  0x1234 0x4567 0 0x10000000 uint64-divmod 0x1234 0x4567 assert-int64 0 0 assert-int64
  1 0 0 0x4567 uint64-divmod 1 0 assert-int64 0 0 assert-int64
end

def test-uint64-div
  0x1000 0x2000 4 0 uint64-div 0x400 0x800 assert-int64
  0x1002 0x2000 4 0 uint64-div 0x400 0x800 assert-int64
  0x1002 0x2002 4 0 uint64-div 0x80000400 0x800 assert-int64
  0x1002 0x2002 0x1000 0 uint64-div 0x200001 0x2 assert-int64

  0x1234 0x4567 0 1 uint64-div 0x4567 0 assert-int64
  0x1234 0x4567 0 0x10000000 uint64-div 0 0 assert-int64
  1 0 0 0x4567 uint64-div 0 0 assert-int64
end

def test-string->uint64
  s" 1234" string->uint64/2 1234 0 assert-int64
  s" 123456789012345" string->uint64/2 0x860DDF79 0x7048 assert-int64
  s" 0" string->uint64/2 0 0 assert-int64
  s" 0xABCD" string->uint64/2 0xABCD 0 assert-int64
end

def test-string->int64
  s" 1234" string->int64/2 1234 0 assert-int64
  s" -1234" string->int64/2 -1234 -1 assert-int64
  s" 0" string->int64/2 0 0 assert-int64
  s" 123456789012345" string->int64/2 0x860DDF79 0x7048 assert-int64
  s" -123456789012345" string->int64/2 0x860DDF79 0x7048 int64-negate assert-int64
  s" 0xABCD" string->int64/2 0xABCD 0 assert-int64
  s" -0xABCD" string->int64/2 0xABCD 0 int64-negate assert-int64
end

def test-[uint64]
  uint64 123456789012345 0x860DDF79 0x7048 assert-int64
  uint64 0x1234567890 0x34567890 0x12 assert-int64
end

def test-[int64]
  int64 123456789012345 0x860DDF79 0x7048 assert-int64
  int64 -123456789012345 0x860DDF79 0x7048 int64-negate assert-int64
  int64 0x1234567890 0x34567890 0x12 assert-int64
  int64 -0x1234567890 0x34567890 0x12 int64-negate assert-int64
end

def test-int64
  test-int64<
  test-int64<=
  test-uint64<
  test-uint64<=
  test-int64-negate
  test-uint64-add
  test-int64-add
  test-int64-sub
  test-uint64-mul
  test-uint64-mulc
  test-int64-mul
  test-int64-bsl
  test-int64-bsr
  test-int64-absr
  test-uint64-divmod32
  test-uint64-div32
  test-uint64-divmod
  test-uint64-div
  test-string->uint64
  test-string->int64
  test-[uint64]
  test-[int64]
end
