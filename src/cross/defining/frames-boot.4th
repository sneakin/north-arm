0 var> this-frame

: repeat-frame
  out-off' int32
  ( todo usings locals is a hack. should have begin-frame on the stack before compiling-read, but def vs colon. )
  out-off' begin-frame stack-find locals min
  here - -op-size 2 * + negate
  out-off' jump-rel
; out-immediate

( todo does-frame )
( todo needs to be adapted for interp )

: def-read
  defcol-read-init compiling-read
  out' return to-out-addr swap 1 +
  ( todo drop terminator search and use length )
  read-terminator over 3 + set-overn
  out' begin-frame to-out-addr over 2 + set-overn
  here 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: def
  create> does-col def-read
  0 ,op
;

: end
  0 compiling poke
; out-immediate
