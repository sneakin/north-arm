tmp" src/lib/assert.4th" load/2

def test-copy-up-full
  1 2 3 4 5 6 7 8 9 10 11 12 here dup 24 + 23 copy-up
  0 assert-equals
  6 dropn
  12 assert-equals
  11 assert-equals
  10 assert-equals
  9 assert-equals
  8 assert-equals
  7 assert-equals
end

def test-copy-up-16
  1 2 3 4 5 6 7 8 here dup 16 + 15 copy-up-16
  15 assert-equals
  1 2 3 4 5 6 7 8 here dup 16 + 16 copy-up-16
  0 assert-equals
  6 dropn
  8 assert-equals
  7 assert-equals
  6 assert-equals
  5 assert-equals
end

def test-copy-up-12
  1 2 3 4 5 6 7 8 here dup 16 + 11 copy-up-12
  11 assert-equals
  1 2 3 4 5 6 7 8 here dup 16 + 16 copy-up-12 
  4 assert-equals
  6 dropn
  8 assert-equals
  7 assert-equals
  6 assert-equals
  1 assert-equals
end

def test-copy-up-8
s" copy up 8" write-line/2
  1 2 3 4 5 6 7 8 here dup 16 + 7 copy-up-8
  7 assert-equals
  1 2 3 4 5 6 7 8 here dup 16 + 16 copy-up-8
  0 assert-equals
  6 dropn
  8 assert-equals
  7 assert-equals
  6 assert-equals
  5 assert-equals
end

def test-copy-up-4
s" copy up 4" write-line/2
  1 2 3 4 5 6 7 8 here dup 16 + 3 copy-up-4
  3 assert-equals
  1 2 3 4 5 6 7 8 here dup 16 + 16 copy-up-4
  0 assert-equals
  6 dropn
  8 assert-equals
  7 assert-equals
  6 assert-equals
  5 assert-equals
end

def test-copy-up-1
s" copy up 1" write-line/2
  1 2 3 4 5 6 7 8 here dup 16 + 0 copy-up-1
  0 assert-equals
  1 2 3 4 5 6 7 8 here dup 16 + 16 copy-up-1
  0 assert-equals
  6 dropn
  8 assert-equals
  7 assert-equals
  6 assert-equals
  5 assert-equals
end

def test-copy-up
  test-copy-up-16
  test-copy-up-12
  test-copy-up-8
  test-copy-up-4
  test-copy-up-1
  test-copy-up-full
end
