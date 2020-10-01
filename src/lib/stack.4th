" *stack-marker*" string-const> stack-marker

: stack-marker?
  dup stack-marker equals
;
  
: drop-to-marker
  stack-marker? IF drop ELSE drop loop THEN
;
