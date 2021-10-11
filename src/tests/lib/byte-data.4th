s[ src/lib/byte-data.4th
   src/lib/assert.4th
] load-list

def test-byte-data-64-32
  dhere
  0x11223344 0x55667788 ,uint64
  local0 uint64@ 
  0x55667788 assert-equals
  0x11223344 assert-equals

  0xAABBCCDD 0xEEFF0011 local0 uint64!
  local0 uint64@ 
  0xEEFF0011 assert-equals
  0xAABBCCDD assert-equals
end

def test-byte-data-64-64
  dhere
  ( Bash doesn't convert 0x tokens into integers unless math
    specific operations are performed. )
  1234605616436508552 ,uint64
  local0 uint64@ 
  1234605616436508552 assert-equals

  -6144092013047381999 local0 uint64!
  local0 uint64@ 
  -6144092013047381999 assert-equals
end

def test-byte-data-64
  cell-size 4 equals?
  IF test-byte-data-64-32
  ELSE test-byte-data-64-64
  THEN
end
