s[ src/lib/math.4th
   src/lib/sort/merge-sort.4th
   src/lib/assert.4th
] load-list

def test-merge-lists
  0 0 0
  0 10 cons 6 cons 2 cons set-local0
  0 20 cons 12 cons 3 cons set-local1
  local0 local1 ' int<=> 0 3 0 merge-lists set-local2
  local2 ' write-int-sp map-car
  nl

  0 10 cons 4 cons set-local0
  0 20 cons 12 cons set-local1
  local0 local1 ' int<=> 0 2 0 merge-lists set-local2
  local2 ' write-int-sp map-car
  nl

  0 4 cons 10 cons set-local0
  0 12 cons 20 cons set-local1
  local0 local1 ' int<=> 0 2 0 merge-lists set-local2
  local2 ' write-int-sp map-car
  nl

  0 10 cons set-local0
  0 20 cons set-local1
  local0 local1 ' int<=> 0 1 0 merge-lists set-local2
  local2 ' write-int-sp map-car
  nl

  0 10 cons 100 cons 6 cons set-local0
  0 2 cons 12 cons 3 cons set-local1
  local0 local1 ' int<=> 0 3 0 merge-lists set-local2
  local2 ' write-int-sp map-car
  nl
end

def sq-int< arg1 arg1 int-mul arg0 arg0 int-mul int< 2 return1-n end

def test-merge-sort
  0 0 0
  ( single )
  0 11 cons set-local0
  ' int< local0 1 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 1 assert-equals

  ( sorted pair )
  0 11 cons 4 cons set-local0
  ' int< local0 2 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 2 assert-equals

  ( unsorted pair )
  0 4 cons 44 cons set-local0
  ' int< local0 2 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 2 assert-equals

  ( triple )
  local0 -10 cons set-local0
  ' int< local0 3 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 3 assert-equals

  ( build a progressively larger list: )
  0 11 cons 4 cons 10 cons 5 cons set-local0
  ' int< local0 4 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 4 assert-equals

  local0 11 cons 4 cons 100 cons -10 cons set-local0
  ' int< local0 8 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 8 assert-equals

  local0 14 cons 42 cons 100 cons -20 cons -16 cons set-local0
  ' int< local0 13 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 13 assert-equals

  local0 16 cons set-local0
  ' int< local0 14 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 14 assert-equals

  local0 19 cons set-local0
  ' int< local0 15 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 15 assert-equals

  ' int> local0 15 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 15 assert-equals

  ( resort )
  ' int> local1 15 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 15 assert-equals

  ( resort )
  ' int< local1 15 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 15 assert-equals

  ( resort )
  ' sq-int< local1 15 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 15 assert-equals

  ( strings )
  0 " hello" cons " world." cons " how" cons " are" cons " you?" cons set-local0
  ' byte-string< local0 5 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-line map-car nl
  local1 cons-count 5 assert-equals

  ' byte-string> local0 5 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-line map-car nl

  0 " hello" cons " world." cons " how" cons " are" cons " you?" cons " hello?" cons set-local0
  ' byte-string< local0 6 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-line map-car nl
  local1 cons-count 6 assert-equals

  ' byte-string> local0 6 0 merge-sort set-local1
  s" Sorted: " write-string/2
  local1 ' write-line map-car nl
end
