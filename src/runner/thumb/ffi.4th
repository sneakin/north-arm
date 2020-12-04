( Basic FFI callers and doers: )

defop fficall-0-1
  ( r0 is the import's address )
  r0 r12 mov-lohi ,uint16
  ( LR needs + 1 to return to thumb mode )
  1 r0 mov# ,uint16
  r0 lr mov-lohi ,uint16
  ( make the call )
  pc lr add-hihi ,uint16 ( straight to next? )
  r12 0 bx-hi ,uint16
  emit-next
endop

defop fficall-1-1
  ( r0 is the import's address )
  r0 r12 mov-lohi ,uint16
  ( LR needs + 1 to return to thumb mode )
  1 r0 mov# ,uint16
  r0 lr mov-lohi ,uint16
  ( pop the argument )
  0 r0 bit-set popr ,uint16
  ( make the call )
  pc lr add-hihi ,uint16 ( straight to next? )
  r12 0 bx-hi ,uint16
  emit-next
endop

defop fficall-2-1
  ( r0 is the import's address )
  r0 r12 mov-lohi ,uint16
  ( LR needs + 1 to return to thumb mode )
  1 r0 mov# ,uint16
  r0 lr mov-lohi ,uint16
  ( pop the argument )
  0 r0 bit-set r1 bit-set popr ,uint16
  ( make the call )
  pc lr add-hihi ,uint16 ( straight to next? )
  r12 0 bx-hi ,uint16
  emit-next
endop

defop fficall-3-1
  ( r0 is the import's address )
  r0 r12 mov-lohi ,uint16
  ( LR needs + 1 to return to thumb mode )
  1 r0 mov# ,uint16
  r0 lr mov-lohi ,uint16
  ( pop the argument )
  0 r0 bit-set r1 bit-set r2 bit-set popr ,uint16
  ( make the call )
  pc lr add-hihi ,uint16 ( straight to next? )
  r12 0 bx-hi ,uint16
  emit-next
endop

defop fficall-4-1
  ( r0 is the import's address )
  r0 r12 mov-lohi ,uint16
  ( LR needs + 1 to return to thumb mode )
  1 r0 mov# ,uint16
  r0 lr mov-lohi ,uint16
  ( pop the argument )
  0 r0 bit-set r1 bit-set r2 bit-set r3 bit-set popr ,uint16
  ( make the call )
  pc lr add-hihi ,uint16 ( straight to next? )
  r12 0 bx-hi ,uint16
  emit-next
endop

defop do-fficall-0-1
  0 r0 bit-set pushr ,uint16
  0 dict-entry-data r1 r0 ldr-offset ,uint16
  out' fficall-0-1 emit-op-call
endop

defop do-fficall-1-1
  0 r0 bit-set pushr ,uint16
  0 dict-entry-data r1 r0 ldr-offset ,uint16
  out' fficall-1-1 emit-op-call
endop

defop do-fficall-2-1
  0 r0 bit-set pushr ,uint16
  0 dict-entry-data r1 r0 ldr-offset ,uint16
  out' fficall-2-1 emit-op-call
endop

defop do-fficall-3-1
  0 r0 bit-set pushr ,uint16
  0 dict-entry-data r1 r0 ldr-offset ,uint16
  out' fficall-3-1 emit-op-call
endop

defop do-fficall-4-1
  0 r0 bit-set pushr ,uint16
  0 dict-entry-data r1 r0 ldr-offset ,uint16
  out' fficall-4-1 emit-op-call
endop

( Callbacks: )

: emit-exec-pc ( offset -- )
  r1 ldr-pc ,uint16
  out' exec-r1-abs dict-entry-code uint32@ r2 emit-load-int32
  cs-reg r2 r2 add ,uint16
  r2 pc mov-lohi ,uint16
;

: emit-exec-uint32
  cell-size 4 * emit-exec-pc
;

( Ops to be copied in trampolines that are called from C with args are in registers: )

defop ffi-callback-0
  0 pushr .pclr ,uint16
  emit-exec-uint32
endop

defop ffi-callback-1
  0 pushr .pclr ,uint16
  emit-exec-uint32
endop

defop ffi-callback-2
  0 r1 bit-set pushr .pclr ,uint16
  emit-exec-uint32
endop

defop ffi-callback-3
  0 r1 bit-set r2 bit-set pushr .pclr ,uint16
  emit-exec-uint32
endop

defop ffi-return
  0 r0 eip mov-lsl ,uint16
  0 popr .pclr ,uint16
endop
