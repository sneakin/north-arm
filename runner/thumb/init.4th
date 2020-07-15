cell-size 2 mult const> frame-byte-size
frame-byte-size defconst> frame-byte-size
cell-size defconst> cell-size
-op-size defconst> op-size

defop dict
  0 r0 bit-set pushr ,uint16
  0 dict-reg r0 mov-lsl ,uint16
  emit-next
endop

defop set-dict
  0 r0 dict-reg mov-lsl ,uint16
  0 r0 bit-set popr ,uint16
  emit-next
endop

defcol break
  int32 0x47 peek
endcol

defop swap
  0 r1 ldr-sp ,uint16
  0 r0 str-sp ,uint16
  0 r1 r0 mov-lsl ,uint16
  emit-next
endop

defop rot
  cell-size r1 ldr-sp ,uint16
  cell-size r0 str-sp ,uint16
  0 r1 r0 mov-lsl ,uint16
  emit-next
endcol

defop 2dup
  0 r1 ldr-sp ,uint16
  0 r0 bit-set pushr ,uint16
  0 r1 bit-set pushr ,uint16
  emit-next
endop

( Messages: )

: string-const>
  dhere swap ,byte-string 4 pad-data defconst-offset>
;

" BOOM" string-const> boom-s

defcol boom
  int32 4 boom-s int32 1 write drop
endcol

defcol hello-s
  int32 6 offset32 12 rot exit
  s" Hello!"
endcol

defcol hello
  hello-s swap int32 1 write drop
endcol

defcol crap-s
  int32 5 offset32 12 rot exit
  s" Crap!"
endcol

defcol crap
  crap-s swap int32 1 write drop
endcol

defcol what-s
  int32 5 offset32 12 rot exit
  s" What!"
endcol

defcol what
  what-s swap int32 1 write drop
endcol

defcol boo-s
  int32 4 offset32 12 rot exit
  s" Boo!"
endcol

defcol boo
  boo-s swap int32 1 write drop
endcol

defcol not-found-s
  int32 10 offset32 12 rot exit
  s" Not Found."
endcol

defcol not-found
  not-found-s swap int32 1 write drop
endcol

defcol nl-s
  int32 1 offset32 12 rot exit
  s" 
"
endcol

defcol nl
  nl-s swap int32 1 write drop
endcol

: RECURSE
  ' int32
  dict
  ' exec ( fixme litters stack with return addresses? )
; out-immediate

defop equals?
  0 r1 bit-set popr ,uint16
  r1 r0 cmp ,uint16
  ' beq emit-truther
  emit-next
endop

defop null?
  0 r0 cmp# ,uint16
  ' beq emit-truther
  emit-next
endop

defop if-jump
  0 r1 bit-set popr ,uint16
  0 r1 cmp# ,uint16
  1 beq ,uint16
  ( 2 r0 r0 mov-lsl ,uint16 )
  r0 eip eip add ,uint16
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop unless-jump
  0 r1 bit-set popr ,uint16
  0 r1 cmp# ,uint16
  1 bne ,uint16
  ( 2 r0 r0 mov-lsl ,uint16 )
  r0 eip eip add ,uint16
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop begin-frame
  ( Place FP on the stack and make FP the SP. )
  0 r0 bit-set pushr ,uint16
  0 fp r0 mov-lsl ,uint16
  sp fp mov-hilo ,uint16
  cell-size fp sub# ,uint16
  1 r3 add# ,uint16
  emit-next
endop

defop end-frame
  ( Set FP to the frame's parent. )
  0 r0 bit-set pushr ,uint16
  0 fp fp ldr-offset ,uint16
  1 r3 sub# ,uint16
  emit-next
endop

defop current-frame
  0 r0 bit-set pushr ,uint16
  0 fp r0 mov-lsl ,uint16
  emit-next
endop

defcol args
  current-frame frame-byte-size +
  swap
endcol

defcol arg0
  args peek swap
endcol

defcol set-arg0
  swap args poke
endcol

defcol arg1
  args cell-size + peek swap
endcol

defcol set-arg1
  swap args cell-size + poke
endcol

defcol arg2
  args cell-size int32 2 * + peek swap
endcol

defcol set-arg2
  swap args cell-size int32 2 * + poke
endcol

defcol arg3
  args cell-size int32 3 * + peek swap
endcol

defcol set-arg3
  swap args cell-size int32 3 * + poke
endcol

defcol argn
  swap cell-size * args + peek swap
endcol

defcol set-argn ( v n )
  swap cell-size * args +
  swap rot swap poke
endcol

defcol locals
  current-frame cell-size -
  swap
endcol

defcol local0
  locals peek swap
endcol

defcol set-local0
  swap locals poke
endcol

defcol return-address
  swap
  cell-size +
  swap
endcol

defcol exit-frame
  drop
  current-frame return-address peek
  end-frame jump
endcol

defop return
  ( Restore FP and SP before exiting. )
  0 r0 bit-set pushr ,uint16
  fp sp mov-lohi ,uint16
  0 fp bit-set popr ,uint16
  0 r0 bit-set popr ,uint16
  1 r3 sub# ,uint16
  op-exit emit-op-call
endop

defop return1
  ( Restore FP and SP before exiting, but keep the ToS. )
  fp sp mov-lohi ,uint16
  0 fp bit-set popr ,uint16
  0 eip bit-set popr ,uint16
  1 r3 sub# ,uint16
  emit-next
endop

defop return2
  ( Restore FP and SP before exiting, but keep the ToS and next on stack. )
  0 r1 bit-set popr ,uint16
  fp sp mov-lohi ,uint16
  0 fp bit-set popr ,uint16
  0 eip bit-set popr ,uint16
  0 r1 bit-set pushr ,uint16
  1 r3 sub# ,uint16
  emit-next
endop

defcol dict-entry-name
  exit exit ( fixme compiling-read and empties, revmap too? )
endcol

defcol dict-entry-link
  swap
  cell-size int32 3 * +
  swap
endcol

: repeat-frame
  literal int32
  literal begin-frame stack-find here - 1 - -op-size mult
  literal jump-rel
; out-immediate

defcol write-string/2 ( string length -- )
  rot int32 1 write drop
endcol

( fixme "boo" == "boot"? Need to check lengths on both. Checking for 0 byte at end works, but not perfect. )

defcol byte-string-equals?/3 ( a-str b-str length )
  begin-frame
  arg2 peek-byte
  arg1 peek-byte
  equals? UNLESS int32 0 return1 THEN
  arg0 int32 0 int<= IF int32 1 return1 THEN
  int32 1 arg0 - set-arg0
  int32 1 arg1 + set-arg1
  int32 1 arg2 + set-arg2
  repeat-frame
endcol

defcol string-equals?/3 ( a-str b-str length )
  begin-frame
  arg0 cell-size int< IF
    arg2 arg1 arg0 byte-string-equals?/3 return1
  THEN
  arg2 peek
  arg1 peek
  equals? UNLESS int32 0 return1 THEN
  cell-size arg0 - set-arg0
  cell-size arg1 + set-arg1
  cell-size arg2 + set-arg2
  repeat-frame
endcol

defop cs
  0 r0 bit-set pushr ,uint16
  0 cs r0 mov-lsl ,uint16
  emit-next
endcol

defcol dict-lookup ( ptr length dict-entry ++ found? )
  begin-frame
  arg0 null? IF int32 0 return1 THEN
  ( arg0 dict-entry-name peek cs + arg1 write-string/2 )
  arg0 dict-entry-name peek cs + arg2 arg1 string-equals?/3 IF
    int32 1 return1
  THEN
  int32 3 dropn
  arg0 dict-entry-link peek
  dup null? IF int32 0 return1 THEN
  cs + set-arg0
  repeat-frame
endcol

defop 2swap ( a b c d -- c d a b )
  ( d <-> b )
  cell-size 1 mult r1 ldr-sp ,uint16
  cell-size 1 mult r0 str-sp ,uint16
  0 r1 r0 mov-lsl ,uint16
  ( c <-> a )
  cell-size 0 mult r1 ldr-sp ,uint16
  cell-size 2 mult r2 ldr-sp ,uint16
  cell-size 2 mult r1 str-sp ,uint16
  cell-size 0 mult r2 str-sp ,uint16
  emit-next
endop

defcol lookup ( ptr length -- dict-entry found? )
  rot swap
  dict dict-lookup
  swap 2swap int32 2 dropn rot
endcol

defcol string-poke ( value string index )
  rot +
  swap rot swap poke-byte
endcol

defcol negative?
  over int32 0 int< swap
endcol

defcol null-terminate
  rot int32 0 rot string-poke
endcol

defcol read-token ( ptr len -- ptr read-length )
  over int32 4 overn int32 0 read
  negative? UNLESS
    int32 1 swap -
    int32 4 overn over null-terminate
  THEN
  rot drop
endcol

defcol prompt
  offset32 20 int32 7 write-string/2
  exit
  s" Forth> "
endcol

defcol one
  int32 1 swap
endcol

defcol zero
  int32 0 swap
endcol

defop bsl
  0 r1 bit-set popr ,uint16
  r0 r1 lsl ,uint16
  0 r1 r0 mov-lsl ,uint16
  emit-next
endop

defop bsr
  0 r1 bit-set popr ,uint16
  r0 r1 lsr ,uint16
  0 r1 r0 mov-lsl ,uint16
  emit-next
endop

defop logand
  0 r1 bit-set popr ,uint16
  r0 r1 and ,uint16
  0 r1 r0 mov-lsl ,uint16
  emit-next
endop

defop logior
  0 r1 bit-set popr ,uint16
  r1 r0 eor ,uint16
  emit-next
endop

defop lognot
  r0 r0 mvn ,uint16
  emit-next
endop

defcol hex-digit
  swap int32 0xF logand
  dup int32 10 int< IF
    int32 48
  ELSE
    int32 10 swap -
    int32 65
  THEN
  + swap
endcol

defcol uint->hex-string/4 ( n out-ptr counter print-always? )
  begin-frame
  ( start with the highest nibble )
  arg3 int32 0xF0000000 logand int32 28 bsr
  ( past leading zeroes? )
  arg0 UNLESS
    dup int32 0 equals? UNLESS
      int32 1 set-arg0
    THEN
  THEN
  arg0 IF
    ( write a digit )
    hex-digit arg2 poke-byte
    arg2 int32 1 + set-arg2
  ELSE
    ( leading zero )
    drop
  THEN
  ( advance the counters & repeat )
  arg1 int32 7 int< IF
    arg1 int32 1 + set-arg1
    arg3 int32 4 bsl set-arg3
    ( N is zero )
    arg1 int32 7 equals? IF int32 1 set-arg0 THEN
    repeat-frame
  THEN
  return
endcol

defcol uint->hex-string ( n out-ptr -- out-ptr length )
  begin-frame
  arg1 arg0 int32 0 int32 0 uint->hex-string/4
  int32 2 dropn
  arg0 dup set-arg1
  swap - set-arg0
  arg1 arg0 int32 1 + null-terminate
  return
endcol

defop negate
  r0 r0 neg ,uint16
  emit-next
endop

defcol int->hex-string ( n out-ptr -- out-ptr length )
  begin-frame
  arg1 negative? IF
    negate
    int32 45 arg0 poke-byte
    arg0 int32 1 +
  ELSE
    arg0
  THEN
  int32 0 int32 0 uint->hex-string/4
  int32 2 dropn
  arg0 dup set-arg1
  swap - set-arg0
  arg1 arg0 int32 1 + null-terminate
  return
endcol

defcol write-hex-uint/1 ( n )
  begin-frame
  int32 12 stack-allot ( need 9 bytes for a 32 bit number, 10 with minus. )
  arg0 over uint->hex-string
  write-string/2
  return
endcol

defcol write-hex-uint
  swap write-hex-uint/1
  drop
endcol

defcol write-hex-int/1 ( n )
  begin-frame
  int32 12 stack-allot ( need 9 bytes for a 32 bit number, 10 with minus. )
  arg0 over int->hex-string
  write-string/2
  return
endcol

defcol write-hex-int
  swap write-hex-int/1
  drop
endcol

defcol interp-loop
  nl hello
  begin-frame
  nl prompt
  arg1 arg0 read-token negative? IF what what return THEN
  2dup write-string/2 nl
  lookup IF exec-abs ELSE not-found drop THEN
  repeat-frame
endcol

( The first interpreted definition that is called: )
defcol boot
  hello
  begin-frame
  int32 128 stack-allot
  int32 128 interp-loop
  boo
  bye
  return
endcol

( OS entry point: )
defop init
  ( calculate CS: pc - dhere )
  30 r3 ldr-pc ,uint16
  pc r5 mov-hilo ,uint16
  r3 r5 cs sub ,uint16
  ( zero registers )
  sp r0 mov-hilo ,uint16
  0 r1 mov# ,uint16
  0 r2 mov# ,uint16
  0 r3 mov# ,uint16
  0 fp mov# ,uint16
  0 eip mov# ,uint16
  ( set the dictionary )
  20 dict-reg ldr-pc ,uint16
  cs dict-reg dict-reg add ,uint16
  ( exec boot )
  14 r1 ldr-pc ,uint16
  op-exec-r1 emit-op-call
  ( data: )
  4 align-data
  dict dict-entry-size + 10 + ,uint32
  op-boot ,uint32
  dict ,uint32
endop

( todo pass eip as an argument to a top level eval. Likewise with the dictionaries and other state like registers. )
  ( todo set dict in colon def from const )
