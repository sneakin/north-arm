DEFINED? assert-equals UNLESS
  tmp" src/lib/assert.4th" load/2
THEN

def test-copy-down-full
s" copy down full" write-line/2
  1 2 3 4 5 6 0x11223344 8 9 10 11 12 here dup 24 + 24 copy-down
  0 assert-equals
  6 dropn
  12 assert-equals
  11 assert-equals
  10 assert-equals
  9 assert-equals
  8 assert-equals
  0x11223344 assert-equals ( fixme partial? )
end

def test-copy-down-partial-cell
  1 2 3 4 5 6 0x11223344 8 9 10 11 12 here dup 24 + 23 copy-down
  0 assert-equals
  6 dropn
  12 assert-equals
  11 assert-equals
  10 assert-equals
  9 assert-equals
  8 assert-equals
  0x223344 assert-equals
end

def test-copy-down-misaligned
s" copy down misaligned dest" write-line/2
  0 0
  " 0123456789ABCDEF" set-local0
  16 stack-allot-zero set-local1
  local0 1 + local1 6 copy-down
  0 assert-equals
  local1 s" 123456" assert-byte-string-equals/3
end

def test-copy-down-16
s" copy down 16" write-line/2
  ( 1 2 3 4 5 6 7 8 here dup 16 + 15 copy-down-16
  15 assert-equals )
  1 2 3 4 5 6 7 8 here dup 16 + 16 copy-down
  0 assert-equals
  4 dropn
  8 assert-equals
  7 assert-equals
  6 assert-equals
  5 assert-equals
end

def test-copy-down-12
s" copy down 12" write-line/2
  ( 1 2 3 4 5 6 7 8 here dup 16 + 11 copy-down-12
  11 assert-equals )
  1 2 3 4 5 6 7 8 here dup 16 + 12 copy-down
  0 assert-equals
  4 dropn
  8 assert-equals
  7 assert-equals
  6 assert-equals
  1 assert-equals
end

def test-copy-down-8
s" copy down 8" write-line/2
  ( 1 2 3 4 5 6 7 8 here dup 16 + 7 copy-down-8
  7 assert-equals )
  1 2 3 4 5 6 7 8 here dup 16 + 8 copy-down
  0 assert-equals
  4 dropn
  8 assert-equals
  7 assert-equals
  2 assert-equals
  1 assert-equals
end

def test-copy-down-4
s" copy down 4" write-line/2
  1 2 3 4 5 6 7 8 here dup 16 + 3 copy-down-4
  0 assert-equals
  6 dropn
  4 assert-equals ( little endian! )
  3 assert-equals
  2 assert-equals
  1 assert-equals

  1 2 3 4 5 6 7 8 here 16 + dup 16 + 16 copy-down-4
  0 assert-equals
  6 dropn
  8 assert-equals
  7 assert-equals
  6 assert-equals
  5 assert-equals
end

def test-copy-down-1
s" copy down 1" write-line/2
  1 2 3 4 5 6 7 8 here 16 + dup 16 + 16 copy-down-1
  0 assert-equals
  6 dropn
  8 assert-equals
  7 assert-equals
  6 assert-equals
  5 assert-equals
end

def test-copy-down
  test-copy-down-16
  test-copy-down-12
  test-copy-down-8
  test-copy-down-4
  test-copy-down-1
  test-copy-down-full
  test-copy-down-partial-cell
  test-copy-down-misaligned
end
