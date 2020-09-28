( Todo To load the assembler: With create builtin, need a compiling-read and colon defining words. )

return-stack peek UNLESS
  128 proper-init
THEN

dhere UNLESS
  64 1024 * data-init-stack
THEN

def does-const
  pointer do-const dict-entry-code peek arg0 dict-entry-code poke
  return0
end

def const>
  create> does-const
  arg0 over dict-entry-data poke
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

def get-word ( name name-len ++ data )
  arg1 arg0 lookup int32 4 unless-jump return1
  dict-entry-data peek cs + return1
end

def set-word ( value name name-len )
  ( todo tokenize a string for the value )
  arg1 arg0 lookup int32 4 unless-jump return0
  does-col
  arg2 swap dict-entry-data cs + poke return0
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

def .s
  args int32 64 memdump
  return0
end immediate

: symbol>
  create> does-const
  dict dict dict-entry-data poke
;

symbol> if-placeholder
( c" if-placeholder" drop here const> if-placeholder )

( todo stack-find roll )

defcol jump-data
  drop
  dict-entry-data peek jump-cs
end

: loop
  literal int32 dict
  literal jump-data
; immediate

def alias
  arg1 dict-entry-code peek arg0 dict-entry-code poke
  arg1 dict-entry-data peek arg0 dict-entry-data poke
end

def dict-drop
  dict dict-entry-link peek cs +
  set-dict
end

def alias>
  create>
  ['] dup IF swap alias exit-frame
  ELSE dict-drop return0
  THEN
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

: IF
  literal int32
  literal if-placeholder
  literal unless-jump
; immediate

: UNLESS
  literal int32
  literal if-placeholder
  literal if-jump
; immediate

: ELSE
  literal int32
  literal if-placeholder stack-find
  literal if-placeholder literal jump-rel
  roll
  dup here stack-delta int32 3 - op-size *
  swap spoke
; immediate

: THEN
  literal if-placeholder stack-find
  dup here stack-delta int32 3 - op-size *
  swap spoke
; immediate

: repeat-frame
  literal int32
  ( todo why does this one need to add 1 to get same offset? op-size guarentee? )
  literal begin-frame stack-find here stack-delta 1 + op-size * negate
  literal jump-rel
; immediate

def POSTPONE
  next-token compile-token
  ( todo adjust words by cs )
  negative? IF not-found nl int32 0 return1
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
end immediate

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
end immediate

symbol> read-terminator

: hey IF hello THEN ;
: heyhey IF hello ELSE boo THEN ;

( todo load or provide iwords and words:
    to load: this-word get-word out_immediates
    to provide: output only immediates, POSTPONE, " to data stack, RECURSE, defcol and def that write to data stack )

def motd
  nl
  hello hello
  nl
end

motd
