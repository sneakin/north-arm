: repeat-frame
  literal int32
  literal begin-frame stack-find here - 1 -
  literal jump-rel
; cross-immediate

( todo does-frame )
( todo needs to be adapted for interp )

: def-read
  defcol-read-init
  read-terminator literal begin-frame
  compiling-read
  here down-stack 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: def
  create> does-col def-read
  out' return0 ,op
  0 ,op
;

: end
  0 set-compiling
; cross-immediate
