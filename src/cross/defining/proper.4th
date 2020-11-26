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
  ( north-bash needs the token on the stack and not the offset, but stage1+ needs the output word's offset. )
  literal pointer
  out-dict dict-entry-data uint32@
  literal jump
; out-immediate-as loop
