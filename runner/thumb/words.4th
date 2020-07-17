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

: does-col
  op-do-col dict-entry-size + dict dict-entry-code uint32!
  4 align-data
  dhere dict dict-entry-data uint32!
;

: cross-lookup
  dup " op-" ++
  dup get-word null? IF
    over number? IF drop ELSE " Warning: " ++ error-line THEN
    2 dropn return
  THEN
  drop swap drop exec
;

: ,op
  -op-size 2 equals IF ,uint16 ELSE ,uint32 THEN
;

: defcol-cb
  cross-lookup number? IF ,op ELSE ,byte-string THEN
  1 +
;

: defcol-read
  literal out_immediates compiling-read/1 here 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
  op-exit ,op
;

: defcol
  next-token create does-col defcol-read
;

: endcol
  0 set-compiling
; out-immediate
