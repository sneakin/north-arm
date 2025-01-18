" src/lib/forth/return-stack.4th" load
" src/lib/assert.4th" load

: test->r
  789 123 >r 789 assert-equals
  r> 123 assert-equals
;

: test-rdup
  123 >r 456 >r rdup
  r> 456 assert-equals
  r> 456 assert-equals
  r> 123 assert-equals
;

: test-rswap
  1 >r 2 >r rswap
  r> 1 assert-equals
  r> 2 assert-equals
;

: test-rdropn
  0 1 >r 2 >r 3 >r
  2 rdropn r> 1 assert-equals
  0 assert-equals
;

: test-rover
  1 >r 2 >r 3 >r
  0 rover 3 assert-equals
  1 rover 2 assert-equals
  2 rover 1 assert-equals
  3 rdropn
  r@ 1 assert-not-equals
;

: test-rover!
  1 >r 2 >r 3 >r
  456 123 2 rover! 456 assert-equals
  2 rover 123 assert-equals
  1 rover 2 assert-equals
  0 rover 3 assert-equals
  3 rdropn
;

: test-rops
  test->r
  test-rdup
  test-rdropn
  test-rswap
  test-rover
  test-rover!
;
