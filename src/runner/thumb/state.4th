defop save-low-regs
  0xFF pushr .pclr ,uint16
  sp r0 mov-hilo ,uint16
  emit-next
endop

defop save-high-regs
  0 r0 bit-set pushr ,uint16
  r15 r3 mov-hilo ,uint16
  r14 r2 mov-hilo ,uint16
  r13 r1 mov-hilo ,uint16
  r12 r0 mov-hilo ,uint16
  0 r0 bit-set r1 bit-set r2 bit-set r3 bit-set pushr ,uint16
  r11 r3 mov-hilo ,uint16
  r10 r2 mov-hilo ,uint16
  r9 r1 mov-hilo ,uint16
  r8 r0 mov-hilo ,uint16
  0 r0 bit-set r1 bit-set r2 bit-set r3 bit-set pushr ,uint16
  sp r0 mov-hilo ,uint16
  emit-next
endop

defop load-low-regs
  r0 0xFF ldmia ,uint16
  emit-next
endop

defop load-high-regs
  r0 0 r1 bit-set r2 bit-set r3 bit-set ldmia ,uint16
  r1 r8 mov-lohi ,uint16
  r2 r9 mov-lohi ,uint16
  r3 r10 mov-lohi ,uint16
  r0 0 r1 bit-set r2 bit-set r3 bit-set ldmia ,uint16
  r1 r11 mov-lohi ,uint16
  r2 r12 mov-lohi ,uint16
  r3 r13 mov-lohi ,uint16
  r0 0 r1 bit-set r2 bit-set ldmia ,uint16
  r1 r14 mov-lohi ,uint16
  r2 r15 mov-lohi ,uint16
  emit-next ( needed? )
endop