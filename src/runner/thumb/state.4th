defop save-low-regs
  0xFF pushr .pclr ,ins
  sp r0 movrr ,ins
  emit-next
endop

defop save-high-regs
  0 r0 bit-set pushr ,ins
  r15 r3 movrr ,ins
  r14 r2 movrr ,ins
  r13 r1 movrr ,ins
  r12 r0 movrr ,ins
  0 r0 bit-set r1 bit-set r2 bit-set r3 bit-set pushr ,ins
  r11 r3 movrr ,ins
  r10 r2 movrr ,ins
  r9 r1 movrr ,ins
  r8 r0 movrr ,ins
  0 r0 bit-set r1 bit-set r2 bit-set r3 bit-set pushr ,ins
  sp r0 movrr ,ins
  emit-next
endop

defop load-low-regs
  r0 0xFF ldmia ,ins
  emit-next
endop

defop load-high-regs
  r0 0 r1 bit-set r2 bit-set r3 bit-set ldmia ,ins
  r1 r8 movrr ,ins
  r2 r9 movrr ,ins
  r3 r10 movrr ,ins
  r0 0 r1 bit-set r2 bit-set r3 bit-set ldmia ,ins
  r1 r11 movrr ,ins
  r2 r12 movrr ,ins
  r3 r13 movrr ,ins
  r0 0 r1 bit-set r2 bit-set ldmia ,ins
  r1 r14 movrr ,ins
  r2 r15 movrr ,ins
  emit-next ( needed? )
endop