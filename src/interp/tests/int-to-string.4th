tmp" src/lib/assert.4th" load/2

def assert-int->string ( n expecting expecting-length )
  arg2 int->string
  arg0 assert-equals
  arg1 arg0 assert-byte-string-equals/3
  3 return0-n
end

def assert-uint->string-6 ( n radix digits padding expecting length )
  0 0
  arg3 1 + stack-allot set-local0
  5 argn local0 arg3 4 argn arg3 arg2 uint->string/6 local0 assert-equals
  local0 arg1 arg0 assert-byte-string-equals/3
end

def test-uint->byte-seq/5
  0 64 stack-allot-zero set-local0
  local0 4 12345678 10 0 uint->byte-seq/5
  1234 assert-equals
  s" 5678" assert-byte-string-equals/4

  local0 4 0x12345678 16 0 uint->byte-seq/5
  0x1234 assert-equals
  s" 5678" assert-byte-string-equals/4

  local0 8 0x12345678 2 0 uint->byte-seq/5
  0x123456 assert-equals
  s" 01111000" assert-byte-string-equals/4
end

def test-uint->string/6
  256 3 12 48 s" 000000100111" assert-uint->string-6
  256 3 8 0 s" 100111" assert-uint->string-6
  256 3 8 32 s"   100111" assert-uint->string-6
  ( max int aka -1 )
  -1 16 32 0 s" FFFFFFFF" assert-uint->string-6
  -1 16 16 48 s" 00000000FFFFFFFF" assert-uint->string-6
  -1 2 32 0 s" 11111111111111111111111111111111" assert-uint->string-6
  ( past max, padded )
  -1 2 40 48 s" 0000000011111111111111111111111111111111" assert-uint->string-6
  -1 16 64 48 s" 00000000000000000000000000000000000000000000000000000000FFFFFFFF" assert-uint->string-6
  ( past max, no padding )
  -1 16 64 0 s" FFFFFFFF" assert-uint->string-6
  0 16 64 0 s" 0" assert-uint->string-6
end

def test-int->string-16
  output-base peek
  16 output-base poke
  int32 0x12345 s" 12345" assert-int->string
  int32 0xABCDEF s" ABCDEF" assert-int->string
  int32 0x0 s" 0" assert-int->string
  int32 -0x12345 s" -12345" assert-int->string
  int32 0x1 s" 1" assert-int->string
  int32 0x12 s" 12" assert-int->string
  int32 -0x1 s" -1" assert-int->string
  int32 -0x12 s" -12" assert-int->string
  int32 -0x1FEEDDCC s" -1FEEDDCC" assert-int->string
  int32 0xFFEEDDCC s" -112234" assert-int->string
  local0 output-base poke
end

def test-int->string-10
  output-base peek
  10 output-base poke
  int32 12345 s" 12345" assert-int->string
  int32 0 s" 0" assert-int->string
  int32 -12345 s" -12345" assert-int->string
  int32 1 s" 1" assert-int->string
  int32 12 s" 12" assert-int->string
  int32 -1 s" -1" assert-int->string
  int32 -12 s" -12" assert-int->string
  int32 -0x1FEEDDCC s" -535748044" assert-int->string
  int32 0xFFEEDDCC s" -1122868" assert-int->string
  local0 output-base poke
end

def test-int->string-3
  output-base peek
  3 output-base poke
  int32 0x12345 s" 10210021200" assert-int->string
  int32 0xABCDEF s" 210012000221220" assert-int->string
  int32 0x0 s" 0" assert-int->string
  int32 -0x12345 s" -10210021200" assert-int->string
  int32 0x1 s" 1" assert-int->string
  int32 0x12 s" 200" assert-int->string
  int32 -0x1 s" -1" assert-int->string
  int32 -0x12 s" -200" assert-int->string
  int32 -0x1FEEDDCC s" -1101100002211011011" assert-int->string
  int32 0xFFEEDDCC s" -2010001021201" assert-int->string
  local0 output-base poke
end

def test-int->string-61
  output-base peek
  61 output-base poke
  int32 0x12345 s" K2N" assert-int->string
  int32 0xABCDEF s" nasu" assert-int->string
  int32 0x0 s" 0" assert-int->string
  int32 -0x12345 s" -K2N" assert-int->string
  int32 0x1 s" 1" assert-int->string
  int32 0x12 s" I" assert-int->string
  int32 -0x1 s" -1" assert-int->string
  int32 -0x12 s" -I" assert-int->string
  int32 -0x1FEEDDCC s" -cgJZo" assert-int->string
  int32 0xFFEEDDCC s" -4vkf" assert-int->string
  local0 output-base poke
end

def test-int->string
  test-uint->byte-seq/5
  test-uint->string/6
  test-int->string-16
  test-int->string-10
  test-int->string-3
  test-int->string-61
end
