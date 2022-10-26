( todo adjust output dictionary and pointers by out-offset; or make dhere, dpoke, dpeek offset? )

tmp" Loading cross compiling words..." error-line/2

alias> exec-cs exec
alias> exec exec-abs
0 var> cross-immediates

alias> cstring-length string-length
alias> cstring-peek string-peek

def cross-immediate/1 ( word )
  arg0 copy-dict-entry
  cross-immediates peek over dict-entry-link poke
  dup cs - cross-immediates poke
  exit-frame
end

def cross-immediate/3 ( src-word name name-length )
  0
  arg2 cross-immediate/1 set-local0
  arg1 arg0 allot-byte-string/2 drop cs -
  local0 dict-entry-name poke
  local0 exit-frame
end

: cross-immediate/2 ( src-word name )
  dup cstring-length cross-immediate/3
;

: cross-immediate dict cross-immediate/1 ;
: cross-immediate-as dict next-token cross-immediate/3 ;

' end-compile tmp" ;" cross-immediate/3

' ( cross-immediate/1

( Output memory offseting: )

dhere var> out-origin

: to-out-addr out-origin peek - ;
: from-out-addr out-origin peek + ;

( fixme duplicated in cross/words.4th )
( todo zero unused memory? )
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

0 var> output-immediates
0 var> out-dictionary

defcol out-dict out-dictionary peek swap endcol

def out-dict-lookup  ( ptr length dict-entry -- dict-entry found? )
  arg1 arg0 out-dictionary peek out-origin peek dict-lookup/4
  set-arg0 set-arg1
end

( Output dictionary lookups: )

0 const> LOOKUP-NOT-FOUND
1 const> LOOKUP-WORD
2 const> LOOKUP-INT
3 const> LOOKUP-STRING
4 const> LOOKUP-IMMED

def cross-lookup
  arg1 arg0 parse-int
  IF LOOKUP-INT
  ELSE drop arg1 arg0 out-dict-lookup IF LOOKUP-WORD ELSE LOOKUP-NOT-FOUND THEN THEN
  THEN set-arg0 set-arg1 return0
end

def cross-lookup-offset
  arg1 arg0 cross-lookup
  negative? UNLESS swap to-out-addr swap THEN
  set-arg0 set-arg1
end

: cross-lookup-or-break/3 ( str length lookup-fn -- lookup )
  2 overn 4 overn rot exec LOOKUP-NOT-FOUND equals IF
    drop not-found/2
    s" break" cross-lookup drop
  ELSE
    2 swapn 2 dropn
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
  2dup error-line/2
  drop make-dict-entry dup to-out-addr error-hex-uint enl
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

( Output quote: )

def dallot-next-token
  next-token dup 0 int> IF
    over dhere 3 overn copy-byte-string/3 3 dropn
    dhere dup 3 overn + cell-size pad-addr dmove
    swap
  ELSE 0 0
  THEN return2
end

: dallot-next-token>
  literal literal
  dallot-next-token
  literal int32 swap
; immediate

( There's out' and out-off' which return the next token's output
address and relative offset. )

: out'
  ( Returns the address of the next token's output word. )
  next-token cross-lookup-or-break
; immediate-as [out']

: out''
  ( The immediate ~out'~ that delays the lookup of the next token until the containing definition is called. The output word's address will be on the stack. )
  POSTPONE dallot-next-token>
  literal cross-lookup-or-break
; immediate-as out'

: out-off'
  ( Returns the offset of the outuut word named by the next token. Doubles as POSTPONE when cross compiling. )
  next-token cross-lookup-offset-or-break
; immediate-as [out-off'] cross-immediate-as POSTPONE

( fixme POSTPONE needs immediate lookup, but immediate support in the output is needed. )

( fixme word ends up in the binary. )
: out-out-off'
  ( The immediate ~out-off'~ that delays the lookup of the next token until the containing definition is called. The output word's offset will be on the stack. )
  POSTPONE dallot-next-token>
  literal cross-lookup-offset-or-break
; immediate-as out-off'

: out-'
  ( Quote for output definitions. Uses the output dictionary. )
  out-off' pointer
  POSTPONE [out-off']
; cross-immediate-as '

( String readers: )

: out-dq-string
  ( Read until a double quote, writing the contained data to the data stack and leaving a literal and length on the stack for a definition. )
  POSTPONE d"
  out-off' cstring
  swap to-out-addr
  dhere to-out-addr out-dict dict-entry-data poke
; cross-immediate-as "

: out-dq-stringn
  ( Read until a double quote, writing the contained data to the data stack and leaving a literal and length on the stack for a definition. )
  POSTPONE d"
  out-off' cstring
  swap dup to-out-addr swap cstring-length
  out-off' int32 swap
  dhere to-out-addr out-dict dict-entry-data poke
; cross-immediate-as s"

( Output dictionary listings: )

def oword-printer
  arg0 dict-entry-name peek from-out-addr write-string space
  arg1 1 + set-arg0
end

def ciwords
  cross-immediates peek dup IF cs + ' words-printer dict-map THEN
end

def owords
  out-dict out-origin peek 0 ' oword-printer dict-map/4
end

def oiwords
  output-immediates @ out-origin peek 0 ' oword-printer dict-map/4
end
