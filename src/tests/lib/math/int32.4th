s[ src/lib/math/int32.4th
   src/lib/assert.4th
] load-list

def test-exp-int32
  -1 exp-int32 0 assert-equals
  0 exp-int32 1 assert-equals
  1 exp-int32 2 assert-equals
  2 exp-int32 7 assert-equals
  3 exp-int32 20 assert-equals
  4 exp-int32 54 assert-equals
  9 exp-int32 8193 assert-equals
  10 exp-int32 59874 assert-equals
end
