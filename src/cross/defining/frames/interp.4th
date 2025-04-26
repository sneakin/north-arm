0 var> this-frame

: repeat-frame
  out-off' int32
  ( compiling-read sets up a frame that holds the accumulated list of words.
    This needs to calculate a jump to after the nearest begin-frame. )
  out-off' begin-frame locals stack-find/2 IF locals umin ELSE locals THEN here - -op-size / 2 + negate
  out-off' jump-rel
; cross-immediate

( todo does-frame )

: def-read
  defcol-read-init compiling-read
  out-off' return0 swap 1 +
  out-off' begin-frame over 2 + set-overn 1 +
  defcol-copy-to-data
  5 + dropn ( drops the frame left by compiling-read )
;

: def
  create> does-col def-read
  0 ,op
;

: end
  0 compiling poke
; cross-immediate
