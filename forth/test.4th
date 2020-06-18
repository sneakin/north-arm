" Loading..." .

: 2dup
  over over
;

: assert
  2dup equals 3 unless-jump
  1 . return
  0 .
;

: test-assert
  12 12 assert
  2 dropn
;

: test-drop
  1 2 drop
  1 assert
  2 dropn
;

: test-dropn
  123 1 2 2 dropn
  123 assert
  2 dropn
;

: test-equals
  0 0 equals 1 assert
  12 12 equals 1 assert
  " hello world" " hello world" equals 1 assert
  0 1 equals 0 assert
  1 0 equals 0 assert
  " hello there" " hello world" equals 0 assert
  12 dropn
;


: test-if-jump-inner  2 if-jump 22 return 33 ;

: test-if-jump
  0 test-if-jump-inner 22 assert
  1 test-if-jump-inner 33 assert
  4 dropn
;

: run-tests
  test-assert
  test-equals
  test-drop
  test-dropn
  test-if-jump
;

: boo
  " boo boo" .
;
