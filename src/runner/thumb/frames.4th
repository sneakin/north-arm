cell-size 2 mult const> frame-byte-size
frame-byte-size defconst> frame-byte-size

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
  fp sp cmp-lohi ,uint16
  2 bhi ,uint16
  0 fp fp ldr-offset ,uint16
  0 branch ,uint16
  0 r0 fp mov-lsl ,uint16
  emit-next
endop

defop drop-locals
  fp sp mov-lohi ,uint16
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop set-current-frame
  0 r0 fp mov-lsl ,uint16
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop current-frame
  0 r0 bit-set pushr ,uint16
  0 fp r0 mov-lsl ,uint16
  emit-next
endop

defop return
  ( Restore FP and SP before exiting. )
  0 r0 bit-set pushr ,uint16
  fp sp mov-lohi ,uint16
  0 fp bit-set popr ,uint16
  0 r0 bit-set popr ,uint16
  1 r3 sub# ,uint16
  out' exit emit-op-call
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
