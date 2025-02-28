" src/lib/assert.4th" load

1 [IF] 2 [THEN] 2 assert-equals
1 0 [IF] 2 3 [THEN] 1 assert-equals

0 1 [IF] 2 [ELSE] 3 [THEN] 2 assert-equals 0 assert-equals
1 0 [IF] 2 [ELSE] 3 [THEN] 3 assert-equals 1 assert-equals

10 0 [IF]
  ( should be ignored as [IF] is truthy )
  0 assert
  0 1 [IF] 2 [ELSE] 3 [THEN] 2 assert-equals 0 assert-equals
  1 0 [IF] 2 [ELSE] 3 [THEN] 3 assert-equals 1 assert-equals
[ELSE] 1 assert
[THEN] 10 assert-equals

10 1 [IF]
  1 assert
[ELSE]
  ( should be ignored as [IF] is truthy annd skips to [ELSE] )
  0 assert
  0 1 [IF] 2 [ELSE] 3 [THEN] 2 assert-equals 0 assert-equals
  1 0 [IF] 2 [ELSE] 3 [THEN] 3 assert-equals 1 assert-equals
[THEN] 10 assert-equals

: test-[IF]
  2 [IF] 3 [THEN] 3 assert-equals
  4 0 [IF] 3 [THEN] 4 assert-equals

  2 [IF] 3 [ELSE] 4 [THEN] 3 assert-equals
  4 0 [IF] 3 [ELSE] 5 [THEN] 5 assert-equals 4 assert-equals
;

: test-[UNLESS]
  0 [UNLESS] 3 [THEN] 3 assert-equals
  4 1 [UNLESS] 3 [THEN] 4 assert-equals

  0 [UNLESS] 3 [ELSE] 4 [THEN] 3 assert-equals
  4 1 [UNLESS] 3 [ELSE] 5 [THEN] 5 assert-equals 4 assert-equals
;

: test-bracketed-conditions
  NORTH-STAGE [UNLESS]
    ' test-[IF] get-word " [IF]" assert-string-contains-not
    ' test-[IF] get-word " [ELSE]" assert-string-contains-not
    ' test-[IF] get-word " [THEN]" assert-string-contains-not
  [THEN]
  test-[IF]
  test-[UNLESS]
;

test-bracketed-conditions
