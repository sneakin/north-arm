cell-size 2 mult const> frame-byte-size
frame-byte-size defconst> frame-byte-size

defop begin-frame
  ( Place FP on the stack and make FP the SP. )
  ( todo more primitive: current-frame here set-current-frame )
  0 r0 bit-set pushr ,ins
  0 fp r0 mov-lsl ,ins
  sp fp movrr ,ins
  cell-size fp sub# ,ins
  emit-next
endop

defop end-frame
  ( Set FP to the frame's parent. )
  ( todo more primitive: current-frame parent-frame set-current-frame )
  fp sp cmprr ,ins
  2 bhi-ins ,ins
  0 fp fp ldr-offset ,ins
  0 branch-ins ,ins
  0 r0 fp mov-lsl ,ins
  emit-next
endop

defop drop-locals
  fp sp movrr ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop set-current-frame
  0 r0 fp mov-lsl ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop current-frame
  0 r0 bit-set pushr ,ins
  0 fp r0 mov-lsl ,ins
  emit-next
endop

defop return0
  ( Restore FP and SP before exiting. )
  0 r0 bit-set pushr ,ins
  fp sp movrr ,ins
  0 fp bit-set popr ,ins
  0 r0 bit-set popr ,ins
  out' exit emit-op-jump
endop

defalias> return return0

defop return0-n
  ( Restore FP and SP before exiting, dropping N args. )
  2 r0 r1 mov-lsl ,ins
  fp sp movrr ,ins
  0 fp bit-set eip bit-set popr ,ins
  r1 sp addrr ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

defop return1
  ( Restore FP and SP before exiting, but keep the ToS. )
  fp sp movrr ,ins
  0 fp bit-set eip bit-set popr ,ins
  emit-next
endop

defop return1-1
  ( Restore FP and SP before exiting, dropping 1 arg, but keeping the next on stack. )
  cell-size r1 mov# ,ins
  0 r0 bit-set popr ,ins
  fp sp movrr ,ins
  0 fp bit-set eip bit-set popr ,ins
  r1 sp addrr ,ins
  emit-next
endop

defop return1-n
  ( Restore FP and SP before exiting, dropping N args, but keep the next on stack. )
  2 r0 r1 mov-lsl ,ins
  0 r0 bit-set popr ,ins
  fp sp movrr ,ins
  0 fp bit-set eip bit-set popr ,ins
  r1 sp addrr ,ins
  emit-next
endop

defop return2
  ( Restore FP and SP before exiting, but keep the ToS and next on stack. )
  0 r1 bit-set popr ,ins
  fp sp movrr ,ins
  0 fp bit-set eip bit-set popr ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop return2-n
  ( Restore FP and SP before exiting, dropping N args, but keep the latest two from the stack. )
  2 r0 r2 mov-lsl ,ins
  0 r0 bit-set r1 bit-set popr ,ins
  fp sp movrr ,ins
  0 fp bit-set eip bit-set popr ,ins
  r2 sp addrr ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop return3
  ( Restore FP and SP before exiting, but keep the top three stack items. )
  0 r1 bit-set r2 bit-set popr ,ins
  fp sp movrr ,ins
  0 fp bit-set eip bit-set popr ,ins
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

defop return4
  ( Restore FP and SP before exiting, but keep the top four stack items. )
  0 r1 bit-set r2 bit-set r3 bit-set popr ,ins
  fp sp movrr ,ins
  0 fp bit-set eip bit-set popr ,ins
  0 r1 bit-set r2 bit-set r3 bit-set pushr ,ins
  emit-next
endop
