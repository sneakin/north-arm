( Adds a colon definition that supports immediate words. Comments only work on the top level until colon is defined. )

0 const> null
0 const> false
-1 const> true

false var> compiling
null var> compiling-immediates
null var> compiling-state
null var> this-word

( Defining words: )

: defined?
  get-word null? not swap drop
;

: make-const
  swap " fpush " ++
  swap set-word!
;

: alias
  swap get-word swap
  dup set-this-word
  set-word!
;

: alias>
  next-token next-token swap alias
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

: maybe-compiler-warning
  dup defined?
  1 unless-jump return
  number? 1 unless-jump return
  " Warning: " error-string dup error-string "  not found" error-line
;

: compiling-read-loop
  next-token
  null? 1 unless-jump return
  compiling-immediates immediate-exec 2 if-jump
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
  literal maybe-compiler-warning set-compiling-state
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

: string-needs-escaping?
  has-spaces?
  over has-special-chars? swap drop
  logior
;

( Args: acc stop-ptr work-stack-ptr )
: concat-seq-loop
  2dup equals 1 unless-jump return
  dup speek string-needs-escaping? 1 unless-jump quote-string
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

: comp-IF
  literal literal
  literal if-placeholder
  literal unless-jump
; immediate-as IF

: comp-UNLESS
  literal literal
  literal if-placeholder
  literal if-jump
; immediate-as UNLESS

: comp-ELSE
  literal literal
  literal if-placeholder stack-find
  literal if-placeholder literal jump-rel
  roll
  dup here stack-delta 3 -
  swap spoke
; immediate-as ELSE

: comp-THEN
  literal if-placeholder stack-find
  dup here stack-delta 3 -
  swap spoke
; immediate-as THEN

( Compile time conditions: )

: IF-loop ( new-block-fn then else depth-counter -- )
  next-token
  dup 6 overn exec IF drop 1 +
  ELSE
    dup 5 overn equals IF
      drop dup IF 1 - ELSE 4 dropn return THEN
    ELSE
      dup 4 overn equals IF
	over 0 equals IF 5 dropn return THEN
      THEN drop
    THEN
  THEN loop
;

: ELSE-loop ( new-block-fn then depth-counter -- )
  next-token
  dup 4 overn equals IF
    over 0 equals IF 4 dropn return ELSE drop 1 - THEN
  ELSE
    dup 5 overn exec IF drop 1 + ELSE drop THEN
  THEN loop
;

: [if-or-unless?]
  dup " [IF]" equals
  swap " [UNLESS]" equals
  logior
;

: [IF] UNLESS ' [if-or-unless?] " [THEN]" " [ELSE]" 0 IF-loop THEN ; immediate
: [UNLESS] IF ' [if-or-unless?] " [THEN]" " [ELSE]" 0 IF-loop THEN ; immediate
: [THEN] ( nop ) ; immediate
: [ELSE] ' [if-or-unless?] " [THEN]" 0 ELSE-loop ; immediate

: if-or-unless?
  dup " IF" equals
  swap " UNLESS" equals
  logior
;

: IF UNLESS ' if-or-unless? " THEN" " ELSE" 0 IF-loop THEN ;
: UNLESS IF ' if-or-unless? " THEN" " ELSE" 0 IF-loop THEN ;
: THEN ( nop ) ;
: ELSE ' if-or-unless? " THEN" 0 ELSE-loop ;

( Numerics: )

: unsigned-integer/2 q" #" swap ++ ++ 0 + ;
: negate 0 swap - ;
: negative? dup 0 int< ;
: abs-int negative? IF negate THEN ;

alias> int-add +
alias> int-sub -
alias> mult *
alias> int-mul *
alias> int-div /
alias> int-mod mod
alias> uint-mul *
alias> uint-div /
alias> uint-mod mod

( Comparisons: )

: int> swap int< ;
: int>= swap int<= ;

alias> uint< int<
alias> uint<= int<=
alias> uint> int>
alias> uint>= int>=

alias> or logior

( Misc: )

320 var> token-buffer-max ( used to condition the about message )
1 const> op-size
1 const> jump-op-size
4 var> cell-size

alias> ! dpoke
alias> @ dpeek
alias> peek-off dpeek-off
alias> poke-off dpoke-off
alias> string-const> const>
alias> tmp" s"

: POSTPONE
  next-token
; immediate

: load-sources
  dup 0 equals IF drop return THEN
  swap load
  1 - loop
;

: error-line/2 drop error-line ;
: error-int ,,i drop ;
: error-hex-int negative? IF " -" error-string abs-int THEN ,,h drop ;
: error-hex-uint ,,h drop ;
: error-string/2 drop error-string ;

: not-found " Not found." error-line ;

: write-int ,i drop ;
: write-hex-uint ,h drop ;
: write-string/2 drop write-string ;
: write-line/2 drop write-line ;

: peek " warning: peeker" error-line ;
: poke " warning: poker" error-line ;

: data-null? ( value ++ yes? ) null? over 0 equals? or ;

" src/bash/platform.4th" load
" src/bash/frames.4th" load
" src/bash/list.4th" load
" src/bash/seq.4th" load
" src/bash/process.4th" load
