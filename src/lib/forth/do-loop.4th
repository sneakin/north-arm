( Standard Forth DO...LOOP construct with LEAVE, I, and J. )

' r@ defined? UNLESS " src/lib/forth/return-stack.4th" load THEN

defcol I ( ++ value )
  ( Return the value of the inner most DO...LOOP's counter. )
  r@ swap
endcol

defcol I! ( value -- )
  ( Set the value of the inner most DO...LOOP's counter. )
  swap rdrop >r
endcol

defcol J ( ++ value )
  ( Return the value of the second enclosing DO...LOOP's counter. )
  2 rover swap
endcol

defcol J! ( value -- )
  ( Return the value of the second enclosing DO...LOOP's counter. )
  swap 2 rover!
endcol

defcol K ( ++ value )
  ( Return the value of the third enclosing DO...LOOP's counter. )
  4 rover swap
endcol

defcol K! ( value -- )
  ( Return the value of the third enclosing DO...LOOP's counter. )
  swap 4 rover!
endcol

symbol> do-marker
symbol> leave-marker

: DO-init ( limit counter -- )
  ( Initiates a DO...LOOP by pushing the counter and limit onto the return stack. )
  swap >r rswap >r rswap
;

: DO ( limit counter ++ ...ops )
  ( Marks the start of a DO...LOOP. )
  do-marker
; immediate

: LEAVE ( ++ ...ops )
  ( Terminates a DO...LOOP by jumping to the post-LEAVE operations. )
  literal int32 leave-marker literal jump-rel
; immediate

def patch-leave-markers ( code-ptr -- )
  leave-marker dict stack-find/2
  IF
    dup arg0 - cell/ 2 + swap !
    repeat-frame
  ELSE 1 return0-n
  THEN
end

: generate-leave-step ( ++ ...ops )
    ( inc counter )
    literal r> literal int-add
    literal dup literal >r
    ( check counter )
    literal int32 int32 1 literal rover literal equals?
;

: generate-loop-jump ( loop-increment -- ...ops )
  ( find the DO )
  do-marker dict stack-find/2
  IF
    ( patch the do-marker )
    ' DO-init cs - over !
    here - cell/ 2 + negate
    ( jump to after DO )
    literal int32 swap literal unless-jump
    ( or clean up )
    literal int32 int32 2 literal rdropn
  ELSE s" DO not found." error-line/2
       drop
  THEN
;

: +LOOP ( increment -- ...ops )
  ( Leaves the loop if the counter equals the maximuw,
    otherwise it Increments the loop counter and jumps back to DO. )
  generate-leave-step
  here patch-leave-markers
  generate-loop-jump
; immediate

: LOOP ( -- ...ops )
  ( Performs a ~1 +LOOP~. )
  literal int32 int32 1 POSTPONE +LOOP
; immediate

: DO-pre ( ++ ...ops )
  literal DO
  literal r@
  literal int32 literal 1 literal rover
;

: DO-post ( ++ ...ops )
  POSTPONE IF POSTPONE LEAVE POSTPONE THEN
;
  
: ?DO ( limit init -- ...ops )
  ( Like DO but leaves the loop if the counter equals the limit. )
  DO-pre literal equals? DO-post
; immediate

: DO< ( limit init -- ...ops )
  ( Like DO but leaves the loop if the unsigned counter is greater or equal to the limit. )
  DO-pre literal uint>= DO-post
; immediate

: DO<= ( limit init -- ...ops )
  ( Like DO but leaves the loop if the unsigned counter is greater than the limit. )
  DO-pre literal uint> DO-post
; immediate
