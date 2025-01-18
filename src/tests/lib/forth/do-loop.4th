" src/lib/forth/return-stack.4th" load
" src/lib/forth/do-loop.4th" load
" src/lib/assert.4th" load

: test-do-loop-leave
  10
  10 0 DO
    I 5 int< UNLESS LEAVE THEN
    1 -
    ( I write-int space dup write-int nl )
  LOOP
  5 assert-equals
  ( rpeek error-hex-int enl )
;

: test-do-loop-down
  10
  0 10 DO
    I 5 int< IF LEAVE THEN
    1 -
    ( I write-int nl )
  -1 +LOOP
  4 assert-equals
;

: test-do-loop-loop-leaves
  10
  10 0 DO
    1 -
    ( I write-int nl )
  2 +LOOP
  5 assert-equals
;

: test-do-loop-inc-misses-limit
  0
  10 0 DO
    1 +
    I 32 int< UNLESS LEAVE THEN
    ( I write-int nl )
  8 +LOOP
  5 assert-equals
;

: test-?do-loop
  0
  10 0 ?DO
    1 +
    ( I write-int nl )
  LOOP

  10 assert-equals
;

: test-do<-loop
  0
  5 0 DO<
    1 +
    ( I write-int nl )
  LOOP
  5 assert-equals
;

: test-do<-loop-no-step
  0
  1 1 DO<
    1 +
    ( I write-int nl )
  LOOP
  0 assert-equals
;

: test-do<=-loop
  0
  5 0 DO<=
    1 +
    ( I write-int nl )
  LOOP
  5 assert-equals
;

: test-nested-do-loop
  0
  5 0 DO
    I +
    0
    15 10 DO
      I +
      I 15 10 assert-in-range
      J 5 0 assert-in-range
      ( I write-int space J write-int nl )
    LOOP
    I 5 0 assert-in-range
    60 assert-equals
  LOOP
  10 assert-equals
;

: test-nested-nested-do-loop
  0
  5 0 DO
    I +
    0
    15 10 DO
      I +
      0
      25 20 DO
	I +
	I 25 20 assert-in-range
	J 15 10 assert-in-range
	K 5 0 assert-in-range
	( I write-int space J write-int space K write-int nl )
      LOOP
      I 15 10 assert-in-range
      J 5 0 assert-in-range
      110 assert-equals
    LOOP
    I 5 0 assert-in-range
    60 assert-equals
  LOOP
  10 assert-equals
;

: test-do-loops
  test-do-loop-leave
  test-do-loop-down
  test-do-loop-loop-leaves
  test-do-loop-inc-misses-limit
  test-?do-loop
  test-do<-loop
  test-do<-loop-no-step
  test-do<=-loop
  test-nested-do-loop
  test-nested-nested-do-loop
;
