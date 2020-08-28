: assert-equals
  2dup equals IF
    2 dropn
    " ." write-string/2
  ELSE
    " F" write-string/2
    sp write-hex-uint sp write-hex-uint nl
  THEN
;
