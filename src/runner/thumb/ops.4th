( Register aliases: )

( runner/thumb/constants.4th references these which were only in the asm dictionary )
4 const> fp
5 const> data-reg
6 const> cs-reg
7 const> eip ( todo suffix with reg? )
13 const> sp

push-asm-mark

r4 const> fp
r5 const> data-reg
r6 const> cs-reg
r7 const> eip ( todo suffix with reg? )

target-thumb2? IF
  tmp" Compiling for thumb2" error-line/2
  : thumb2? 1 ;
ELSE
  tmp" Compiling for thumb" error-line/2
  : thumb2? 0 ;
THEN

( Branch helpers: )

: emit-fake-blx ( reg -- )
  ( Emits the equivalunt to a BLX dnstruction: set LR to PC + next instruction, then set PC to the specified register. )
  ( preserve thumb mode, using r0 for scratch )
  0 r0 bit-set pushr ,ins
  1 r0 mov# ,ins
  r0 lr movrr ,ins
  0 r0 bit-set popr ,ins
  ( add PC into LR )
  pc lr addrr ,ins
  ( do branch to register argument )
  bx ,ins
;

: emit-blx ( reg -- )
  ( Emit a BLX or equivalent instruction sequence depending on if ~*arm-thumb2*~ is set. )
  ( todo target-aaarch32-v7? )
  target-aarch32? thumb2? or IF
    blx ,ins
  ELSE
    emit-fake-blx
  THEN
;

(
: print-branch-info
  s" Branch at " error-string/2
  dhere to-out-addr error-hex-uint
  s"  -> " error-string/2
  dup error-hex-int espace
  dhere to-out-addr + error-hex-uint enl
;
)

: emit-branch
  ( dup print-branch-info )
  dup abs-int 0x800 int< IF
    branch ,ins
  ELSE
    thumb2? IF
      ( factor in PC alignment )
      dhere to-out-addr 2 logand 2 +
      ( load the PC relative address into PC )
      ip ldr-pc.w ,ins
      ip pc addrr ,ins
      ( the address offset )
      cell-size - ,uint32
    ELSE
      0 r0 bit-set pushr ,ins
      ( ldr-pc is 4 byte aligned. Determine if the offset will be padded: )
      dhere to-out-addr 2 logand
      ( s" Branch aligned: " error-string/2 espace dhere to-out-addr error-hex-uint espace dup error-int espace enl )
      dup target-aarch32? IF 8 ELSE 6 THEN + r0 ldr-pc ,ins
      ( stash the offset in IP and restore R0 )
      r0 ip movrr ,ins
      0 r0 bit-set popr ,ins
      ( jump to the offset )
      dhere to-out-addr 2 logand
      ip pc addrr ,ins
      ( align the data? )
      swap IF
        2 + ( add padding to offset's offset )
        0 ,uint16 ( the padding )
      THEN
      ( the offset: adjusted for padding & add pc address )
      - target-aarch32? IF 20 ELSE 6 THEN - ,uint32 
    THEN
  THEN
;

( Emits the assembly to jump to an op. )
: emit-op-jump
  dict-entry-code uint32@ dhere to-out-addr - emit-branch
;

( tbd to push LR before calls or in prologue. )

( Emits the assembly to call an op with the PC stored in LR. )
( fixme does it fail on ops that use R1 to access the entry? )
: emit-op-call
  dict-entry-code uint32@ dhere to-out-addr - branch-link ,ins
;

pop-mark

( Core execution: )

defop exec-r1-abs
  ( load and jump to the pointed to word's code field, leaving word in r0 )
  0 dict-entry-code r1 r2 ldr-offset ,ins
  ( skip the length and offset for thumb mode )
  cell-size r2 add# ,ins
  ( dict-entries are offset from the .text segment. )
  ( add the base address )
  cs-reg r2 r2 add ,ins
  ( jump to the code )
  r2 bx ,ins
endop

defop exec-r1
  ( load a word from a CS offset and jump to the word's code field, leaving word in r0 )
  cs-reg r1 r1 add ,ins
  out' exec-r1-abs emit-op-jump
endop

defop exec
  ( Move the ToS to r1, lower stack, and exec the word offset. )
  0 r0 r1 mov-lsl ,ins
  0 r0 bit-set popr ,ins
  out' exec-r1 emit-op-jump
endop

defop exec-abs
  ( Move the ToS to r1, lower stack, and exec the word pointer. )
  0 r0 r1 mov-lsl ,ins
  0 r0 bit-set popr ,ins
  out' exec-r1-abs emit-op-jump
endop

defop next
  ( load word eip points at and increase eip )
  dhere
  eip 0 r1 bit-set ldmia ,ins
  cs-reg r1 r1 add ,ins
  out' exec-r1-abs emit-op-call
  dhere - 4 - branch ,ins
endop

push-asm-mark

: emit-next
  ( out' next emit-op-jump )
  lr bx ,ins
;

pop-mark

( Calling words: )

defop jump
  ( Set eip. )
  0 r0 eip mov-lsl ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop jump-cs
  ( Set eip. )
  r0 cs-reg eip add ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop jump-rel
  ( Set eip from a relative offset. )
  2 r0 r0 mov-lsl ,ins
  r0 eip eip add ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop enter-r1
  ( Save eip and interpret the list of words pointed by r1. )
  ( save eip to ToS )
  0 r0 bit-set pushr ,ins
  0 eip r0 mov-lsl ,ins
  ( load r1 into eip )
  0 r1 eip mov-lsl ,ins
  ( emit-next )
  out' next emit-op-jump
endop

defop do-col
  ( Enter the definition from word's data field. )
  ( load r1's data+cs into r1 )
  0 dict-entry-data r1 r1 ldr-offset ,ins
  cs-reg r1 r1 add ,ins
  out' enter-r1 emit-op-jump
endop

defop exit
  ( Return from a list of words. Return address must be the ToS. )
  ( pop eip )
  0 r0 eip mov-lsl ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

( Stack manipulations: )

defop drop
  0 r0 bit-set popr ,ins
  emit-next
endop

defop dropn
  2 r0 r0 mov-lsl ,ins
  r0 sp addrr ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop dup
  0 r0 bit-set pushr ,ins
  emit-next
endop

defop 2dup
  0 r1 ldr-sp ,ins
  0 r0 bit-set pushr ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop swap
  0 r1 ldr-sp ,ins
  0 r0 str-sp ,ins
  0 r1 r0 mov-lsl ,ins
  emit-next
endop

defop swapn ( sp+n+1 ... value n -- value ... sp+n+1 )
  ( Swaps ToS with the value N cells up the stack. `1 swapn` is equivalent to `swap`. )
  2 r0 r1 mov-lsl ,ins
  sp r1 addrr ,ins ( r1 addr )
  0 r2 bit-set popr ,ins ( r2 near value )
  0 r1 r0 ldr-offset ,ins ( r0 far value ) 
  0 r1 r2 str-offset ,ins
  emit-next
endop

defop 2swap ( a b c d -- c d a b )
  ( d <-> b )
  cell-size 1 mult r1 ldr-sp ,ins
  cell-size 1 mult r0 str-sp ,ins
  0 r1 r0 mov-lsl ,ins
  ( c <-> a )
  cell-size 0 mult r1 ldr-sp ,ins
  cell-size 2 mult r2 ldr-sp ,ins
  cell-size 2 mult r1 str-sp ,ins
  cell-size 0 mult r2 str-sp ,ins
  emit-next
endop

defop rot
  cell-size r1 ldr-sp ,ins
  cell-size r0 str-sp ,ins
  0 r1 r0 mov-lsl ,ins
  emit-next
endop

defop over
  0 r0 bit-set pushr ,ins
  cell-size r0 ldr-sp ,ins
  emit-next
endop

defop overn
  2 r0 r0 mov-lsl ,ins
  sp r0 addrr ,ins
  cell-size r0 sub# ,ins
  0 r0 r0 ldr-offset ,ins
  emit-next
endop

defop set-overn
  0 r1 bit-set popr ,ins
  2 r0 r0 mov-lsl ,ins
  sp r0 addrr ,ins
  cell-size r0 sub# ,ins
  0 r0 r1 str-offset ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop here
  0 r0 bit-set pushr ,ins
  sp r0 movrr ,ins
  emit-next
endop

defop move
  r0 sp movrr ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop stack-allot
  sp r1 movrr ,ins
  ( align stack )
  cell-size 1 - r0 add# ,ins
  2 r0 r0 mov-lsr ,ins
  2 r0 r0 mov-lsl ,ins
  ( move stack )
  r0 r1 r0 sub ,ins
  r0 sp movrr ,ins
  emit-next
endop

( Memory ops: )

defop peek ( addr -- value )
  0 r0 r0 ldr-offset ,ins
  emit-next
endop

defop peek-byte
  0 r0 r0 ldr-offset .offset-byte ,ins
  emit-next
endop

defop peek-short
  0 r0 r0 ldrh ,ins
  emit-next
endop

defop peek-off ( offset base -- value )
  0 r1 bit-set popr ,ins
  r1 r0 r0 ldr ,ins
  emit-next
endop  

defop peek-off-byte
  0 r1 bit-set popr ,ins
  r1 r0 r0 ldr .byte ,ins
  emit-next
endop  

defop peek-off-short
  0 r1 bit-set popr ,ins
  r1 r0 r0 ldr .half ,ins
  emit-next
endop  

defop poke ( value addr -- )
  0 r1 bit-set popr ,ins
  0 r0 r1 str-offset ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop poke-byte
  0 r1 bit-set popr ,ins
  0 r0 r1 str-offset .offset-byte ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop poke-short
  0 r1 bit-set popr ,ins
  0 r0 r1 strh ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop poke-off ( value base offset -- )
  0 r1 bit-set r2 bit-set popr ,ins
  r0 r1 r2 str ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop  

defop poke-off-byte ( value base offset -- )
  0 r1 bit-set r2 bit-set popr ,ins
  r0 r1 r2 str .byte ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop  

defop poke-off-short ( value base offset -- )
  0 r1 bit-set r2 bit-set popr ,ins
  r0 r1 r2 str .half ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

( Data loaders: )

defop literal
  ( store ToS )
  0 r0 bit-set pushr ,ins  
  ( load cell at eip )
  0 eip r0 ldr-offset ,ins
  ( advance eip )
  cell-size eip add# ,ins
  emit-next
endop

defop int32
  ( store ToS )
  0 r0 bit-set pushr ,ins  
  ( load cell at eip )
  0 eip r0 ldr-offset ,ins
  ( advance eip )
  cell-size eip add# ,ins
  emit-next
endop

defop offset32
  ( store ToS )
  0 r0 bit-set pushr ,ins  
  ( load cell at eip & add eip )
  0 eip r0 ldr-offset ,ins
  r0 eip r0 add ,ins
  ( advance eip )
  cell-size eip add# ,ins
  emit-next
endop

defop pointer
  ( store ToS )
  0 r0 bit-set pushr ,ins  
  ( load cell at eip & add CS )
  0 eip r0 ldr-offset ,ins
  cs-reg r0 r0 add ,ins
  ( advance eip )
  cell-size eip add# ,ins
  emit-next
endop

( Data literals: )
defalias> cstring pointer
defalias> string literal
defalias> uint32 int32


( Constants: )

defop do-const
  ( load word in R1's data to ToS )
  0 r0 bit-set pushr ,ins
  0 dict-entry-data r1 r0 ldr-offset ,ins
  emit-next
endop

defop do-const-offset
  ( load word in R1's data + CS to ToS )
  0 r0 bit-set pushr ,ins
  0 dict-entry-data r1 r0 ldr-offset ,ins
  cs-reg r0 r0 add ,ins
  emit-next
endop

( Variables: )

defop do-inplace-var
  ( load the word in R1's data's address into ToS )
  0 r0 bit-set pushr ,ins
  0 r1 r0 mov-lsl ,ins
  0 dict-entry-data r0 add# ,ins
  emit-next
endop

defalias> do-var do-inplace-var

defop do-data-var
  ( load the address in the data segment of the word in R1's data's offset )
  0 r0 bit-set pushr ,ins
  0 r1 r0 mov-lsl ,ins
  0 dict-entry-data r0 r0 ldr-offset ,ins
  cs-reg r0 r0 ldr ,ins
  2 r0 r0 mov-lsl ,ins
  data-reg r0 addrr ,ins
  emit-next
endop

( todo place in separate file for small builds )

defop do-indirect-var
  ( load the address from the word in R1's data's offset )
  0 r0 bit-set pushr ,ins
  0 r1 r0 mov-lsl ,ins
  0 dict-entry-data r0 r0 ldr-offset ,ins
  ( cs-reg r0 addrr ,ins )
  emit-next
endop

defop do-indirect-const
  ( load the address from the word in R1's data's offset )
  0 r0 bit-set pushr ,ins
  0 r1 r0 mov-lsl ,ins
  0 dict-entry-data r0 r0 ldr-offset ,ins
  0 r0 r0 ldr-offset ,ins
  emit-next
endop

defop ds
  0 r0 bit-set pushr ,ins
  data-reg r0 movrr ,ins
  emit-next
endop

defop set-ds
  r0 data-reg movrr ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop


( Dictionary helpers: )

push-asm-mark

: emit-load-word ( offset reg )
  over to-out-addr over emit-load-int32
  cs-reg over dup add ,ins
  int32 2 dropn
;

: emit-get-word-data
  over over emit-load-word
  swap drop
  0 dict-entry-data over dup ldr-offset ,ins
  drop
;

: emit-get-reg-word-data ( src-reg dest-reg -- )
  cs-reg 3 overn 3 overn add ,ins
  0 dict-entry-data over dup ldr-offset ,ins
  cs-reg over dup add ,ins
  2 dropn
;

: emit-set-word-data ( offset data-reg tmp-reg )
  int32 3 overn int32 2 overn emit-load-word
  0 dict-entry-data int32 2 overn int32 4 overn str-offset ,ins
  int32 3 dropn
;

: emit-get-var
  over over emit-load-word
  swap drop
  int32 0 dict-entry-data over dup ldr-offset ,ins
  dup cs-reg over ldr ,ins
  int32 2 over dup mov-lsl ,ins
  data-reg over addrr ,ins
  int32 0 over dup ldr-offset ,ins
  drop
;

: emit-set-var ( offset data-reg tmp-reg )
  int32 3 overn int32 2 overn emit-load-word
  int32 0 dict-entry-data int32 2 overn dup ldr-offset ,ins
  dup cs-reg over ldr ,ins
  int32 2 over dup mov-lsl ,ins
  data-reg over addrr ,ins
  int32 0 over int32 4 overn str-offset ,ins
  int32 3 dropn
;

: emit-truther
  2 swap exec-abs ,ins
  0 r0 mov# ,ins
  0 branch-ins ,ins
  1 r0 mov# ,ins
;

: emit-comparable-resulter
  ( not eq )
  10 beq-ins ,ins
    ( less than )
    4 blt-ins ,ins
      1 r0 mov# ,ins
      r0 r0 neg ,ins
      4 branch-ins ,ins
      ( else )
      1 r0 mov# ,ins
      0 branch-ins ,ins
    ( else )
    0 r0 mov# ,ins
;

: emit-unsigned-comparable-resulter
  ( not eq )
  10 beq-ins ,ins
    ( less than )
    4 bcc-ins ,ins
      1 r0 mov# ,ins
      r0 r0 neg ,ins
      4 branch-ins ,ins
      ( else )
      1 r0 mov# ,ins
      0 branch-ins ,ins
    ( else )
    0 r0 mov# ,ins
;

pop-mark

( Integer Math: )

defop negate
  r0 r0 neg ,ins
  emit-next
endop

defop int-add
  0 r1 bit-set popr ,ins
  r1 r0 r0 add ,ins
  emit-next
endop

defop int-sub
  0 r1 bit-set popr ,ins
  r0 r1 r0 sub ,ins
  emit-next
endop

defop int-mul
  0 r1 bit-set popr ,ins
  r1 r0 mul ,ins
  emit-next
endop

defop int-div-v2
  0 r1 bit-set popr ,ins
  r0 r1 r0 sdiv ,ins
  emit-next
endop

defop uint-div-v2
  0 r1 bit-set popr ,ins
  r0 r1 r0 udiv ,ins
  emit-next
endop

defop int<
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  ' blt-ins emit-truther
  emit-next
endop

defop int<=
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  ' ble-ins emit-truther
  emit-next
endop

defop uint<
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  ' bcc-ins emit-truther
  emit-next
endop

defop uint<=
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  ' bls-ins emit-truther
  emit-next
endop

defop int<=>
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  emit-comparable-resulter
  emit-next
endop

defop uint<=>
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  emit-unsigned-comparable-resulter
  emit-next
endop

( Bits and logic: )

defop bsl
  0 r1 bit-set popr ,ins
  r0 r1 lsl ,ins
  0 r1 r0 mov-lsl ,ins
  emit-next
endop

defop bsr
  0 r1 bit-set popr ,ins
  r0 r1 lsr ,ins
  0 r1 r0 mov-lsl ,ins
  emit-next
endop

defop absr
  0 r1 bit-set popr ,ins
  r0 r1 asr ,ins
  0 r1 r0 mov-lsl ,ins
  emit-next
endop

defop logand
  0 r1 bit-set popr ,ins
  r0 r1 and ,ins
  0 r1 r0 mov-lsl ,ins
  emit-next
endop

defop logior
  0 r1 bit-set popr ,ins
  r1 r0 orr ,ins
  emit-next
endop

defop logxor
  0 r1 bit-set popr ,ins
  r1 r0 eor ,ins
  emit-next
endop

defop lognot
  r0 r0 mvn ,ins
  emit-next
endop

( Conditions: )

defop equals?
  0 r1 bit-set popr ,ins
  r1 r0 cmp ,ins
  ' beq-ins emit-truther
  emit-next
endop

defop null?
  0 r0 cmp# ,ins
  ' beq-ins emit-truther
  emit-next
endop

defop if-jump
  0 r1 bit-set popr ,ins
  0 r1 cmp# ,ins
  2 beq-ins ,ins
  2 r0 r0 mov-lsl ,ins
  r0 eip eip add ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop unless-jump
  0 r1 bit-set popr ,ins
  0 r1 cmp# ,ins
  2 bne-ins ,ins
  2 r0 r0 mov-lsl ,ins
  r0 eip eip add ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

( Registers: )

defop eip
  0 r0 bit-set pushr ,ins
  0 eip r0 mov-lsl ,ins
  emit-next
endop

defop cs
  0 r0 bit-set pushr ,ins
  0 cs-reg r0 mov-lsl ,ins
  emit-next
endop

defop set-cs
  0 r0 cs-reg mov-lsl ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop calc-cs
  0 r0 bit-set pushr ,ins
  ( calculate CS: pc - dhere )
  4 r0 ldr-pc ,ins
  pc r0 add-hilo ,ins
  dhere
  emit-next
  ( data: )
  ( 0 ,uint16 )
  to-out-addr target-aarch32? IF 4 ELSE 2 THEN + negate ,uint32
endop

defop push-lr
  0 r0 bit-set pushr ,ins
  lr r0 movrr ,ins
  emit-next
endop

defop set-pc
  r0 ip movrr ,ins
  0 r0 bit-set popr ,ins
  ip bx ,ins
endop

defop set-eip-pc
  0 r0 r1 mov-lsl ,ins
  0 eip bit-set popr ,ins
  0 r0 bit-set popr ,ins
  r1 0 bx-lo ,ins
endop

( Structures: )

defop field-accessor
  ( with a word in R1, add the field's offset to ToS )
  0 dict-entry-data r1 r1 ldr-offset ,ins
  ( 0 struct-field-offset ) 2 cell-size mult r1 r1 ldr-offset ,ins
  r1 r0 r0 add ,ins
  emit-next
endop

defop seq-field-accessor
  ( with a word in R1, add the field's offset + ToS * the array's element
    type's size to ToS )
  0 dict-entry-data r1 r1 ldr-offset ,ins
  ( 0 struct-field-offset ) 2 cell-size mult r1 r2 ldr-offset ,ins
  ( 0 struct-field-type ) 1 cell-size mult r1 r3 ldr-offset ,ins
  ( r3 cdr ) cell-size r3 r3 ldr-offset ,ins
  ( 0 array-type-element-type ) 4 cell-size mult r3 r3 ldr-offset ,ins
  ( r3 cdr ) cell-size r3 r3 ldr-offset ,ins
  ( 0 type-byte-size ) cell-size r3 r3 ldr-offset ,ins
  ( nth:r0 * el-size:r3 + offset:r2 + ptr:sp[0] )
  r0 r3 mul ,ins
  r3 r2 r0 add ,ins
  0 r1 bit-set popr ,ins
  r1 r0 r0 add ,ins
  emit-next
endop

( Misc: )

defop nop
  emit-next
endop
