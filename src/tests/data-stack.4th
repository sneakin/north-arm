s[ src/lib/assert.4th ] load-list

def test-dpush-byte
  dhere
  0x45 dpush-byte 0x55 dpush-byte 0x65 dpush-byte 0x75 dpush-byte
  dhere local0 4 + assert-equals
  data-cell-size 4 equals? IF
    local0 dpeek 0x75655545 assert-equals
  ELSE
    local0 dpeek 0x45 assert-equals
    local0 1 + dpeek 0x55 assert-equals
    local0 2 + dpeek 0x65 assert-equals
    local0 3 + dpeek 0x75 assert-equals
  THEN local0 dmove dhere local0 assert-equals
end

def test-dpop-byte
  dhere
  45 dpush-byte 55 dpush-byte 65 dpush-byte 75 dpush-byte
  dhere local0 4 + assert-equals
  dpop-byte 75 assert-equals
  dpop-byte 65 assert-equals
  dpop-byte 55 assert-equals
  dpop-byte 45 assert-equals
  local0 dhere assert-equals
end

def test-dpeek-byte
  dhere
  45 dpush-byte 55 dpush-byte 65 dpush-byte 75 dpush-byte
  local0 3 + dpeek-byte 75 assert-equals
  local0 2 + dpeek-byte 65 assert-equals
  local0 1 + dpeek-byte 55 assert-equals
  local0 0 + dpeek-byte 45 assert-equals
  local0 dmove dhere local0 assert-equals
end

def test-dpush
  dhere
  45 dpush 55 dpush 65 dpush 75 dpush
  dhere local0 data-cell-size 4 * + assert-equals
  local0 dpeek 45 assert-equals
  local0 data-cell-size + dpeek 55 assert-equals
  local0 data-cell-size 2 * + dpeek 65 assert-equals
  local0 data-cell-size 3 * + dpeek 75 assert-equals
  local0 dmove dhere local0 assert-equals
end

def test-dpop
  dhere
  45 dpush 55 dpush 65 dpush 75 dpush
  dhere local0 data-cell-size 4 * + assert-equals
  dpop 75 assert-equals
  dpop 65 assert-equals
  dpop 55 assert-equals
  dpop 45 assert-equals
  local0 dhere assert-equals
end

def test-dpeek
  dhere
  45 dpush 55 dpush 65 dpush 75 dpush
  local0 data-cell-size 3 * + dpeek-byte 75 assert-equals
  local0 data-cell-size 2 * + dpeek-byte 65 assert-equals
  local0 data-cell-size 1 * + dpeek-byte 55 assert-equals
  local0 data-cell-size 0 * + dpeek-byte 45 assert-equals
  local0 dmove dhere local0 assert-equals
end

def test-dpoke-off
  dhere
  45 dpush 55 dpush 65 dpush 75 dpush
  123 local0 data-cell-size 2 * dpoke-off
  local0 data-cell-size 2 * + dpeek 123 assert-equals
  local0 dmove dhere local0 assert-equals
end

def test-dpeek-off
  dhere
  45 dpush 55 dpush 65 dpush 75 dpush
  local0 data-cell-size 3 * dpeek-off 75 assert-equals
  local0 data-cell-size 2 * dpeek-off 65 assert-equals
  local0 data-cell-size dpeek-off 55 assert-equals
  local0 0 dpeek-off 45 assert-equals
  local0 dmove dhere local0 assert-equals
end

def test-data-stack
  test-dpush-byte
  test-dpop-byte
  test-dpeek-byte
  test-dpush
  test-dpop
  test-dpeek
  test-dpoke-off
  test-dpeek-off
end
