( Memory copying assembler routines: )

( Copies from low to high memory by the byte. )
defop copy-up-1
  1 r0 cmp# ,ins
  18 bcc-ins ,ins
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  1 r0 cmp# ,ins
  10 bcc-ins ,ins
  0 r2 r3 ldr-offset .offset-byte ,ins
  0 r1 r3 str-offset .offset-byte ,ins
  1 r0 sub# ,ins
  1 r1 add# ,ins
  1 r2 add# ,ins
  -18 branch-ins ,ins
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

( Copies from low to high memory by the 4 byte cell. )
defop copy-up-4
  cell-size r0 cmp# ,ins
  18 bcc-ins ,ins
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  cell-size r0 cmp# ,ins
  10 bcc-ins ,ins
  0 r2 r3 ldr-offset ,ins
  0 r1 r3 str-offset ,ins
  cell-size r0 sub# ,ins
  cell-size r1 add# ,ins
  cell-size r2 add# ,ins
  -18 branch-ins ,ins
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

push-asm-mark

: emit-copy-up ( bytes register -- )
  ( todo cmp r0 before pop )
  over r0 cmp# ,ins
  18 bcc-ins ,ins
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  dup pushr ,ins
  over r0 cmp# ,ins
  6 bcc-ins ,ins
  r2 over ldmia ,ins
  r1 over stmia ,ins
  over r0 sub# ,ins ( fixme ldmia/stmia should auto increment )
  -14 branch-ins ,ins
  dup popr ,ins
  0 r1 bit-set r2 bit-set pushr ,ins
  2 dropn
;

pop-mark

( Copies from low to high memory by 8 bytes, 2 cells. )
defop copy-up-8
  cell-size 2 mult
  0 r4 bit-set r5 bit-set
  emit-copy-up
  emit-next
endop

( Copies from low to high memory by 12 bytes, 3 cells. )
defop copy-up-12
  cell-size 3 mult
  0 r4 bit-set r5 bit-set r6 bit-set
  emit-copy-up
  emit-next
endop

( Copies from low to high memory by 16 bytes, 4 cells. )
defop copy-up-16
  cell-size 4 mult
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set
  emit-copy-up
  emit-next
endop

( Copies bytes from low to high memory. )
def copy-up ( src dest num-bytes -- bytes-left )
  arg2 arg1 arg0
  arg2 0x3 logand arg1 0x3 logand logior UNLESS
     copy-up-16 copy-up-12 copy-up-8 
  THEN copy-up-4 copy-up-1
  3 return1-n
end

( Copy down: )

( Copies from high to low memory by the byte. )
defop copy-down-1
  1 r0 cmp# ,ins
  18 bcc-ins ,ins
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  1 r0 cmp# ,ins
  10 bcc-ins ,ins
  1 r2 sub# ,ins
  1 r1 sub# ,ins
  1 r0 sub# ,ins
  0 r2 r3 ldr-offset .offset-byte ,ins
  0 r1 r3 str-offset .offset-byte ,ins
  -18 branch-ins ,ins
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

( Copies from high to low memory by 4 bytes, 1 cell. )
defop copy-down-4
  cell-size r0 cmp# ,ins
  18 bcc-ins ,ins
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  cell-size r0 cmp# ,ins
  10 bcc-ins ,ins
  cell-size r2 sub# ,ins
  cell-size r1 sub# ,ins
  cell-size r0 sub# ,ins
  0 r2 r3 ldr-offset ,ins
  0 r1 r3 str-offset ,ins
  -18 branch-ins ,ins
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

push-asm-mark

: emit-copy-down
  over r0 cmp# ,ins
  26 bcc-ins ,ins
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  dup pushr ,ins
  over r0 cmp# ,ins
  14 bcc-ins ,ins  ( fixme ldmia/stmia should auto increment )
  over r1 sub# ,ins
  over r2 sub# ,ins
  r2 r3 movrr ,ins
  r3 over ldmia ,ins
  r1 r3 movrr ,ins
  r3 over stmia ,ins
  over r0 sub# ,ins
  -22 branch-ins ,ins
  dup popr ,ins
  0 r1 bit-set r2 bit-set pushr ,ins
  2 dropn
;

pop-mark

( Copies from high to low memory by 8 bytes, 2 cells. )
defop copy-down-8
  cell-size 2 mult
  0 r4 bit-set r5 bit-set
  emit-copy-down
  emit-next
endop

( Copies from high to low memory by 12 bytes, 3 cells. )
defop copy-down-12
  cell-size 3 mult
  0 r4 bit-set r5 bit-set r6 bit-set
  emit-copy-down
  emit-next
endop

( Copies from high to low memory by 16 bytes, 4 cells. )
defop copy-down-16
  cell-size 4 mult
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set
  emit-copy-down
  emit-next
endop

( Copies bytes from high to low memory. )
def copy-down ( src dest num-bytes -- bytes-left )
  arg2 arg0 int-add
  arg1 arg0 int-add
  arg0
  3 overn 0x3 logand 3 overn 0x3 logand logior UNLESS
    copy-down-16 copy-down-12 copy-down-8
  THEN copy-down-4 copy-down-1
  3 return1-n
end
