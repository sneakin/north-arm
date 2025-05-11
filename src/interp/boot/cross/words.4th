( The output dictionary: )

0 var> output-immediates
0 var> out-dictionary

defcol out-dict out-dictionary peek swap endcol

def out-dict-lookup  ( ptr length -- dict-entry found? )
  arg1 arg0 out-dictionary peek out-origin peek dict-lookup/4
  set-arg0 set-arg1
end

: OUT:DEFINED?
  next-token out-dict-lookup swap drop
;


( Output dictionary lookups: )

0 const> LOOKUP-NOT-FOUND
1 const> LOOKUP-WORD
2 const> LOOKUP-INT
3 const> LOOKUP-STRING
4 const> LOOKUP-IMMED

def cross-lookup
  arg1 arg0 parse-int
  IF LOOKUP-INT
  ELSE drop arg1 arg0 out-dict-lookup
       IF LOOKUP-WORD ELSE LOOKUP-NOT-FOUND THEN
  THEN set-arg0 set-arg1 return0
end

def cross-lookup-offset
  arg1 arg0 cross-lookup
  negative? UNLESS swap to-out-addr swap THEN
  set-arg0 set-arg1
end

: cross-lookup-or-break/3 ( str length lookup-fn -- lookup )
  3 overn 3 overn 3 overn exec-abs LOOKUP-NOT-FOUND equals? IF
    drop shift not-found/2
    s" break" 2dup 5 overn exec-abs
    LOOKUP-NOT-FOUND equals? IF shift not-found/2 ELSE shift 2 dropn THEN
    swap drop
  ELSE 3 set-overn 2 dropn
  THEN
;

: cross-lookup-or-break ' cross-lookup cross-lookup-or-break/3 ;
: cross-lookup-offset-or-break ' cross-lookup-offset cross-lookup-or-break/3 ;

( Dictionary words for output: )

: make-dict-entry/4 ( link data code name -- pointer )
  dhere swap ,byte-string
  4 align-data
  dhere
  swap to-out-addr ,uint32
  swap to-out-addr ,uint32
  swap ,uint32
  swap dup IF to-out-addr THEN ,uint32
;

: make-dict-entry ( name )
  out-dictionary peek swap 0 swap 0 swap make-dict-entry/4
;

: create ( ptr length -- entry )
  INTERP-LOG-WORDS interp-logs? IF 2dup error-line/2 THEN
  drop make-dict-entry
  INTERP-LOG-WORDS interp-logs? IF dup to-out-addr error-hex-uint enl THEN
  dup out-dictionary poke
;

: create> next-token create ;

: copies-entry ( link source-entry )
  dup dict-entry-data uint32@
  swap dup dict-entry-code uint32@ from-out-addr
  swap dict-entry-name uint32@ from-out-addr
  make-dict-entry/4
;

: copies-entry-as ( link source-entry new-name )
  dhere swap ,byte-string
  rot swap copies-entry
  swap to-out-addr over dict-entry-name uint32!
;

: copies-entry-as> ( link src-entry -- new-entry )
  next-token negative?
  IF error 2 dropn
  ELSE drop copies-entry-as
  THEN
;

: drop-out-dict
  out-dictionary peek dict-entry-link peek from-out-addr out-dictionary poke
;
