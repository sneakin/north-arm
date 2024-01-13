( Proper Forth colon definitions for output: )

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

" endproper" ' endcol swap cross-immediate/2

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
  ( todo? north-bash needs the token on the stack and not the offset, but stage1+ needs the output word's offset. )
  out-off' pointer
  out-dict to-out-addr
  out-off' jump-data
; cross-immediate-as loop
