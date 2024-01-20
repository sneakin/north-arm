0 var> this-frame

: repeat-frame
  out-off' int32
  ( compiling-read sets up a frame that holds the accumulated list of words.
    This needs to calculate a jump to after the nearest begin-frame. )
  out-off' begin-frame locals stack-find/2 locals min here - -op-size / 2 + negate
  out-off' jump-rel
; cross-immediate

( todo does-frame )

: def-read
  defcol-read-init compiling-read
  out' return0 to-out-addr swap 1 +
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
; cross-immediate
