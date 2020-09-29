( Output word access: )

" op-" const> -op-prefix

: make-label
  -op-prefix ++ make-const
;

( The output dictionary: )

0 var> out-dict

: rel-addr
  dhere -
;

( Dictionary words for output: )

: dict-entry-size cell-size 4 mult ;
: dict-entry-name ;
: dict-entry-code cell-size + ;
: dict-entry-data cell-size 2 mult + ;

: make-dict-entry/4 ( link data code name -- data-pointer )
  dhere swap ,byte-string
  4 align-data
  dhere
  swap ,uint32
  swap ,uint32
  swap ,uint32
  swap ,uint32
;

: make-dict-entry ( name )
  out-dict swap 0 swap 0 swap make-dict-entry/4
;

: create
  dup error-line
  dup make-dict-entry ,,h
  dup rot make-label
  set-out-dict
;

: copies-entry ( link source-entry )
  dup dict-entry-data uint32@
  swap dup dict-entry-code uint32@
  swap dict-entry-name uint32@
  make-dict-entry/4
;

: copies-entry-as ( link source-entry new-name )
  dhere swap ,byte-string
  rot swap copies-entry
  swap over dict-entry-name uint32!
;

( Output dictionary lookups: )

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

: out'
  next-token cross-lookup LOOKUP-NOT-FOUND equals IF
    not-found
  THEN
; out-immediate-as [']

: out''
  literal literal
  out'
; out-immediate-as '

' out'' ' out' immediate/2

: literalizes?
  dup ' int32 equals
  swap dup ' literal equals
  swap dup ' pointer equals
  swap dup ' offset32 equals
  swap ' uint32 equals
  logior logior logior logior
;

( Op definitions: )

: does-code
  4 align-data
  dhere out-dict dict-entry-code uint32!
;

: defop
  next-token create does-code
;

: endop
  0 ,uint16
  4 align-data
; immediate

: op@
  -op-size 2 equals IF uint16@ ELSE uint32@ THEN
;

: ,op
  -op-size 2 equals IF ,uint16 ELSE ,uint32 THEN
;
