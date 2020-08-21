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

defcol parent-frame
  exit
endcol

defcol args
  current-frame frame-byte-size +
  swap
endcol

defcol arg0
  args peek swap
endcol

defcol set-arg0
  swap args poke
endcol

defcol arg1
  args cell-size + peek swap
endcol

defcol set-arg1
  swap args cell-size + poke
endcol

defcol arg2
  args cell-size int32 2 * + peek swap
endcol

defcol set-arg2
  swap args cell-size int32 2 * + poke
endcol

defcol arg3
  args cell-size int32 3 * + peek swap
endcol

defcol set-arg3
  swap args cell-size int32 3 * + poke
endcol

defcol argn
  swap cell-size * args + peek swap
endcol

defcol set-argn ( v n )
  swap cell-size * args +
  swap rot swap poke
endcol

defcol locals
  current-frame cell-size -
  swap
endcol

defcol local0
  locals peek swap
endcol

defcol set-local0
  swap locals poke
endcol

defcol return-address
  swap
  cell-size +
  swap
endcol

defcol exit-frame
  drop
  current-frame return-address peek
  end-frame jump
endcol

defop return
  ( Restore FP and SP before exiting. )
  0 r0 bit-set pushr ,uint16
  fp sp mov-lohi ,uint16
  0 fp bit-set popr ,uint16
  0 r0 bit-set popr ,uint16
  1 r3 sub# ,uint16
  op-exit emit-op-call
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

: repeat-frame
  literal int32
  literal begin-frame stack-find here - 1 - -op-size mult
  literal jump-rel
; out-immediate

( todo does-frame )

: def-read
  ' defcol-state-fn set-compiling-state
  read-terminator literal begin-frame
  literal out_immediates compiling-read/2
  here down-stack 0 ' defcol-cb revmap-stack-seq/3 1 + dropn
;

: def
  next-token create does-col def-read
  op-return ,op
;

: end
  0 set-compiling
; out-immediate
