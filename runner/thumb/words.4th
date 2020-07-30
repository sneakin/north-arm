" op-" const> -op-prefix

: make-label
  -op-prefix ++ make-const
;

0 var> dict

r4 const> fp
r5 const> dict-reg
r6 const> cs
r7 const> eip

: rel-addr
  dhere -
;

: dict-entry-size cell-size 4 mult ;
: dict-entry-code cell-size + ;
: dict-entry-data cell-size 2 mult + ;

: make-dict-entry
  dhere swap ,byte-string
  4 align-data
  dhere swap ,uint32
  0 ,uint32
  0 ,uint32
  dict ,uint32
;

: create
  dup error-line
  dup make-dict-entry ,,h
  dup rot make-label
  set-dict
;

: does-code
  4 align-data
  dhere dict dict-entry-code uint32!
;

: defop
  next-token create does-code
;

: endop
  0 ,uint16
  4 align-data
; immediate

: does-col/1
  op-do-col dict-entry-code uint32@ over dict-entry-code uint32!
  4 align-data
  dhere over dict-entry-data uint32!
  drop
;

: does-col
  dict does-col/1
;

0 const> LOOKUP-NOT-FOUND
1 const> LOOKUP-WORD
2 const> LOOKUP-INT
3 const> LOOKUP-STRING
4 const> LOOKUP-IMMED

: cross-lookup
  dup " op-" ++
  dup get-word null? IF
    drop
    over number? IF
      2 dropn LOOKUP-INT return
    ELSE
      " Warning: " ++ error-line
      drop LOOKUP-NOT-FOUND return
    THEN
  THEN
  drop swap drop exec LOOKUP-WORD
;

: op@
  -op-size 2 equals IF uint16@ ELSE uint32@ THEN
;

: ,op
  -op-size 2 equals IF ,uint16 ELSE ,uint32 THEN
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
      IF drop op-break ,op
      ELSE ,op
      THEN
    THEN
  THEN
  1 +
;

: literalizes?
  dup ' int32 equals
  swap dup ' literal equals
  swap dup ' pointer equals
  swap dup ' offset32 equals
  swap ' uint32 equals
  logior logior logior logior
;

: defcol-state-fn
  over literalizes? UNLESS
    number? IF ' int32 swap THEN
  THEN
;

: defcol-read
  ' defcol-state-fn set-compiling-state
  literal out_immediates compiling-read/1
  here down-stack 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: defcol
  next-token create does-col
  defcol-read
  op-exit ,op
;

: endcol
  0 set-compiling
; out-immediate

: does-defalias
  cross-lookup LOOKUP-WORD equals IF
    dup dict-entry-code uint32@ dict dict-entry-code uint32! 
    dup dict-entry-data uint32@ dict dict-entry-data uint32!
  ELSE
    " Warning: bad alias" error-line
  THEN
  drop
;
  
: defalias>
  next-token create next-token does-defalias
;
