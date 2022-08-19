defop uint64
  0 r0 bit-set pushr ,ins
  0 eip r1 ldr-offset ,ins
  cell-size eip r0 ldr-offset ,ins
  0 r1 bit-set pushr ,ins
  cell-size 2 * eip add# ,ins
  emit-next
endop

defalias> int64 uint64  

defop uint64-add32 ( alo ahi b -- lo hi )
  0 r2 bit-set r3 bit-set popr ,ins
  0 r1 mov# ,ins
  r3 r0 r0 add ,ins
  r2 r1 adc ,ins
  0 r0 bit-set pushr ,ins
  r1 r0 movrr ,ins
  emit-next
endop

defop uint64-addc ( alo ahi blo bhi -- lo hi carry )
  0 r1 bit-set r2 bit-set r3 bit-set popr ,ins
  r3 r1 r1 add ,ins
  r2 r0 adc ,ins
  0 r0 bit-set r1 bit-set pushr ,ins
  0 r0 mov# ,ins
  r0 r0 adc ,ins
  emit-next
endop  

defop int64-add32 ( alo ahi b -- lo hi )
  0 r2 bit-set r3 bit-set popr ,ins
  31 r0 r1 mov-asr ,ins
  r3 r0 r0 add ,ins
  r2 r1 r1 adc ,ins
  0 r0 bit-set pushr ,ins
  r1 r0 movrr ,ins
  emit-next
endop

defop int64-addc ( alo ahi blo bhi -- lo hi higher )
  ( registers: bhi blo ahi alo higher )
  0 r1 bit-set r2 bit-set r3 bit-set popr ,ins
  0 r4 bit-set pushr ,ins
  31 r0 r4 mov-asr ,ins
  r3 r1 r1 add ,ins
  r2 r0 adc ,ins
  0 r3 mov# ,ins
  r4 r3 adc ,ins  ( r3 now higher )
  0 r4 bit-set popr ,ins
  0 r0 bit-set r1 bit-set pushr ,ins
  r3 r0 movrr ,ins
  emit-next
endop  

defop int64-sub ( alo ahi blo bhi -- rlo rhi )
  0 r1 bit-set r2 bit-set r3 bit-set popr ,ins
  r1 r3 r3 sub ,ins
  r0 r2 sbc ,ins
  0 r3 bit-set pushr ,ins
  r2 r0 movrr ,ins
  emit-next
endop
