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
  local0 local1 ' int<=> 0 2 1 merge-lists set-local2
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

def test-merge-sort-list
  0 0 0
  ( single )
  0 11 cons set-local0
  ' int< local0 1 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 1 assert-equals

  ( sorted pair )
  0 11 cons 4 cons set-local0
  ' int< local0 2 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 2 assert-equals

  ( unsorted pair )
  0 4 cons 44 cons set-local0
  ' int< local0 2 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 2 assert-equals

  ( triple )
  local0 -10 cons set-local0
  ' int< local0 3 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 3 assert-equals

  ( build a progressively larger list: )
  0 11 cons 4 cons 10 cons 5 cons set-local0
  ' int< local0 4 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 4 assert-equals

  local0 11 cons 4 cons 100 cons -10 cons set-local0
  ' int< local0 8 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 8 assert-equals

  local0 14 cons 42 cons 100 cons -20 cons -16 cons set-local0
  ' int< local0 13 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 13 assert-equals

  local0 16 cons set-local0
  ' int< local0 14 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 14 assert-equals

  local0 19 cons set-local0
  ' int< local0 15 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 15 assert-equals

  ' int> local0 15 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 15 assert-equals

  ( resort )
  ' int> local1 15 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 15 assert-equals

  ( resort )
  ' int< local1 15 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 15 assert-equals

  ( resort )
  ' sq-int< local1 15 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-int-sp map-car nl
  local1 cons-count 15 assert-equals

  ( strings )
  0 " hello" cons " world." cons " how" cons " are" cons " you?" cons set-local0
  ' byte-string< local0 5 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-line map-car nl
  local1 cons-count 5 assert-equals

  ' byte-string> local0 5 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-line map-car nl

  0 " hello" cons " world." cons " how" cons " are" cons " you?" cons " hello?" cons set-local0
  ' byte-string< local0 6 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-line map-car nl
  local1 cons-count 6 assert-equals

  ' byte-string> local0 6 0 merge-sort-list set-local1
  s" Sorted: " write-string/2
  local1 ' write-line map-car nl
end

def test-merge-seqs
  0 0 0
  0 20 10 here set-local0
  local0 cell-size + set-local1
  local0 local1 local0 ' int<=> 0 1 1 merge-seqs set-local2
  local2 2 0 ' write-int-sp map-seq-n/4
  nl

  0 20 12 3 10 6 2 here set-local0
  local0 cell-size 3 * + set-local1
  local0 local1 local0 ' int<=> 0 3 3 merge-seqs set-local2
  local2 6 0 ' write-int-sp map-seq-n/4
  nl

  0 20 12 10 4 here set-local0
  local0 cell-size 2 * + set-local1
  local0 local1 local0 ' int<=> 0 2 2 merge-seqs set-local2
  local2 4 0 ' write-int-sp map-seq-n/4
  nl

  0 20 12 4 10 here set-local0
  local0 cell-size 2 * + set-local1
  local0 local1 local0 ' int<=> 0 2 2 merge-seqs set-local2
  local2 4 0 ' write-int-sp map-seq-n/4
  nl

  0 12 3 2 100 10 6 here set-local0
  local0 cell-size 3 * + set-local1
  local0 local1 local0 ' int<=> 0 3 3 merge-seqs set-local2
  local2 6 0 ' write-int-sp map-seq-n/4
  nl

  0 100 30 12 3 2 111 100 99 10 6 here set-local0
  local0 cell-size 5 * + set-local1
  local0 local1 local0 ' int<=> 0 5 5 merge-seqs set-local2
  local2 10 0 ' write-int-sp map-seq-n/4
  nl
end

def test-merge-sort-seq
  0 0 0
  ( single )
  0 11 here set-local0
  ' int< local0 1 merge-sort-seq set-local1
  s" Sorted: " write-string/2
  local1 1 0 ' write-int-sp map-seq-n/4 nl
  local0 0 seq-peek 11 assert-equals
  
  ( sorted pair )
  0 11 4 here set-local0
  ' int< local0 2 merge-sort-seq set-local1
  s" Sorted: " write-string/2
  local1 2 0 ' write-int-sp map-seq-n/4 nl
  local1 0 seq-peek 4 assert-equals
  local1 1 seq-peek 11 assert-equals

  ( unsorted pair )
  0 4 44 here set-local0
  ' int< local0 2 merge-sort-seq set-local1
  s" Sorted: " write-string/2
  local1 2 0 ' write-int-sp map-seq-n/4 nl
  local1 0 seq-peek 4 assert-equals
  local1 1 seq-peek 44 assert-equals

  ( triple )
  0 -10 4 44 here set-local0
  ' int< local0 3 merge-sort-seq set-local1
  s" Sorted: " write-string/2
  local1 3 0 ' write-int-sp map-seq-n/4 nl
  local1 0 seq-peek -10 assert-equals
  local1 1 seq-peek 4 assert-equals
  local1 2 seq-peek 44 assert-equals

  ' sq-int< local0 3 merge-sort-seq set-local1
  s" Sorted^2: " write-string/2
  local1 3 0 ' write-int-sp map-seq-n/4 nl

  0 50 20 20 -10 4 44 100 -30 34 here set-local0
  ' int< local0 9 merge-sort-seq set-local1
  s" Sorted: " write-string/2
  local1 9 0 ' write-int-sp map-seq-n/4 nl
  local1 0 seq-peek -30 assert-equals
  local1 1 seq-peek -10 assert-equals
  local1 2 seq-peek 4 assert-equals

  ' sq-int< local0 9 merge-sort-seq set-local1
  s" Sorted^2: " write-string/2
  local1 9 0 ' write-int-sp map-seq-n/4 nl
  local1 0 seq-peek 4 assert-equals
  local1 1 seq-peek -10 assert-equals
  local1 2 seq-peek 20 assert-equals

  ( Sequence of strings )
  s[ oh, hello world. how are you? hello? ] set-local0
  7 cell-size * stack-allot local0 list->seq set-local0
  s" Unsorted: " write-string/2
  local0 7 0 ' write-line map-seq-n/4 nl
  ' byte-string< local0 7 merge-sort-seq set-local1
  s" Sorted: " write-string/2
  local1 7 0 ' write-line map-seq-n/4 nl

  ' byte-string> local0 7 merge-sort-seq set-local1
  s" Sorted: " write-string/2
  local1 7 0 ' write-line map-seq-n/4 nl
end

s[ src/lib/bm.4th
   src/lib/random.4th
] load-list

def test-merge-sort-seq-big/2
  0 0 0
  arg1 arg0 rand-seq/2 set-local0
  ' merge-sort-seq arg0 partial-first local0 partial-first ' int< partial-first set-local1
  debug? IF local0 arg0 10 min 0 ' write-int-sp map-seq-n/4 nl THEN
  local1 time-fun set-local2
  debug? IF local0 arg0 0 ' write-int-sp map-seq-n/4 nl THEN
  s" Time: " write-string/2 local2 write-int nl
  local2 2 return1-n
end

def test-merge-sort-seq-big
  s" Number: " write-string/2 arg0 write-int nl
  1000 arg0 test-merge-sort-seq-big/2
  arg0 arg1 int< IF
    arg0 2 * set-arg0 repeat-frame
  THEN .s
end
