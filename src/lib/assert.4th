: assert
  IF s" ." write-string/2
  ELSE s" F" write-string/2
  THEN
;

: assert-equals
  2dup equals dup assert IF
    2 dropn
  ELSE
    space write-hex-uint space write-hex-uint nl
  THEN
;
