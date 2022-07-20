load-core
" src/lib/assert.4th" load

: test-assert-data
  dhere 0 assert-data
  dhere
  dup 1 dpush 2 dpush 1 2 2 assert-data
  dup 3 dpush 4 dpush 1 2 3 4 4 assert-data
  drop 
;
