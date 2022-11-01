' alias defined? [UNLESS] load-core [THEN]
' assert-equals defined? [UNLESS] " src/lib/assert.4th" load [THEN]
' patch-ldr-pc! defined? [UNLESS] load-thumb-asm [THEN]

def test-patch-ldr-pc-2
  dhere 0 dpush
  local0 r3 patch-ldr-pc!/2
  local0 @ 0x4B00 assert-equals
  local0 2 + r3 patch-ldr-pc!/2
  local0 @ 0x4B004B00 assert-equals
end

def test-patch-ldr-pc
  dhere 0 dpush
  ( 0 offset )
  local0 0 r3 patch-ldr-pc!
  local0 @ 0x4B00 assert-equals
  local0 2 + 0 r3 patch-ldr-pc!
  local0 @ 0x4B004B00 assert-equals
  ( +4 offset )
  0 local0 !
  local0 4 r3 patch-ldr-pc!
  local0 @ 0x4B01 assert-equals
  local0 2 + 4 r3 patch-ldr-pc!
  local0 @ 0x4B014B01 assert-equals
end

def patch-ldr-pc-test-block
  dhere

  dhere 0 ,ins
  dhere 0 ,ins
  dhere 0 ,ins
  dhere 0 ,ins

  0 r3 patch-ldr-pc!
  0 r3 patch-ldr-pc!
  0 r3 patch-ldr-pc!
  0 r3 patch-ldr-pc!

  0 ,uint32

  return1
end

def test-patch-ldr-pc-by-assert
  dhere
  patch-ldr-pc-test-block
  local0 assert-equals
  local0 @ 0x4B014B01 assert-equals
  local0 4 + @ 0x4B004B00 assert-equals
  dmove
end

def test-patch-ldr-pc-by-binary-dump
  dhere
  patch-ldr-pc-test-block ddump-binary-bytes
  dmove
end

def test-patch-ldr-pc-by-memdump
  dhere
  patch-ldr-pc-test-block
  dhere local0 - memdump
  dmove
end

def test-v1
  test-patch-ldr-pc-2
  test-patch-ldr-pc
  test-patch-ldr-pc-by-assert
end
