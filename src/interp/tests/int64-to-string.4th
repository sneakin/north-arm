require[ src/interp/output/int64.4th assert ]

 def test-uint64->string/3
  ( base 10 )
  0 0 10 uint64->string/3 s" 0" assert-byte-string-equals/4
  1 0 10 uint64->string/3 s" 1" assert-byte-string-equals/4
  -1 0 10 uint64->string/3 s" 4294967295" assert-byte-string-equals/4
  0 1 10 uint64->string/3 s" 4294967296" assert-byte-string-equals/4
  0 -1 10 uint64->string/3 s" 18446744069414584320" assert-byte-string-equals/4
  -1 -1 10 uint64->string/3 s" 18446744073709551615" assert-byte-string-equals/4

  ( base 16 )
  0 0 16 uint64->string/3 s" 0" assert-byte-string-equals/4
  1 0 16 uint64->string/3 s" 1" assert-byte-string-equals/4
  -1 0 16 uint64->string/3 s" FFFFFFFF" assert-byte-string-equals/4
  0 1 16 uint64->string/3 s" 100000000" assert-byte-string-equals/4
  0 -1 16 uint64->string/3 s" FFFFFFFF00000000" assert-byte-string-equals/4
  -1 -1 16 uint64->string/3 s" FFFFFFFFFFFFFFFF" assert-byte-string-equals/4
end

def test-int64->string/3
  ( base 10 )
  0 0 10 int64->string/3 s" 0" assert-byte-string-equals/4
  1 0 10 int64->string/3 s" 1" assert-byte-string-equals/4
  -1 0 10 int64->string/3 s" 4294967295" assert-byte-string-equals/4
  0 1 10 int64->string/3 s" 4294967296" assert-byte-string-equals/4
  0 -1 10 int64->string/3 s" -4294967296" assert-byte-string-equals/4
  -1 -1 10 int64->string/3 s" -1" assert-byte-string-equals/4
  0xFFFFFFFF 0x7FFFFFFF 10 int64->string/3 s" 9223372036854775807" assert-byte-string-equals/4
  1 0x80000000 10 int64->string/3 s" -9223372036854775807" assert-byte-string-equals/4

  ( base 16 )
  0 0 16 int64->string/3 s" 0" assert-byte-string-equals/4
  1 0 16 int64->string/3 s" 1" assert-byte-string-equals/4
  -1 0 16 int64->string/3 s" FFFFFFFF" assert-byte-string-equals/4
  0 1 16 int64->string/3 s" 100000000" assert-byte-string-equals/4
  0 -1 16 int64->string/3 s" -100000000" assert-byte-string-equals/4
  -1 -1 16 int64->string/3 s" -1" assert-byte-string-equals/4
  0xFFFFFFFF 0x7FFFFFFF 16 int64->string/3 s" 7FFFFFFFFFFFFFFF" assert-byte-string-equals/4
  1 0x80000000 16 int64->string/3 s" -7FFFFFFFFFFFFFFF" assert-byte-string-equals/4
end

def test-int64-to-string
  test-uint64->string/3
  test-int64->string/3
end
