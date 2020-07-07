: make-label
  " op-" ++ make-const
;

: rel-addr
  dhere -
;

0 var> dict
4 const> cell-size
r6 const> cs
r7 const> eip

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
  next-token
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
  create does-code
;

: endop
  0 ,uint16
  4 align-data
; immediate

: does-col
  4 align-data
  op-do-col dict dict-entry-code uint32!
  dhere dict dict-entry-data uint32!
;

: defcol
  create does-col
;

: endcol
  0 ,uint16
  4 align-data
; immediate
