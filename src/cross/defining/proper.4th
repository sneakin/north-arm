: does-proper
  out' do-proper dict-entry-code uint32@
  over dict-entry-code uint32!
  4 align-data
  dhere to-out-addr swap dict-entry-data uint32!  
;

: defproper
  create> does-proper
  defcol-read
  out-off' proper-exit ,op
  0 ,op
;

" endproper" ' endcol swap out-immediate/2

: lookup-or-create
  cross-lookup LOOKUP-WORD equals UNLESS
    create out-dict
  THEN
;

: redefproper
  next-token lookup-or-create does-proper
  defcol-read
  out-off' proper-exit ,op
  0 ,op
;

: out-loop
  out-off' pointer
  out-dict dict-entry-data uint32@
  out-off' jump
; out-immediate-as loop
