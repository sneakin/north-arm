tmp" src/lib/assert.4th" load/2

def test-write-uint-16
  output-base peek
  16 output-base poke
  int32 0x12345 write-uint nl
  int32 0x1 write-uint nl
  int32 0x0 write-uint nl
  int32 0x1000 write-uint nl
  int32 0x1010 write-uint nl
  int32 0x1FEEDDCC write-uint nl
  int32 0xFFEEDDCC write-uint nl
  int32 -0x12 write-uint nl
  local0 output-base poke
end

def test-write-int-16
  output-base peek
  16 output-base poke
  int32 0x12345 write-int nl
  int32 0x1 write-int nl
  int32 0x0 write-int nl
  int32 0x1000 write-int nl
  int32 0x1010 write-int nl
  int32 0x1FEEDDCC write-int nl
  int32 0xFFEEDDCC write-int nl
  int32 -0x12 write-int nl
  local0 output-base poke
end

def test-write-int-2
  output-base peek
  2 output-base poke
  int32 0x12345 write-int nl
  int32 0x1 write-int nl
  int32 0x0 write-int nl
  int32 0x1000 write-int nl
  int32 0x1010 write-int nl
  int32 0x1FEEDDCC write-int nl
  int32 0xFFEEDDCC write-int nl
  int32 -0x12 write-int nl
  local0 output-base poke
end

def test-write-int
  test-write-uint-16
  test-write-int-16
  test-write-int-2
end
