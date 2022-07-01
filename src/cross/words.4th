( Bash output word functions )

" op-" const> -op-prefix

: make-label
  -op-prefix ++ make-const
;

( Output addresses: )

0 var> out-origin

: to-out-addr out-origin - ;
: from-out-addr out-origin + ;

( The output dictionary: )

0 var> out-dict

: dict-entry-size cell-size 4 mult ;
: dict-entry-name ;
: dict-entry-code cell-size + ;
: dict-entry-data cell-size 2 mult + ;

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

( Dictionary words for output: )

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
  dup make-dict-entry dup error-hex-uint enl
  dup rot make-label
  dup set-out-dict
;

: create> next-token create ;

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

: copies-entry-as>
  next-token copies-entry-as
;

: literalizes?
  dup ' int32 equals
  swap dup ' literal equals
  swap dup ' pointer equals
  swap dup ' offset32 equals
  swap ' uint32 equals
  logior logior logior logior
;
