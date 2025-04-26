( Optimized copiers for Thumb: )

( Copy up: copies from low to high memory. )

( Macros for inner loops: )
push-asm-mark

( Copies up by a byte. )
: emit-copy-up-1
  ( r1 dest, r2 src, r0 counter )
  1 r0 cmp# ,ins
  10 bcc-ins ,ins
  0 r2 r3 ldr-offset .offset-byte ,ins
  0 r1 r3 str-offset .offset-byte ,ins
  1 r0 sub# ,ins
  1 r1 add# ,ins
  1 r2 add# ,ins
  -18 branch-ins ,ins
;

( Copies up by 4 bytes. )
: emit-copy-up-4
  ( r1 dest, r2 src, r0 counter )
  cell-size r0 cmp# ,ins
  10 bcc-ins ,ins
  0 r2 r3 ldr-offset ,ins
  0 r1 r3 str-offset ,ins
  cell-size r0 sub# ,ins
  cell-size r1 add# ,ins
  cell-size r2 add# ,ins
  -18 branch-ins ,ins
;

pop-mark

( Ops for direct calls: )

( todo remove 1 byte ops )

( Copies up by a byte. )
defop copy-up-1
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  emit-copy-up-1
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

( Copies up by 4 bytes and then by 1 byte. )
defop copy-up-4
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  emit-copy-up-4
  emit-copy-up-1
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

( Copy down: copies from high to low memory. )

( Macros: )
push-asm-mark

( Copy down by the byte. )
: emit-copy-down-1
  ( r1 dest, r2 src, r0 counter )
  1 r0 cmp# ,ins
  10 bcc-ins ,ins
  1 r2 sub# ,ins
  1 r1 sub# ,ins
  1 r0 sub# ,ins
  0 r2 r3 ldr-offset .offset-byte ,ins
  0 r1 r3 str-offset .offset-byte ,ins
  -18 branch-ins ,ins
;

( Copy down by 4 bytes. )
: emit-copy-down-4
  ( r1 dest, r2 src, r0 counter )
  cell-size r0 cmp# ,ins
  10 bcc-ins ,ins
  cell-size r2 sub# ,ins
  cell-size r1 sub# ,ins
  cell-size r0 sub# ,ins
  0 r2 r3 ldr-offset ,ins
  0 r1 r3 str-offset ,ins
  -18 branch-ins ,ins
;

( Copy down by multiple cells, multiples of 4 bytes: )
: emit-copy-down-loop ( byte-size reg-mask ++ )
  ( r1 dest, r2 src, r0 counter )
  over r0 cmp# ,ins
  14 bcc-ins ,ins
  over r1 sub# ,ins
  over r2 sub# ,ins
  r2 r3 movrr ,ins
  r3 over ldmia ,ins
  r1 r3 movrr ,ins
  r3 over stmia ,ins
  over r0 sub# ,ins
  -22 branch-ins ,ins
;

pop-mark

( Ops for direct calls: )

( Copy down by a byte. )
defop copy-down-1
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  emit-copy-down-1
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

( Copy down by 4 bytes, then by 1 byte. )
defop copy-down-4
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  emit-copy-down-4
  emit-copy-down-1
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

( Reverse: )

( Macros for inner loops: )
push-asm-mark

( Reverses a string of bytes. )
: emit-reverse-bytes
  ( r1 dest, r2 src, r0 counter )
  1 r0 cmp# ,ins
  10 bcc-ins ,ins
  0 r2 r3 ldr-offset .offset-byte ,ins
  0 r1 r3 str-offset .offset-byte ,ins
  1 r0 sub# ,ins
  1 r1 add# ,ins
  1 r2 sub# ,ins
  -18 branch-ins ,ins
;

( Reverse a sequence of cells. )
: emit-reverse-cells
  ( r1 dest, r2 src, r0 counter )
  1 r0 cmp# ,ins
  8 bcc-ins ,ins
  0 r2 r3 ldr-offset ,ins
  r1 0 r3 bit-set stmia ,ins
  1 r0 sub# ,ins
  cell-size r2 sub# ,ins
  -16 branch-ins ,ins
;

( Reverse a sequence of cells. )
: emit-nreverse-bytes
  ( r1 dest, r2 src, r0 counter )
  1 r0 cmp# ,ins
  14 bcc-ins ,ins
  0 r1 r3 ldr-offset .offset-byte ,ins
  0 r2 r4 ldr-offset .offset-byte ,ins
  0 r1 r4 str-offset .offset-byte ,ins
  0 r2 r3 str-offset .offset-byte ,ins
  1 r0 sub# ,ins
  1 r1 add# ,ins
  1 r2 sub# ,ins
  -22 branch-ins ,ins
;

( Reverse a sequence of cells. )
: emit-nreverse-cells
  ( r1 dest, r2 src, r0 counter )
  1 r0 cmp# ,ins
  12 bcc-ins ,ins
  0 r1 r3 ldr-offset ,ins
  0 r2 r4 ldr-offset ,ins
  r1 0 r4 bit-set stmia ,ins
  0 r2 r3 str-offset ,ins
  1 r0 sub# ,ins
  cell-size r2 sub# ,ins
  -20 branch-ins ,ins
;

pop-mark
