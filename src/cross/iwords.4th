( Immediates for output target words: )

: cross-immediate/2 ( src-word out-word )
  swap get-word swap literal cross_immediates dict-set!
;

: cross-immediate/1 ( word )
  dup cross-immediate/2
;

: cross-immediate this-word cross-immediate/1 ;
: cross-immediate-as this-word next-token cross-immediate/2 ;

" feval 0 set-compiling" ' ; ' cross_immediates dict-set!

' ( cross-immediate/1
' POSTPONE cross-immediate/1

: out-dq
  ( Read until a double quote, writing the contained data to the data stack and pushing the calls to leave a pointer on the stack for a definition. )
  literal cstring dhere to-out-addr
  ' \" read-until ,byte-string 4 align-data
  ( Update the word being defined as it's definition will have moved. )
  ( todo update when mapping the stack? )
  dhere out-dict dict-entry-data uint32!
; cross-immediate-as "

: out-dq-string
  ( Read until a double quote, writing the contained data to the data stack and leaving a quoted pointer and length on the stack for a definition. )
  literal cstring dhere to-out-addr
  ' \" read-until
  dup string-length swap ,byte-string 4 align-data
  literal int32 swap
  ( Update the word being defined as it's definition will have moved. )
  ( todo update when mapping the stack? )
  dhere out-dict dict-entry-data uint32!
; cross-immediate-as s"

( Control flow: )

: out-IF
  literal int32
  literal if-placeholder
  literal unless-jump
; cross-immediate-as IF

: out-UNLESS
  literal int32
  literal if-placeholder
  literal if-jump
; cross-immediate-as UNLESS

: out-ELSE
  literal int32
  literal if-placeholder stack-find
  literal if-placeholder literal jump-rel
  roll
  dup here stack-delta 3 - -op-size mult
  swap spoke
; cross-immediate-as ELSE

: out-THEN
  literal if-placeholder stack-find
  dup here stack-delta 3 - -op-size mult
  swap spoke
; cross-immediate-as THEN

: out-RECURSE
  ' pointer
  out-dict dict-entry-data dpeek
  ' jump
; cross-immediate
