def test-int32-abs
  4 abs-int 4 assert-equals
  -4 abs-int 4 assert-equals
end
  
def test-int32-div
  44 3 int-div 14 assert-equals
  -44 3 int-div -14 assert-equals
  44 -3 int-div -14 assert-equals
  -44 -3 int-div 14 assert-equals
  -10 -30 int-div 0 assert-equals
end

def test-int32-mod
  44 3 int-mod 2 assert-equals
  -44 3 int-mod 2 assert-equals
  44 -3 int-mod 2 assert-equals
  -44 -3 int-mod 2 assert-equals
  10 30 int-mod 10 assert-equals
  -10 -30 int-mod 10 assert-equals
end

def test-int32
  test-int32-abs
  test-int32-div
  test-int32-mod
end
