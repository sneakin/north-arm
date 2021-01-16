defop save-low-regs
  0xFF pushr .pclr ,ins
  sp r0 mov-hilo ,ins
  emit-next
endop

defop save-high-regs
  0 r0 bit-set pushr ,ins
  r15 r3 mov-hilo ,ins
  r14 r2 mov-hilo ,ins
  r13 r1 mov-hilo ,ins
  r12 r0 mov-hilo ,ins
  0 r0 bit-set r1 bit-set r2 bit-set r3 bit-set pushr ,ins
  r11 r3 mov-hilo ,ins
  r10 r2 mov-hilo ,ins
  r9 r1 mov-hilo ,ins
  r8 r0 mov-hilo ,ins
  0 r0 bit-set r1 bit-set r2 bit-set r3 bit-set pushr ,ins
  sp r0 mov-hilo ,ins
  emit-next
endop

defop load-low-regs
  r0 0xFF ldmia ,ins
  emit-next
endop

defop load-high-regs
  r0 0 r1 bit-set r2 bit-set r3 bit-set ldmia ,ins
  r1 r8 mov-lohi ,ins
  r2 r9 mov-lohi ,ins
  r3 r10 mov-lohi ,ins
  r0 0 r1 bit-set r2 bit-set r3 bit-set ldmia ,ins
  r1 r11 mov-lohi ,ins
  r2 r12 mov-lohi ,ins
  r3 r13 mov-lohi ,ins
  r0 0 r1 bit-set r2 bit-set ldmia ,ins
  r1 r14 mov-lohi ,ins
  r2 r15 mov-lohi ,ins
  emit-next ( needed? )
endop