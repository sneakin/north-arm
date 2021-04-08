tmp" src/lib/fun.4th" load/2
tmp" src/lib/assert.4th" load/2

def test-find-first
  0
  4 locals push-onto
  5 locals push-onto
  ' equals? 4 partial-first local0 over find-first
  dup 4 assert-equals
  ' equals? 5 partial-first local0 over find-first
  dup 5 assert-equals
  ( todo 0 and null separation )
  ' equals? 0 partial-first local0 over find-first
  dup 0 assert-equals
end

