( Adds a colon definition that supports immediate words. Comments only work on the top level until colon is defined. )

0 var> compiling
0 var> compiling-immediates
0 var> compiling-state
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

( Compiler's read loop with immediates: )

: immediate-exec
  over swap dict-lookup
  null? 3 unless-jump drop 0 return
  swap drop sys-exec 1
;

" feval 0 set-compiling" ' ; set-immediate!

: symbol>
  next-token dup " fpush " ++ swap set-word!
;

: ?exec
  dup 0 equals 2 if-jump exec return
  drop
;

: compiling-read-loop
  next-token
  null? 1 unless-jump return
  compiling-immediates immediate-exec drop
  compiling-state ?exec
  compiling 1 if-jump return
  loop
;

' *read-terminator* const> read-terminator

( read-terminator ... ++ more-words )
: compiling-read
  1 set-compiling
  compiling-read-loop
;

: compiling-init
  literal IDICT set-compiling-immediates
  0 set-compiling-state
;

( Stack operations: )

: 2dup
  over over
;
  
alias> down-stack/2 +
: down-stack 1 down-stack/2 ;

alias> up-stack/2 -
: up-stack 1 up-stack/2 ;

: stack-delta
  swap -
;

: set-overn
  here swap up-stack/2 up-stack spoke
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
  here 2 up-stack/2 stack-find/2
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

: speek-byte speek 255 logand ;
: spoke-byte spoke ;

( Definitions! )

: compile
  compiling-init read-terminator compiling-read concat-seq
;

: :
  next-token dup error-line
  dup set-this-word
  compile " feval " ++ swap set-word!
;

alias> :: :

: defined?
  get-word null? swap drop
;

( Now that immediates can execute: )

( Args: src-word target-word )
: immediate/2
  swap get-word swap set-immediate!
;

: immediate/1
  dup immediate/2
;

: immediate this-word immediate/1 ;
: immediate-as this-word next-token immediate/2 ;

' ( immediate/1

( IF ... ELSE ... THEN )

symbol> if-placeholder

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
  dup here stack-delta 3 -
  swap spoke
; immediate

: THEN
  literal if-placeholder stack-find
  dup here stack-delta 3 -
  swap spoke
; immediate

( Numerics: )

: unsigned-integer/2
  q" #" swap ++ ++ 0 +
;

: negate
  0 swap -
;

( Comparisons: )

: int> swap int<= ;
: int>= swap int< ;

alias> uint< int<
alias> uint<= int<=
alias> uint> int>
alias> uint>= int>=

( Misc: )

alias> ! dpoke
alias> @ dpeek
alias> string-const> const>

: POSTPONE
  next-token
; immediate

: load-sources
  dup 0 equals IF drop return THEN
  swap load .s
  1 - loop
;

: error-line/2
  drop error-line
;

: not-found " Not found." error-line ;

" src/bash/frames.4th" load
" src/bash/list.4th" load