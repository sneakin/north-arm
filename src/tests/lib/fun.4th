DEFINED? assert UNLESS
  tmp" src/lib/assert.4th" load/2
THEN

DEFINED? partial-first UNLESS
  tmp" src/lib/fun.4th" load/2
THEN

def test-partial-first
  0 0
  ( arithmetic )
  ' * 3 partial-first set-local0
  2 3 local0 exec-abs
  9 assert-equals
  2 assert-equals
  ( strings with length )
  ' string-equals?/3 3 partial-first " hey" partial-first set-local1
  2 " what" local1 exec-abs
  false assert-equals
  3 dropn
  2 assert-equals
  2 " hey" local1 exec-abs
  1 assert-equals
  3 dropn
  2 assert-equals
end

def test-partial-first-n
  ' int-add 0 partial-first-n 200 100 3 overn exec-abs 300 assert-equals
  ' int-add 10 1 partial-first-n 100 over exec-abs 110 assert-equals
  ' int-add 10 20 2 partial-first-n dup exec-abs 30 assert-equals
  ' int-add 10 20 30 3 partial-first-n dup exec-abs 50 assert-equals 10 assert-equals
  ' int-add 10 20 30 40 4 partial-first-n dup exec-abs 70 assert-equals 20 assert-equals
end

def test-partial-after
  0 0
  ( arithmetic )
  ' - 3 1 partial-after set-local0
  2 -6 local0 exec-abs
  9 assert-equals
  2 assert-equals
  ( third argument )
  ' string-equals?/3 " hey" 2 partial-after set-local1
  s" hello" local1 exec-abs
  false assert-equals
  s" hey" local1 exec-abs
  1 assert-equals
end

def test-compose
  0 0
  ( arithmetic )
  ' + ' negate compose set-local0
  2 3 4 local0 exec-abs
  -7 assert-equals
  2 assert-equals
  ( multiple composes )
  ' swap ' drop compose ' negate compose set-local1
  2 3 4 local1 exec-abs
  -4 assert-equals
  2 assert-equals
end

def test-fun
  test-partial-first
  test-partial-first-n
  test-partial-after
  test-compose
end
