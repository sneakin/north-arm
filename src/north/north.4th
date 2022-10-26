( todo remove this file? )

frame-byte-size defconst> frame-size
cell-size defconst> call-frame-size

alias> doc( ( immediate
alias> args( ( immediate

defalias> equals equals?

defcol dallot-seq
  swap
  dup int32 1 + dallot
  2dup poke
  swap drop swap
endcol

defcol roll ( a b c -- c a b )
  int32 4 overn
  int32 3 overn int32 5 set-overn
  int32 4 overn int32 3 set-overn
  int32 3 set-overn
endcol

defcol drop2
  rot int32 2 dropn
endcol

defcol drop3
  rot int32 2 dropn
  swap drop
endcol

defcol swapdrop
  rot drop swap
endcol

defcol rotdrop2 ( a b c -- c )
  swap int32 4 set-overn
  rot int32 2 dropn
endcol

def copydown ( src dest n )
  arg0 0 int> IF
    arg0 1 - set-arg0
    arg2 arg0 seq-peek
    arg1 arg0 seq-poke
    repeat-frame
  THEN
end

defcol returnN
  ( copy N values over the frame's return and FP. Return from the frame. )
  ( save the return )
  current-frame return-address peek
  ( copy the values )
  here cell-size 3 * +
  current-frame frame-byte-size + 5 overn cell-size * -
  5 overn
  end-frame
  copydown
  ( copy the return up )
  2 overn cell-size -
  5 overn over poke
  ( and then )
  move jump
endcol

alias> c-defvar> defvar>

: global-var
  int32 0 c-defvar>
;

: constant
  create> does-constant
  next-token parse-int UNLESS error ( todo better error ) THEN
  swap dict-entry-data uint32!
;

( todo in-range? should drop args; and to ignore arg order )

: char-code
  dup 2 0 in-range? UNLESS 5 dropn 0 proper-exit THEN ( todo error )
  3 dropn
  dup 2 equals? IF
    drop 1 string-peek
    dup 110 equals? IF drop 10 proper-exit THEN
    dup 118 equals? IF drop 11 proper-exit THEN
    dup 116 equals? IF drop 9 proper-exit THEN
    dup 114 equals? IF drop 13 proper-exit THEN
    dup 48 equals? IF drop 0 proper-exit THEN
    drop 0 proper-exit ( todo error )
  THEN
  dup 1 equals?
  IF drop 0 string-peek
  ELSE 2 dropn 0 ( todo error )
  THEN
;

: out-char-code
  next-token char-code
; out-immediate-as char-code

(
: immediate
;

: immediate-as
  next-token .s 2 dropn
;

: immediate-only
;
)

: north-def-read
  defcol-read-init compiling-read
  out' exit-frame to-out-addr swap 1 +
  ( todo drop terminator search and use length )
  read-terminator over 3 + set-overn
  out' begin-frame to-out-addr over 2 + set-overn
  here 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: north-def
  create> does-col north-def-read
  0 ,op
;

defcol read-byte
  0
  1 locals current-input @ read
  drop swap
endcol

defcol input-reset
  exit
endcol

defcol write-byte
  swap here 1 swap current-output @ write 2 dropn
endcol

defcol write-word
  swap here cell-size swap current-output @ write 2 dropn
endcol

defcol jump-entry-data
  swap cs + dict-entry-data peek jump-cs
end

( defalias> return0 return )
defalias> drop-call-frame drop2

defalias> code-segment cs

defalias> ! poke
defalias> @ peek
defalias> exec-core-word exec
defalias> or logior
defalias> value-peeker do-const
defalias> variable-peeker do-var
defalias> string pointer
defalias> uint32 int32

alias> RECURSE repeat-frame out-immediate

alias> c: :
alias> cdef def
( alias> def north-def )
alias> : north-def

alias> calias> alias>
alias> alias defalias>

( alias> immediate out-immediate
alias> immediate-as out-immediate-as )
( immediates need to build a dictionary that's writen out. )

( read $hex )
( strings )
( recurse )
( : needs a def? )
