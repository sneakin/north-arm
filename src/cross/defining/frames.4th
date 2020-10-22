: repeat-frame
  literal int32
  literal begin-frame stack-find here - 1 - -op-size mult
  literal jump-rel
; out-immediate

( todo does-frame )
( todo needs to be adapted for interp )

: def-read
  literal out_immediates set-compiling-immediates
  ' defcol-state-fn set-compiling-state
  read-terminator literal begin-frame
  compiling-read
  here down-stack 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: def
  create> does-col def-read
  out' return ,op
;

: end
  0 set-compiling
; out-immediate
