(
' cell-size get-word UNLESS 4 const> cell-size THEN
' -op-size get-word UNLESS cell-size const> -op-size THEN
)

: out-immediate/2 ( src-word out-word )
  swap get-word swap literal out_immediates dict-set!
;

: out-immediate/1 ( word )
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

: out-dq-string
  ( Read until a double quote, writing the contained data to the data stack and leaving a literal and length on the stack for a definition. )
  literal pointer dhere ( todo pointer or segment offset )
  ' \" read-until
  dup string-length swap ,byte-string 4 align-data
  literal int32 swap
  ( Update the word being defined as it's definition will have moved. )
  ( todo update when mapping the stack? )
  dhere dict dict-entry-data uint32!
; out-immediate-as "

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

: RECURSE
  ' int32
  dict
  ' exec ( fixme litters stack with return addresses? )
; out-immediate
