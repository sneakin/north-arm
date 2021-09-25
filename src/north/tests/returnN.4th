load-core
s[ src/lib/assert.4th
   src/north/words.4th
] load-list

def test-returnN-fun0 1 2 4 0 returnN end
def test-returnN-fun1 1 2 4 1 returnN end
def test-returnN-fun3 1 2 4 3 returnN end

def test-returnN
  11 22 test-returnN-fun0
  22 assert-equals
  11 assert-equals

  11 22 test-returnN-fun1
  4 assert-equals
  22 assert-equals
  11 assert-equals

  11 22 test-returnN-fun3
  4 assert-equals
  2 assert-equals
  1 assert-equals
  22 assert-equals
  11 assert-equals
end
