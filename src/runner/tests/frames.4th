DEFINED? assert UNLESS
  s" src/lib/assert.4th" load/2
THEN

def test-return0-fn
  1000 return0
end

def test-return0
  10 test-return0-fn 10 assert-equals
end

def test-return1-fn
  1000 return1
end

def test-return1
  10 test-return1-fn 1000 assert-equals 10 assert-equals
end

def test-return2-fn
  1000 2000 return2
end

def test-return2
  10 test-return2-fn 2000 assert-equals 1000 assert-equals 10 assert-equals
end

def test-return3-fn
  1000 2000 3000 return3
end

def test-return3
  10 test-return3-fn 3000 assert-equals 2000 assert-equals 1000 assert-equals 10 assert-equals
end

def test-return4-fn
  1000 2000 3000 4000 return4
end

def test-return4
  10 test-return4-fn 4000 assert-equals 3000 assert-equals 2000 assert-equals 1000 assert-equals 10 assert-equals
end

def test-return1-1-fn
  arg0 arg0 * return1-1
end

def test-return1-1
  10 test-return1-1-fn 100 assert-equals
end

def test-return0-n-fn
  1000 arg0 return0-n
end

def test-return0-n
  0 1 2 3 10 0 test-return0-n-fn 0 assert-equals
  0 1 2 3 10 1 test-return0-n-fn 10 assert-equals
  0 1 2 3 10 2 test-return0-n-fn 3 assert-equals
  0 1 2 3 10 3 test-return0-n-fn 2 assert-equals
  0 1 2 3 10 4 test-return0-n-fn 1 assert-equals
end

def test-return1-n-fn
  arg1 arg1 * arg0 return1-n
end

def test-return1-n
  0 1 2 3 10 0 test-return1-n-fn 100 assert-equals 0 assert-equals
  0 1 2 3 10 1 test-return1-n-fn 100 assert-equals 10 assert-equals
  0 1 2 3 10 2 test-return1-n-fn 100 assert-equals 3 assert-equals
  0 1 2 3 10 3 test-return1-n-fn 100 assert-equals 2 assert-equals
  0 1 2 3 10 4 test-return1-n-fn 100 assert-equals 1 assert-equals
  0 1 2 3 10 5 test-return1-n-fn 100 assert-equals 0 assert-equals
end

def test-return2-n-fn
  arg1 arg1 * dup arg1 * arg0 return2-n
end

def test-return2-n
  0 1 2 3 10 0 test-return2-n-fn 1000 assert-equals 100 assert-equals 0 assert-equals
  0 1 2 3 10 1 test-return2-n-fn 1000 assert-equals 100 assert-equals 10 assert-equals
  0 1 2 3 10 2 test-return2-n-fn 1000 assert-equals 100 assert-equals 3 assert-equals
  0 1 2 3 10 3 test-return2-n-fn 1000 assert-equals 100 assert-equals 2 assert-equals
  0 1 2 3 10 4 test-return2-n-fn 1000 assert-equals 100 assert-equals 1 assert-equals
  0 1 2 3 10 5 test-return2-n-fn 1000 assert-equals 100 assert-equals 0 assert-equals
end

def test-frames
  test-return0
  test-return1
  test-return2
  test-return3
  test-return4
s" 1-1" error-line/2
  test-return1-1
s" 0-n" error-line/2
  test-return0-n
s" 1-n" error-line/2
  test-return1-n
s" 1-n" error-line/2
  test-return2-n
end
