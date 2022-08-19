( Todo To load the assembler: With create builtin, need a compiling-read and colon defining words. )
tmp" Loading core words..." error-line/2

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
  not-found enl dict-drop return
end

( todo necessary? bash loadable... )
alias> return0 return
alias> return proper-exit
alias> equals equals?
alias> speek peek
alias> spoke poke
alias> mult int-mul

def does-const
  arg0 pointer do-const does
end

def const>
  create> does-const
  arg0 over dict-entry-data poke
  exit-frame
end

alias> string-const> const>

def does-const-offset
  arg0 pointer do-const-offset does
end

def symbol>
  create> does-const
  dup dict-entry-data poke
  exit-frame
end

def does-var
  arg0 pointer do-var does
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

defcol jump-data
  drop
  dict-entry-data peek jump-cs
end

: loop
  literal int32 dict
  literal jump-data
; immediate

: stack-find/2
  2dup speek equals int32 3 op-size * unless-jump swap drop proper-exit
  up-stack loop
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

def ememdump/3
  current-output peek
  standard-error current-output poke
  arg2 arg1 arg0 exec-abs
  current-output poke
endcol

defcol ememdump
  rot swap pointer memdump ememdump/3
  3 dropn
endcol

defcol ecmemdump
  rot swap pointer cmemdump ememdump/3
  3 dropn
endcol

def .s
  args int32 96 ecmemdump
end immediate-as [.s]

defcol ?exec-abs
  swap dup IF ( exec-abs ) jump-data ELSE drop THEN
endcol

def alias>
  create>
  ['] dup IF swap alias exit-frame
  ELSE not-found enl dict-drop return0
  THEN
end

: repeat-frame
  literal int32
  ( fixme may not have a begin-frame to find. )
  literal begin-frame stack-find
  current-frame min
  here stack-delta 1 + op-size * negate
  literal jump-rel
; immediate

def POSTPONE
  next-token 2dup compile-token
  negative? IF 2 dropn not-found/2 int32 0
  ELSE drop
  THEN return1
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

( alias> string literal )

' string [IF] ( todo remove the condition once rebuilt )
  defcol [s"]
    literal string swap
    POSTPONE s" ( ra ptr len )
    swap rot ( ptr len ra )
    literal int32 rot swap
  endcol immediate-as s"

  def ["]
    literal string
    POSTPONE d" return2
  end immediate-as "

[ELSE]
  defcol [s"]
    literal literal swap
    POSTPONE s" ( ra ptr len )
    swap rot ( ptr len ra )
    literal int32 rot swap
  endcol immediate-as s"

  def ["]
    literal literal
    POSTPONE d" return2
  end immediate-as "
[THEN]

: ."
  [s"] literal write-string/2
; immediate

def ."
  POSTPONE tmp" write-string/2
end

def error
  s" Error" error-line/2
end

def does>
  arg0 next-token interp-token negative?
  IF not-found
  ELSE drop does
  THEN
  return0
end immediate

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

symbol> read-terminator

alias> endcol end-compile
op-size const> -op-size ( todo  needs to be variable )
op-mask const> -op-mask

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

NORTH-BUILD-TIME 1634096442 uint<= [IF]
def defined?/2
  arg1 arg0 dict dict-lookup 2 return1-n
end
[THEN]
