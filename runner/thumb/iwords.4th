: out-immediate/2
  swap get-word swap literal out_immediates dict-set!
;

: out-immediate/1
  dup out-immediate/2
;

: out-immediate this-word out-immediate/1 ;
: out-immediate-as this-word next-token out-immediate/2 ;

" feval 0 set-compiling" ' ; ' out_immediates dict-set!

' ( out-immediate/1
" '" out-immediate/1

: out-dq
  ' \" read-until
; out-immediate-as s"
out-immediate-as "

: out-IF
  literal literal
  literal if-placeholder
  literal unless-jump
; out-immediate-as IF

: out-UNLESS
  literal literal
  literal if-placeholder
  literal if-jump
; out-immediate-as UNLESS

: out-ELSE
  literal literal
  literal if-placeholder stack-find
  literal if-placeholder literal jump-rel
  roll
  dup 3 + here swap up-stack/1 -op-size mult
  swap spoke
; out-immediate-as ELSE

: out-THEN
  literal if-placeholder stack-find
  dup 3 + here swap up-stack/1 -op-size mult
  swap spoke
; out-immediate-as THEN
