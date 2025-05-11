DEFINED? ,uint32 UNLESS
  require[ src/lib/byte-data.4th ]
THEN
DEFINED? assert UNLESS
	require[ src/lib/assert.4th ]
THEN

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

def test-,seq
  dhere 0

  0 10 20 30 40 here 4 ,seq
  40 assert-equals
  local0 40 30 20 10 4 assert-data
  dhere local0 cell-size 4 * + assert-equals

  dhere set-local1
  100 here 0 ,seq
  dhere local1 assert-equals

  dhere set-local1
  100 200 here 1 ,seq
  200 assert-equals
  local1 200 1 assert-data
  dhere local1 cell-size + assert-equals
end

def test-,byte-string
	dhere 0

  0 " hello" ,byte-string
  0 assert-equals
  local0 s" hello" assert-byte-string-equals/3
  local0 5 assert-string-null-terminated
  dhere local0 6 + assert-equals

  dhere set-local1  
  0 " " ,byte-string
  0 assert-equals
  local1 s" " assert-byte-string-equals/3
  local1 0 assert-string-null-terminated
  dhere local1 1 + assert-equals
end

def test-byte-data
  test-byte-data-64
  test-,byte-string
  test-,seq
end
