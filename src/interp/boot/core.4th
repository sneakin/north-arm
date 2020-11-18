( Todo To load the assembler: With create builtin, need a compiling-read and colon defining words. )
tmp" Loading core words..." error-line/2

return-stack peek UNLESS
  256 proper-init
  tmp" Initialized return stack" error-line/2
THEN

dhere UNLESS
  64 1024 * data-init-stack
  tmp" Initialized data stack" error-line/2
THEN

def dict-drop
  dict dict-entry-link peek cs +
  set-dict
end

def alias
  arg1 dict-entry-code peek arg0 dict-entry-code poke
  arg1 dict-entry-data peek arg0 dict-entry-data poke
end

def alias>
  create>
  ['] dup 12 unless-jump swap alias exit-frame
  not-found enl dict-drop return0
end

( create> : ' defproper swap alias )
alias> return0 return
alias> return proper-exit
alias> equals equals?
alias> speek peek
alias> spoke poke
alias> mult int-mul

def does-const
  pointer do-const dict-entry-code peek arg0 dict-entry-code poke
  ( return0 )
end

def const>
  create> does-const
  arg0 over dict-entry-data poke
  exit-frame
end

def does-const-offset
  pointer do-const-offset dict-entry-code peek arg0 dict-entry-code poke
  return0
end

def symbol>
  create> does-const
  dup dict-entry-data poke
  exit-frame
end

def does-var
  pointer do-var dict-entry-code peek arg0 dict-entry-code poke
  return0
end

def var>
  create> does-var
  args peek over dict-entry-data poke
  exit-frame
end

def immediate/1
  arg0 copy-dict-entry
  immediates peek over dict-entry-link poke
  cs - immediates poke
  compiling-init
  exit-frame
end

def immediate
  dict immediate/1
  exit-frame
end

def immediate-as/1
  arg0 immediate/1
  next-token allot-byte-string/2
  IF
    cs -
    immediates peek cs + dict-entry-name poke
    exit-frame
  ELSE return0
  THEN
end

def immediate-as
  dict immediate-as/1
  exit-frame
end

defcol ''
  literal literal swap
  ['] swap
end immediate-as '

defcol ememdump
  rot swap
  current-output peek
  standard-error current-output poke
  rot swap memdump
  current-output poke
endcol

def .s
  args int32 96 ememdump return0
end immediate-as [.s]

defcol jump-data
  drop
  dict-entry-data peek jump-cs
end

: loop
  literal int32 dict
  literal jump-data
; immediate

def shift ( a b c -- c a b )
  arg0
  arg1 set-arg0
  arg2 set-arg1
  set-arg2
  return0
end

def roll ( a b c -- b c a )
  arg0
  arg2 set-arg0
  arg1 set-arg2
  set-arg1
  return0
end

: down-stack/2 cell-size * - ;
: down-stack int32 1 down-stack/2 ;

: up-stack/2 cell-size * + ;
: up-stack int32 1 up-stack/2 ;

defcol stack-delta
  rot swap
  - cell/
  swap
end

: stack-find/2
  2dup speek equals int32 3 op-size * unless-jump swap drop proper-exit
  up-stack
  dup int32 0 equals int32 1 op-size * unless-jump proper-exit
  loop
;

: stack-find
  here int32 2 up-stack/2 stack-find/2
;

symbol> if-placeholder

: IF
  literal int32 if-placeholder
  literal unless-jump
; immediate

: UNLESS
  literal int32 if-placeholder
  literal if-jump
; immediate

: ELSE
  literal int32
  if-placeholder stack-find
  if-placeholder literal jump-rel
  roll
  dup here stack-delta int32 3 - op-size *
  swap spoke
; immediate

: THEN
  if-placeholder stack-find
  dup here stack-delta int32 3 - op-size *
  swap spoke
; immediate

def alias>
  create>
  ['] dup IF swap alias exit-frame
  ELSE not-found enl dict-drop return0
  THEN
end

: minmax 2dup int> IF swap THEN ;
: min minmax drop ;
: max minmax swap drop ;

: repeat-frame
  literal int32
  ( fixme may not have a begin-frame to find. )
  literal begin-frame stack-find
  current-frame min
  here stack-delta 1 + op-size * negate
  literal jump-rel
; immediate

def POSTPONE
  next-token compile-token
  ( todo adjust words by cs )
  negative? IF not-found enl int32 0 return1
  ELSE
    ( TOKEN-INT equals? UNLESS cs - THEN )
    drop return1
  THEN
end immediate

def "
  POSTPONE c" drop here
  exit-frame
end

defcol pad-addr ( addr alignment )
  rot swap
  2dup + over / over *
  rot 2 dropn
  swap
end

def d"
  POSTPONE c"
  here up-stack dhere 3 overn copy-byte-string/3 3 dropn
  dhere dup 3 overn + cell-size pad-addr dmove
  return1
end immediate

def s"
  POSTPONE c"
  here up-stack dhere 3 overn copy-byte-string/3 3 dropn
  dhere dup 3 overn + cell-size pad-addr dmove
  swap return2
end

defcol [s"]
  literal literal swap
  s" ( ra ptr len )
  swap rot ( ptr len ra )
  literal int32 rot swap
endcol immediate-as s"

def ["]
  literal literal
  POSTPONE d" return2
end immediate-as "

def does>
  arg0 next-token interp-token negative?
  IF not-found
  ELSE drop does
  THEN
  return0
end

def copies-entry-as ( link source-entry new-name )
  arg1 copy-dict-entry
  arg0 cs - over dict-entry-name poke
  arg2 dup IF cs - THEN over dict-entry-link poke
  exit-frame
end

def copy-as> ( link src-entry -- new-entry )
  next-token negative?
  IF error 0 return1
  ELSE allot-byte-string/2 drop arg1 swap arg0 swap copies-entry-as exit-frame
  THEN
end

def error
  " Error" error-line
end

symbol> read-terminator

alias> endcol end-compile
op-size const> -op-size ( todo  needs to be variable )
op-mask const> -op-mask

def top-frame-loop
  arg0 parent-frame dup IF set-arg0 repeat-frame THEN
  return0
end

0 var> -top-frame

def top-frame
  -top-frame peek
  dup UNLESS
    drop current-frame top-frame-loop
    dup -top-frame poke
  THEN return1
end

def argc
  top-frame farg1 peek return1
end

def argv
  top-frame farg2 return1
end

def argv/1
  argv cell-size arg0 * +
  dup IF peek ELSE 0 THEN return1
end

def env
  top-frame frame-args cell-size 3 argc + arg0 + * +
  dup IF peek ELSE 0 THEN return1
end

def fill-seq ( seq n value )
  arg1 0 int> UNLESS return0 THEN
  arg1 1 - set-arg1
  arg0 arg2 arg1 seq-poke
  repeat-frame
end

def stack-allot-zero
  arg0 stack-allot
  dup arg0 cell/ 0 fill-seq 3 dropn
  exit-frame
end

def stack-allot-zero-seq
  arg0 cell-size * stack-allot-zero
  exit-frame
end

def safe-stack-find/2 ( ptr value -- addr found )
  arg1 top-frame uint< UNLESS 0 set-arg0 return0 THEN
  arg1 peek arg0 equals? IF 1 set-arg0 return0 THEN
  arg1 up-stack set-arg1 repeat-frame
end

def tab 9 write-byte end

defcol write-tabbed-hex-uint
  swap dup write-hex-uint tab
  0x10000 uint< IF tab THEN
endcol

: ,byte-string/3
  ( string length n )
  2dup equals IF 0 dpush-byte return THEN
  3 overn 2 overn string-peek dpush-byte
  1 + loop
;

: ,byte-string
  dup string-length 0 ,byte-string/3
  3 dropn
;
