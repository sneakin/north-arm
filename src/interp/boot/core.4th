( Todo To load the assembler: With create builtin, need a compiling-read and colon defining words. )
tmp" Loading core words..." error-line/2

def dict-drop
  dict dict-entry-link peek cs +
  set-dict
end

def does-const
  arg0 pointer do-const does
end

def const>
  create> does-const
  arg0 over dict-entry-data poke
  exit-frame
end

NORTH-BUILD-TIME 1704950389 int>
' NORTH-COMPILE-TIME defined?
or [IF] 1 [ELSE] op-size [THEN] const> jump-op-size

def alias
  arg1 dict-entry-code peek arg0 dict-entry-code poke
  arg1 dict-entry-data peek arg0 dict-entry-data poke
end

def alias>
  create>
  ['] dup 3 jump-op-size * unless-jump swap alias exit-frame
  not-found enl dict-drop
end

( todo necessary? bash loadable... )
' return0 [UNLESS]
  alias> return0 return
[THEN]
alias> return proper-exit
alias> equals equals?
alias> speek peek
alias> spoke poke
alias> mult int-mul
alias> sys' '

alias> string-const> const>

def does-const-offset
  arg0 pointer do-const-offset does
end

def symbol>
  create> does-const
  dup dict-entry-data poke
  exit-frame
end

def immediate/1
  arg0 copy-dict-entry
  immediates peek over dict-entry-link poke
  cs - immediates poke
  compiling-init
  exit-frame
end

def immediate/2
  arg0 immediate/1
  arg1 cs - immediates peek cs + dict-entry-name poke
  exit-frame
end

def immediate
  dict immediate/1
  exit-frame
end

( fixme necessary? )
defcol jump-data
  drop
  dict-entry-data peek jump-cs
end

: loop
  literal literal dict
  literal jump-data
; immediate

: stack-find/3 ( value top current -- ptr true | false )
  2dup uint> int32 6 jump-op-size * if-jump int32 3 dropn int32 0 proper-exit
  int32 3 overn over speek equals? int32 7 jump-op-size * unless-jump rot int32 2 dropn int32 -1 proper-exit
  up-stack loop
;

: stack-find/2 ( value top -- ptr true | false )
  here int32 3 up-stack/2 stack-find/3
;

: stack-find ( value -- ptr true | false )
  top-frame here int32 3 up-stack/2 stack-find/3
;

def immediate-as/1
  next-token allot-byte-string/2
  jump-op-size if-jump return0
  arg0 immediate/2
  exit-frame
end

def immediate-as
  dict immediate-as/1
  exit-frame
end

symbol> if-placeholder

: interp-IF
  literal int32 if-placeholder
  literal unless-jump
; immediate-as IF

: interp-UNLESS
  literal int32 if-placeholder
  literal if-jump
; immediate-as UNLESS

: interp-ELSE
  literal int32
  if-placeholder stack-find int32 2 jump-op-size * if-jump int32 0
  if-placeholder literal jump-rel
  roll
  dup here stack-delta int32 3 - jump-op-size *
  swap spoke
; immediate-as ELSE

: interp-THEN
  if-placeholder stack-find int32 2 jump-op-size * if-jump int32 0
  dup here stack-delta int32 3 - jump-op-size *
  swap spoke
; immediate-as THEN

defcol ''
  literal pointer swap
  ['] cs - swap
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

def colon?
  arg0 dict-entry-code @ ' does-col dict-entry-code @ equals? return1
end

defcol ?jump-data
  swap dup IF jump-data ELSE drop THEN
endcol

' umin defined? [UNLESS]
  defcol uminmax rot 2dup uint< IF swap THEN rot endcol
  defcol umin rot uminmax drop swap endcol
[THEN]

: repeat-frame
  literal int32
  ( compiling-read sets up a frame that holds the accumulated list of words.
    This needs to calculate a jump to after the nearest begin-frame. )
  literal begin-frame locals stack-find/2 IF locals umin ELSE locals THEN
  here stack-delta negate 2 - jump-op-size *
  literal jump-rel
; immediate

: repeat-word
  literal int32
  ( compiling-read sets up a frame that holds the accumulated list of words.
    This needs to calculate a jump to after the begin-frame. )
  locals here stack-delta negate 2 - jump-op-size *
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

def safe-stack-find/2 ( ptr value -- addr true | false )
  arg1 top-frame uint< UNLESS 0 2 return1-n THEN
  arg1 peek arg0 equals? IF arg1 -1 2 return2-n THEN
  arg1 up-stack set-arg1 repeat-frame
end

def tab 9 write-byte end

defcol write-tabbed-hex-uint
  swap dup write-hex-uint tab
  0x10000 uint< IF tab THEN
endcol

: ,byte-string/3
  ( string length n )
  2dup equals IF 0 dpush-byte return0 THEN
  3 overn 2 overn string-peek dpush-byte
  1 + loop
;

: ,byte-string
  dup string-length 0 ,byte-string/3
  3 dropn
;

' IF defined? [UNLESS]
  tmp" src/interp/toplevel-if.4th" load/2
[THEN]

NORTH-BUILD-TIME 1659768556 int< IF
def defined?/2
  arg1 arg0 dict dict-lookup 2 return1-n
end
THEN

s" stack-allot-zero" defined?/2 UNLESS " src/lib/seq.4th" load THEN
