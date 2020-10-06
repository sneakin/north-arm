( Word aliases: )

: does-defalias
  cross-lookup LOOKUP-WORD equals IF
    dup dict-entry-code uint32@ 3 overn dict-entry-code uint32! 
    dup dict-entry-data uint32@ 3 overn dict-entry-data uint32!
  ELSE
    " Warning: bad alias" error-line
  THEN
  2 dropn
;
  
: defalias>
  create> next-token does-defalias
;
