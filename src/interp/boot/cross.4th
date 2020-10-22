( todo adjust output dictionary and pointers by out-offset; or make dhere, dpoke, dpeek offset? )

alias> exec-cs exec
alias> exec exec-abs
0 var> out-immediates

def out-immediate/1 ( word )
  arg0 copy-dict-entry
  out-immediates peek over dict-entry-link poke
  dup cs - out-immediates poke
  exit-frame
end

def out-immediate/3 ( src-word name name-length )
  0
  arg2 out-immediate/1 set-local0
  arg1 arg0 allot-byte-string/2 drop cs -
  local0 dict-entry-name poke
  local0 exit-frame
end

: out-immediate/2 ( src-word name )
  cstring-length out-immediate/3
;

: out-immediate dict out-immediate/1 ;
: out-immediate-as dict next-token out-immediate/3 ;

' end-compile tmp" ;" out-immediate/3

' ( out-immediate/1
' POSTPONE out-immediate/1
' s" out-immediate

( The output dictionary: )

dhere var> out-origin
0 var> out-dictionary

defcol out-dict out-dictionary peek swap endcol

def out-dict-lookup  ( ptr length dict-entry ++ found? )
  arg2 arg1 arg0 out-origin peek dict-lookup/4
  over set-arg0
  return1
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
  ELSE drop arg1 arg0 out-dictionary peek out-dict-lookup IF LOOKUP-WORD ELSE LOOKUP-NOT-FOUND THEN
  THEN set-arg0 set-arg1 return0
end

def cross-lookup-offset
  arg1 arg0 cross-lookup
  negative? UNLESS swap out-origin peek - swap THEN
  set-arg0 set-arg1
end

( Dictionary words for output: )

: ,byte-string/3
  ( string length n )
  2dup equals IF 0 ,uint8 return THEN
  3 overn 2 overn cstring-peek ,uint8
  1 + loop
;

: ,byte-string
  dup cstring-length 0 ,byte-string/3
  3 dropn
;

: make-dict-entry/4 ( link data code name -- data-pointer )
  dhere swap ,byte-string
  4 align-data
  dhere
  swap out-origin peek - ,uint32
  swap out-origin peek - ,uint32
  swap ,uint32
  swap out-origin peek - ,uint32
;

: make-dict-entry ( name )
  out-dictionary peek swap 0 swap 0 swap make-dict-entry/4
;

: create ( ptr length -- )
  2dup error-line/2
  drop make-dict-entry ( ,,h )
  dup out-dictionary poke
;

: create> next-token create ;

: copies-entry ( link source-entry )
  dup dict-entry-data uint32@
  swap dup dict-entry-code uint32@ out-origin peek +
  swap dict-entry-name uint32@ out-origin peek +
  make-dict-entry/4
;

: copies-entry-as ( link source-entry new-name )
  dhere swap ,byte-string
  rot swap copies-entry
  swap over dict-entry-name out-origin peek - uint32!
;

( Output quote: )

: out'
  next-token cross-lookup LOOKUP-NOT-FOUND equals IF
    not-found
  THEN
;

: out-off'
  POSTPONE out' out-origin peek -
; out-immediate-as [']

: out''
  s" literal" cross-lookup-offset UNLESS not-found THEN
  POSTPONE out-off'
; out-immediate-as '

: [out'']
  literal literal
  POSTPONE out'
; immediate-as out'

: out-dq-string
  ( Read until a double quote, writing the contained data to the data stack and leaving a literal and length on the stack for a definition. )
  POSTPONE d"
  s" pointer" cross-lookup-offset UNLESS not-found drop int32 0 THEN swap ( todo pointer or segment offset )
  dup out-origin peek - swap cstring-length
  s" int32" cross-lookup-offset UNLESS not-found drop int32 0 THEN swap
; out-immediate-as "

def oword-printer
  arg0 dict-entry-name peek out-origin peek + write-string space
end

def owords
  out-dict out-origin peek 0 ' oword-printer dict-map/4
end

def oiwords
  out-immediates peek cs + ' words-printer dict-map
end
