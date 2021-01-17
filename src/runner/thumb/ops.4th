( Register aliases: )

r4 const> fp
r5 const> dict-reg
r6 const> cs-reg
r7 const> eip

: emit-branch
  dup abs-int 0x800 int< IF
    branch ,ins
  ELSE
    ( alters LR unlike the above )
    branch-link ,ins
  THEN
;

( Emits the assembly to jump to an op. )
: emit-op-call
  dict-entry-code uint32@ dhere to-out-addr -
  cell-size - emit-branch
;

( Core execution: )

defop exec-r1-abs
  ( load and jump to the pointed to word's code field, leaving word in r0 )
  0 dict-entry-code r1 r2 ldr-offset ,ins
  ( dict-entries are offset from the .text segment. )
  ( add the base address )
  cs-reg r2 r2 add ,ins
  ( jump to the code )
  r2 0 bx-lo ,ins
endop

defop exec-r1
  ( load a word from a CS offset and jump to the word's code field, leaving word in r0 )
  cs-reg r1 r1 add ,ins
  out' exec-r1-abs emit-op-call
endop

defop exec
  ( Move the ToS to r1, lower stack, and exec the word offset. )
  0 r0 r1 mov-lsl ,ins
  0 r0 bit-set popr ,ins
  out' exec-r1 emit-op-call
endop

defop exec-abs
  ( Move the ToS to r1, lower stack, and exec the word pointer. )
  0 r0 r1 mov-lsl ,ins
  0 r0 bit-set popr ,ins
  out' exec-r1-abs emit-op-call
endop

defop next
  ( load word eip points at )
  0 eip r1 ldr-offset ,ins
  ( todo apply op-mask )
  ( increase eip )
  -op-size eip add# ,ins
  out' exec-r1 emit-op-call
endop

: emit-next
  out' next emit-op-call
;

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
  emit-next
endop

defop enter-r0
  ( Call the ToS. )
  0 r0 r1 mov-lsl ,ins
  0 r0 bit-set popr ,ins
  out' enter-r1 emit-op-call
endop

defop do-col
  ( Enter the definition from word's data field. )
  ( load r1's data+cs into r1 )
  0 dict-entry-data r1 r1 ldr-offset ,ins
  cs-reg r1 r1 add ,ins
  out' enter-r1 emit-op-call
endop

defop exit
  ( Return from a list of words. Return address must be the ToS. )
  ( pop eip )
  0 r0 eip mov-lsl ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop quit
  ( todo reset stack & state )
  emit-next
endop

( Stack manipulations: )

defop drop
  0 r0 bit-set popr ,ins
  emit-next
endop

defop dropn
  2 r0 r0 mov-lsl ,ins
  r0 sp add-lohi ,ins
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
  ( Swaps ToS with the value N cells up the stack. `1 swopn` is equivalent to `swap`. )
  2 r0 r1 mov-lsl ,ins
  sp r1 add-hilo ,ins ( r1 addr )
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
  sp r0 add-hilo ,ins
  cell-size r0 sub# ,ins
  0 r0 r0 ldr-offset ,ins
  emit-next
endop

defop set-overn
  0 r1 bit-set popr ,ins
  2 r0 r0 mov-lsl ,ins
  sp r0 add-hilo ,ins
  cell-size r0 sub# ,ins
  0 r0 r1 str-offset ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop here
  0 r0 bit-set pushr ,ins
  sp r0 mov-hilo ,ins
  emit-next
endop

defop move
  r0 sp mov-lohi ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop stack-allot
  sp r1 mov-hilo ,ins
  ( align stack )
  cell-size 1 - r0 add# ,ins
  2 r0 r0 mov-lsr ,ins
  2 r0 r0 mov-lsl ,ins
  ( move stack )
  r0 r1 r0 sub ,ins
  r0 sp mov-lohi ,ins
  emit-next
endop

( Memory ops: )

defop peek
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

defop poke
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

defalias> cstring pointer
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

defop do-var
  ( load the word in R1's data's address into ToS )
  0 r0 bit-set pushr ,ins
  0 r1 r0 mov-lsl ,ins
  0 dict-entry-data r0 add# ,ins
  emit-next
endop

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

: emit-truther
  2 swap exec ,ins
  0 r0 mov# ,ins
  0 branch ,ins
  1 r0 mov# ,ins
;

defop int<
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  ' blt emit-truther
  emit-next
endop

defop int<=
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  ' ble emit-truther
  emit-next
endop

defop uint<
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  ' bcc emit-truther
  emit-next
endop

defop uint<=
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  ' bls emit-truther
  emit-next
endop

: emit-comparable-resulter
  ( not eq )
  10 beq ,ins
    ( less than )
    4 blt ,ins
      1 r0 mov# ,ins
      r0 r0 neg ,ins
      4 branch ,ins
      ( else )
      1 r0 mov# ,ins
      0 branch ,ins
    ( else )
    0 r0 mov# ,ins
;

defop int<=>
  0 r1 bit-set popr ,ins
  r0 r1 cmp ,ins
  emit-comparable-resulter
  emit-next
endop

: emit-unsigned-comparable-resulter
  ( not eq )
  10 beq ,ins
    ( less than )
    4 bcc ,ins
      1 r0 mov# ,ins
      r0 r0 neg ,ins
      4 branch ,ins
      ( else )
      1 r0 mov# ,ins
      0 branch ,ins
    ( else )
    0 r0 mov# ,ins
;

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
  ' beq emit-truther
  emit-next
endop

defop null?
  0 r0 cmp# ,ins
  ' beq emit-truther
  emit-next
endop

defop if-jump
  0 r1 bit-set popr ,ins
  0 r1 cmp# ,ins
  1 beq ,ins
  ( 2 r0 r0 mov-lsl ,ins )
  r0 eip eip add ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop unless-jump
  0 r1 bit-set popr ,ins
  0 r1 cmp# ,ins
  1 bne ,ins
  ( 2 r0 r0 mov-lsl ,ins )
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

defop dict
  0 r0 bit-set pushr ,ins
  0 dict-reg r0 mov-lsl ,ins
  emit-next
endop

defop set-dict
  0 r0 dict-reg mov-lsl ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

( Misc: )

defop nop
  emit-next
endop

( Dictionary helpers: )

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

: emit-set-word-data ( offset data-reg tmp-reg )
  int32 3 overn int32 2 overn emit-load-word
  0 dict-entry-data int32 2 overn int32 4 overn str-offset ,ins
  int32 3 dropn
;

defop push-lr
  0 r0 bit-set pushr ,ins
  lr r0 mov-hilo ,ins
  emit-next
endop
