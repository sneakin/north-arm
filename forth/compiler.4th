( Adds a colon definition that supports immediate words. Comments only work on the top level until colon is defined. )

0 var> compiling
0 var> compiling-immediates
0 var> this-word

( Defining words: )

: make-const
  swap " fpush " ++
  swap set-word!
;

: alias
  get-word swap
  dup set-this-word
  set-word!
;

: alias>
  next-token next-token alias
;

alias> down-stack/1 +
: down-stack 1 down-stack/1 ;

alias> up-stack/1 -
: up-stack 1 up-stack/1 ;

( Compiler's read loop with immediates: )

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

( read-terminator ... immediates )
: compiling-read/2
  1 set-compiling
  set-compiling-immediates
  compiling-read-loop
;

: compiling-read/1
  read-terminator swap compiling-read/2
;

: compiling-read
  literal IDICT compiling-read/1
;

( Stack operations: )

: 2dup
  over over
;
  
: set-overn
  here swap up-stack/1 up-stack spoke
;

: stack-find-loop
  2dup speek equals 3 unless-jump swap drop return
  up-stack
  dup 0 equals 1 unless-jump return
  loop
;

: stack-find/2
  stack-find-loop
;

: stack-find
  here 2 up-stack/1 stack-find/2
;

( Args: acc stop-ptr work-stack-ptr )
: concat-seq-loop
  2dup equals 1 unless-jump return
  dup speek has-spaces? 1 unless-jump quote-string
  4 overn "  " swap ++ ++
  3 set-overn
  down-stack loop
;

( Concatenates everything on the stack between here and a read-terminator into a string. )
: concat-seq
  here down-stack literal 0 swap " " swap
  read-terminator stack-find
  dup 4 set-overn
  down-stack concat-seq-loop 2 dropn
  2dup swap spoke
  over here swap - up-stack dropn
;

( Definitions! )

: compile
  compiling-read concat-seq
;

: :
  next-token dup error-line
  dup set-this-word
  compile " feval " ++ swap set-word!
;

( Now that immediates can execute: )

: immediate/1
  dup get-word swap set-immediate!
;

: immediate this-word immediate/1 ;

' ( immediate/1

( IF ... ELSE ... THEN )

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

( Numerics: )

: unsigned-integer/2
  q" #" swap ++ ++ 0 +
;

: negate
  0 swap -
;

