( Bash output word functions )

( todo would better match boot/cross by adding an out-origin )

" op-" const> -op-prefix

: make-label
  -op-prefix ++ make-const
;

( Output addresses: )

0 var> out-origin

: to-out-addr out-origin - ;
: from-out-addr out-origin + ;

: align-code ( alignment -- )
  dhere to-out-addr swap pad-addr from-out-addr
  dhere over over - cell-size / 0 fill-seq
  dmove
;

: ,seq-pointer/3 ( seq size n -- )
  2dup int> IF
    3 overn over seq-peek ,h espace
    dup IF to-out-addr THEN ,h enl
    over cell-size * dhere + uint32!
    1 + loop
  ELSE drop
       cell-size *
       dhere 2dup + dmove
       shift 2 dropn
  THEN
;

: ,seq-pointer ( seq n -- )
  0 ,seq-pointer/3
;

( The output dictionary: )

0 var> out-dict

: dict-entry-size cell-size 4 mult ;
: dict-entry-name ;
: dict-entry-code cell-size + ;
: dict-entry-data cell-size 2 mult + ;
: dict-entry-link cell-size 3 mult + ;

( Iteration: )

def dict-map/4 ( dict origin state fn )
  arg3 data-null? UNLESS
    arg1 arg3 arg0 exec set-arg1
    arg3 dict-entry-link uint32@ data-null? UNLESS
      arg2 + set-arg3
      repeat-frame
    ELSE drop
    THEN
  ELSE drop
  THEN arg1 exit-frame
end

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

: make-dict-entry-with-interned-name/4 ( link data code name -- data-pointer )
  4 align-data
  dhere
  swap ,uint32
  swap ,uint32
  swap ,uint32
  swap ,uint32
;

: make-dict-entry/4 ( link data code name -- data-pointer )
  dhere swap ,byte-string make-dict-entry-with-interned-name/4
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

: does ( word code-word -- word )
  dict-entry-code uint32@ swap dict-entry-code uint32!
;

: copies-entry ( link source-entry )
  dup dict-entry-data uint32@
  swap dup dict-entry-code uint32@
  swap dict-entry-name uint32@
  make-dict-entry-with-interned-name/4
;

: copies-entry-as ( link source-entry new-name )
  dhere swap ,byte-string
  rot swap copies-entry
  swap over dict-entry-name uint32!
;

: copies-entry-as>
  next-token copies-entry-as
;

: drop-out-dict
  out-dict dict-entry-link uint32@ from-out-addr set-out-dict
;

: literalizes?
  CASE
    ' literal OF true ENDOF
    ' pointer OF true ENDOF
    ' int32 OF true ENDOF
    ' uint32 OF true ENDOF
    ' string OF true ENDOF
    ' cstring OF true ENDOF
    ' offset32 OF true ENDOF
    ' uint64 OF true ENDOF
    ' int64 OF true ENDOF
    ' float32 OF true ENDOF
    ' float64 OF true ENDOF
    drop false
  ENDCASE
;

: oword-printer ( state word -- new-state )
  dict-entry-name uint32@ from-out-addr byte-string@ error-string/2 espace
  1 +
;

: owords
  out-dict out-origin 0 ' oword-printer dict-map/4 enl
  5 + dropn
;
