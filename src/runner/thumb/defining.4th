( Colon definitions: )

( todo to get rid of op- calls, some ops will need to be defined before this. )

: does-col/1
  out' do-col dict-entry-code uint32@ over dict-entry-code uint32!
  4 align-data
  dhere over dict-entry-data uint32!
  drop
;

: does-col
  out-dict does-col/1
;

: defcol-cb
  cross-lookup
  dup LOOKUP-INT equals
  IF drop ,uint32
  ELSE
    dup LOOKUP-STRING equals
    IF drop ,byte-string
    ELSE
      LOOKUP-NOT-FOUND equals
      IF not-found drop
      ELSE ,op
      THEN
    THEN
  THEN
  1 +
;

: defcol-state-fn
  over literalizes? UNLESS
    number? IF ' int32 swap THEN
  THEN
;

: defcol-read
  literal out_immediates set-compiling-immediates
  ' defcol-state-fn set-compiling-state
  read-terminator compiling-read
  here down-stack 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: defcol
  next-token create does-col
  defcol-read
  out' exit ,op
;

: endcol
  0 set-compiling
; out-immediate

( Word aliases: )

: does-defalias
  cross-lookup LOOKUP-WORD equals IF
    dup dict-entry-code uint32@ out-dict dict-entry-code uint32! 
    dup dict-entry-data uint32@ out-dict dict-entry-data uint32!
  ELSE
    " Warning: bad alias" error-line
  THEN
  drop
;
  
: defalias>
  next-token create next-token does-defalias
;

( Constants: )

: defconst
  create
  out' do-const dict-entry-size + out-dict dict-entry-code uint32!
  out-dict dict-entry-data uint32!
;

: defconst>
  next-token defconst
;

( Constants whose data is a CS offset: )

: defconst-offset
  create
  out' do-const-offset dict-entry-size + out-dict dict-entry-code uint32!
  out-dict dict-entry-data uint32!
;

: defconst-offset>
  next-token defconst-offset
;

( Constants with string values: )

: string-const>
  dhere swap
  ,byte-string 4 pad-data defconst-offset>
;

( Variables: )

: defvar
  create
  out' do-var dict-entry-size + out-dict dict-entry-code uint32!
  out-dict dict-entry-data uint32!
;

: defvar>
  next-token defvar
;

( Cell & Op Constants: )

cell-size defconst> cell-size
-op-size defconst> op-size
-op-mask defconst> op-mask

( Math aliases: )

defalias> + int-add
defalias> - int-sub
defalias> * int-mul
defalias> / int-div

( Debug helpers: )

defcol break
  int32 0x47 peek
endcol
