: write-fixed16-binop-message
  swap write-fixed16 write-string write-fixed16
;

: assert-fixed16-equals
  2dup equals dup assert IF
    2 dropn
  ELSE
    space "  != " write-fixed16-binop-message nl
  THEN
;

: assert-fixed16-not-equals
  2dup equals not dup assert IF
    2 dropn
  ELSE
    space "  == " write-fixed16-binop-message nl
  THEN
;

: assert-fixed16-within ( a b epsilon -- )
  3 overn 3 overn fixed16-sub fixed16-abs fixed16>=
  dup assert IF
    2 dropn
  ELSE
    space "  ≇ " write-fixed16-binop-message nl
  THEN
;
