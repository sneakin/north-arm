: write-float32-binop-message
  swap write-float32 write-string write-float32
;

: assert-float32-equals
  2dup float32-equals? dup assert IF
    2 dropn
  ELSE
    space "  != " write-float32-binop-message nl
  THEN
;

: assert-float32-within ( a b epsilon -- )
  3 overn 3 overn float32-sub float32-abs float32>=
  dup assert IF
    2 dropn
  ELSE
    space "  ≇ " write-float32-binop-message nl
  THEN
;
