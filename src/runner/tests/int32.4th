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
  -44 3 int-mod -2 assert-equals
  44 -3 int-mod 2 assert-equals
  -44 -3 int-mod -2 assert-equals
  10 30 int-mod 10 assert-equals
  -10 -30 int-mod -10 assert-equals
end

def assert-floored-divmod ( num den quotient remainder -- )
  debug? IF arg3 write-int space arg2 write-int nl THEN
  arg3 arg2 floored-divmod arg0 assert-equals arg1 assert-equals
  arg3 arg2 floored-div arg1 assert-equals
  arg3 arg2 floored-mod arg0 assert-equals
  4 return0-n
end

def test-int32-floored
  -1 5 -1 4 assert-floored-divmod
  1 -5 0 1 assert-floored-divmod
  11 5 2 1 assert-floored-divmod
  -11 5 -3 4 assert-floored-divmod
  11 -5 -2 1 assert-floored-divmod
  -11 -5 2 -1 assert-floored-divmod
  -5 5 -1 0 assert-floored-divmod
  5 -5 -1 0 assert-floored-divmod
end

def test-int32
  test-int32-abs
  test-int32-div
  test-int32-mod
  test-int32-floored
end
