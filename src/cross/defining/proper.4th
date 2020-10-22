: does-proper
  out' do-proper dict-entry-code uint32@
  over dict-entry-code uint32!
  4 align-data
  dhere swap dict-entry-data uint32!  
;

: defproper
  create> does-proper
  defcol-read
  out' proper-exit ,op
;

' endcol ' endproper out-immediate/2

: lookup-or-create
  cross-lookup LOOKUP-WORD equals UNLESS
    create out-dict
  THEN
;

: redefproper
  next-token lookup-or-create does-proper
  defcol-read
  out' proper-exit ,op
;

: out-loop
  ' pointer
  out-dict dict-entry-data uint32@
  ' jump
; out-immediate-as loop
