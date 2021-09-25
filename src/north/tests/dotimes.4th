load-core
s[ src/lib/assert.4th
   src/north/words.4th
] load-list

def test-dotimes
  11 22 5 DOTIMES[ hello arg0 ]DOTIMES
  4 assert-equals
  3 assert-equals
  2 assert-equals
  1 assert-equals
  0 assert-equals
  5 assert-equals ( todo drop the loop counters? )
  5 assert-equals
  22 assert-equals
  11 assert-equals
end
