: make-label
  " op-" ++ make-const
;

0 var> dict
4 const> cell-size
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
  op-do-col dict dict-entry-code uint32!
  4 align-data
  dhere dict dict-entry-data uint32!
;

: defcol
  next-token create does-col
  ( ' cross-dict compiling-read )
;

: endcol
  0 ,uint16
  4 align-data
; immediate
