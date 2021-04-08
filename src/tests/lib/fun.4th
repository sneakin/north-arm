tmp" src/lib/assert.4th" load/2

def test-rolln
  ( typical )
  1 2 3 4 5 0x33 3 rolln
  5 assert-equals
  4 assert-equals
  3 assert-equals
  0x33 assert-equals
  2 assert-equals
  1 assert-equals
  ( zero )
  1 2 3 4 5 0x33 0 rolln
  0x33 assert-equals
  5 assert-equals
  4 assert-equals
  3 assert-equals
  2 assert-equals
  1 assert-equals
  ( one )
  1 2 3 4 5 0x33 1 rolln
  5 assert-equals
  0x33 assert-equals
  4 assert-equals
  3 assert-equals
  2 assert-equals
  1 assert-equals
end

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
