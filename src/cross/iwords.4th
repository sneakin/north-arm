( Immediates for output target words: )

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
' POSTPONE out-immediate/1

( Output word quoting. Order is important with postpones in the output variants in owords.4th. )

: out'
  next-token cross-lookup LOOKUP-NOT-FOUND equals IF
    not-found
  THEN
; immediate-as [out'] immediate ( for postpone safety )
 
: out-off'
  POSTPONE out' to-out-addr
; out-immediate-as ['] immediate ( for postpone safety )

: out''
  literal literal POSTPONE out'
; immediate-as out'

: out-dq
  ( Read until a double quote, writing the contained data to the data stack and pushing the calls to leave a pointer on the stack for a definition. )
  literal cstring dhere to-out-addr
  ' \" read-until ,byte-string 4 align-data
  ( Update the word being defined as it's definition will have moved. )
  ( todo update when mapping the stack? )
  dhere out-dict dict-entry-data uint32!
; out-immediate-as "

: out-dq-string
  ( Read until a double quote, writing the contained data to the data stack and leaving a quoted pointer and length on the stack for a definition. )
  literal cstring dhere to-out-addr
  ' \" read-until
  dup string-length swap ,byte-string 4 align-data
  literal int32 swap
  ( Update the word being defined as it's definition will have moved. )
  ( todo update when mapping the stack? )
  dhere out-dict dict-entry-data uint32!
; out-immediate-as s"

( Control flow: )

: out-IF
  literal int32
  literal if-placeholder
  literal unless-jump
; out-immediate-as IF

: out-UNLESS
  literal int32
  literal if-placeholder
  literal if-jump
; out-immediate-as UNLESS

: out-ELSE
  literal int32
  literal if-placeholder stack-find
  literal if-placeholder literal jump-rel
  roll
  dup here stack-delta 3 - -op-size mult
  swap spoke
; out-immediate-as ELSE

: out-THEN
  literal if-placeholder stack-find
  dup here stack-delta 3 - -op-size mult
  swap spoke
; out-immediate-as THEN

: out-RECURSE
  literal int32
  out-dict dict-entry-data peek
  literal jump-cs
; out-immediate
