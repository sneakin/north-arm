( Conditionals: )

( todo are output immediates placing output words in defs? )
( todo whitespace? is missing a THEN and is getting an extra 0x40 )

: out-IF
  out-off' int32
  if-placeholder
  out-off' unless-jump
; cross-immediate-as IF

: out-UNLESS
  out-off' int32
  if-placeholder
  out-off' if-jump
; cross-immediate-as UNLESS

: out-ELSE
  out-off' int32
  if-placeholder stack-find UNLESS s" Warning: ELSE with no IF" error-line/2 0 THEN
  if-placeholder out-off' jump-rel
  roll
  dup here stack-delta int32 3 -
  swap spoke
; cross-immediate-as ELSE

: out-THEN
  if-placeholder stack-find UNLESS s" Warning: THEN with no IF" error-line/2 0 THEN
  dup here stack-delta int32 3 -
  swap spoke
; cross-immediate-as THEN
