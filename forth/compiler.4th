" Loading..." error-line

0 var> compiling
0 var> compiling-immediates
0 var> this-word

: alias
  get-word swap set-word!
;

: alias>
  next-token next-token alias
;

alias> down-stack/1 +
: down-stack 1 down-stack/1 ;

alias> up-stack/1 -
: up-stack 1 up-stack/1 ;

: immediate-exec
  over swap dict-lookup
  null? 3 unless-jump drop 0 return
  swap drop sys-exec 1
;

" feval 0 set-compiling" ' ; set-immediate!

: compiling-read-loop
  next-token
  null? 1 unless-jump return
  compiling-immediates immediate-exec drop
  compiling 1 if-jump return
  loop
;

' *read-terminator* const> read-terminator

: compiling-read/1
  1 set-compiling
  set-compiling-immediates
  read-terminator compiling-read-loop
;

: compiling-read
  literal IDICT compiling-read/1
;

: 2dup
  over over
;
  
: stack-find-loop
  2dup speek equals 3 unless-jump swap drop return
  up-stack
  dup 0 equals 1 unless-jump return
  loop
;

: stack-find/2
  2 up-stack/1 stack-find-loop
;

: stack-find
  here stack-find/2
;

: concat-seq-loop
  dup speek has-spaces? 1 unless-jump quote-string
  4 overn "  " swap ++ ++
  3 set-overn
  2dup equals 1 unless-jump return
  down-stack loop
;

: concat-seq
  here literal 0 swap " " swap
  read-terminator stack-find
  dup 4 set-overn
  down-stack concat-seq-loop 2 dropn
  2dup swap spoke
  over here swap - up-stack dropn
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
  compile " feval " ++ swap set-word!
;

: IF
  literal literal
  literal if-placeholder
  literal unless-jump
; immediate

: UNLESS
  literal literal
  literal if-placeholder
  literal if-jump
; immediate

: ELSE
  literal literal
  literal if-placeholder stack-find
  literal if-placeholder literal jump-rel
  roll
  dup 3 + here swap up-stack/1
  swap spoke
; immediate

: THEN
  literal if-placeholder stack-find
  dup 3 + here swap up-stack/1
  swap spoke
; immediate

" Done." error-line
