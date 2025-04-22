( optimized copiers for aarch32: )

( Copy up: copies from low to high memory. )

( Macros for inner loops: )
push-asm-mark

( Copies up by a byte. )
: emit-copy-up-1
  ( r1 dest, r2 src, r0 counter )
  1 r0 cmp# ,ins
  6 bcc-ins ,ins
  1 r2 r3 ldr# .w .up .b ,ins
  1 r1 r3 str# .w .up .b ,ins
  1 r0 sub# ,ins
  -14 branch-ins ,ins
;

( Copies up by 4 bytes. )
: emit-copy-up-4
  ( r1 dest, r2 src, r0 counter )
  cell-size r0 cmp# ,ins
  6 bcc-ins ,ins
  4 r2 r3 ldr# .w .up ,ins
  4 r1 r3 str# .w .up ,ins
  cell-size r0 sub# ,ins
  -14 branch-ins ,ins
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

( Copies up by 4 bytes, and then by 1 byte. )
defop copy-up-4
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  emit-copy-up-4
  emit-copy-up-1
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

defop copy-cells-up ( src dest num-bytes -- src+#b dest+#b num-bytes-left )
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set pushr ,ins
  ( copy by 16 bytes )
  cell-size 4 mult
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set
  emit-copy-up-loop
  ( 12 bytes )
  cell-size 3 mult
  0 r4 bit-set r5 bit-set r6 bit-set
  emit-copy-up-loop
  ( 8 bytes )
  cell-size 2 mult
  0 r4 bit-set r5 bit-set
  emit-copy-up-loop
  ( 4 bytes and then 1 byte )
  emit-copy-up-4
  emit-copy-up-1
  ( finish up )
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set popr ,ins
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop


( Copy down: copies from high to low memory by the byte. )

( Macros: )
push-asm-mark

( Copy down by the byte. )
: emit-copy-down-1
  ( r1 dest, r2 src, r0 counter )
  1 r0 cmp# ,ins
  6 bcc-ins ,ins
  1 r0 sub# ,ins
  1 r2 r3 ldr# .w .p .b ,ins
  1 r1 r3 str# .w .p .b ,ins
  -14 branch-ins ,ins
;

( Copy down by 4 bytes. )
: emit-copy-down-4
  ( r1 dest, r2 src, r0 counter )
  cell-size r0 cmp# ,ins
  6 bcc-ins ,ins
  cell-size r0 sub# ,ins
  cell-size r2 r3 ldr# .w .p ,ins
  cell-size r1 r3 str# .w .p ,ins
  -14 branch-ins ,ins
;

( Copy down by multiple cells, multiples of 4 bytes: )
: emit-copy-down-loop
  ( r1 dest, r2 src, r0 counter )
  over r0 cmp# ,ins
  6 bcc-ins ,ins
  dup r2 ldm .p .w ,ins
  dup r1 stm .p .w ,ins
  over r0 sub# ,ins ( fixme compare w/ precomputed ending )
  -14 branch-ins ,ins
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

( Copy down by 4 bytes and then by 1 byte. )
defop copy-down-4
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  emit-copy-down-4
  emit-copy-down-1
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop
