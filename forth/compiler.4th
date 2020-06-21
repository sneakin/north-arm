" Loading..." error-line

0 var> compiling
0 var> this-word

: immediate-exec
  dup immediate-lookup
  null? 3 unless-jump drop 0 return
  swap drop sys-exec 1
;

" feval 0 set-compiling" ' ; set-immediate!

: compiling-read-loop
  next-token
  null? 1 unless-jump return
  immediate-exec drop
  compiling 1 if-jump return
  loop
;

' *read-terminator* const> read-terminator

: compiling-read
  1 set-compiling
  read-terminator compiling-read-loop
;

: 2dup
  over over
;
  
: stack-find-loop
  2dup speek equals 3 unless-jump swap drop return
  1 -
  dup 0 equals 1 unless-jump return
  loop
;

: stack-find
  here 2 - stack-find-loop
;

: concat-seq-loop
  dup speek
  4 overn "  " swap ++ ++
  3 set-overn
  2dup equals 1 unless-jump return
  1 + loop
;

: concat-seq
  here literal 0 swap " " swap
  read-terminator stack-find
  dup 4 set-overn
  1 + concat-seq-loop 2 dropn
  2dup swap spoke
  over here swap - 1 - dropn
;

: compile
  compiling-read concat-seq
;

: immediate/1
  dup get-word swap set-immediate!
;

: immediate this-word immediate/1 ;

' ( immediate/1

: :
  next-token dup error-line
  dup set-this-word
  compile literal " feval " ++ swap set-word!
;

: IF
  literal if-placeholder
  literal unless-jump
; immediate

: UNLESS
  literal if-placeholder
  literal if-jump
; immediate

: ELSE
  literal if-placeholder stack-find
  literal if-placeholder literal jump
  roll
  dup 3 + here swap - swap spoke
; immediate

: THEN
  literal if-placeholder stack-find
  dup 3 + here swap - swap spoke
; immediate

" Done." error-line
