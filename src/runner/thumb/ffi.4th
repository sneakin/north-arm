( Basic FFI callers: )

( todo save state before calling? r4-7 saved by called per ABI. )

defop fficall-0-0
  ( r0 is the import's address )
  r0 r12 mov-lohi ,uint16
  ( LR needs + 1 to return to thumb mode )
  1 r0 mov# ,uint16
  r0 lr mov-lohi ,uint16
  0 r0 mov# ,uint16
  ( make the call )
  pc lr add-hihi ,uint16 ( straight to next? )
  r12 0 bx-hi ,uint16
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop fficall-0-1
  ( r0 is the import's address )
  r0 r12 mov-lohi ,uint16
  ( LR needs + 1 to return to thumb mode )
  1 r0 mov# ,uint16
  r0 lr mov-lohi ,uint16
  0 r0 mov# ,uint16
  ( make the call )
  pc lr add-hihi ,uint16 ( straight to next? )
  r12 0 bx-hi ,uint16
  emit-next
endop

defop fficall-1-0
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
  0 r0 bit-set popr ,uint16
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

( FFI code words that load the function from the data field into R0: )

defop do-fficall-0-0
  0 r0 bit-set pushr ,uint16
  0 dict-entry-data r1 r0 ldr-offset ,uint16
  out' fficall-0-0 emit-op-call
endop

defop do-fficall-1-0
  0 r0 bit-set pushr ,uint16
  0 dict-entry-data r1 r0 ldr-offset ,uint16
  out' fficall-1-0 emit-op-call
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
  r1 r9 mov-lohi ,uint16
  out' exec-r1-abs dict-entry-code uint32@ r2 emit-load-int32
  cs-reg r2 r2 add ,uint16
  r2 0 bx-lo ,uint16
;

: emit-exec-uint32
  cell-size 4 *
  ( dhere to-out-addr 2 logand UNLESS cell-size - THEN )
  emit-exec-pc ( fixme depends on where instruction is )
;

( Ops to be copied in trampolines that are called from C with args are in registers: )

( FFI returns by putting LR back in the PC. An explicit op can be used, or the callback can be made to return to a definition that restores EIP and moves LR to PC. )

defop ffi-return
  ( eip lr return-value )
  0 eip bit-set popr .pclr ,uint16
endop

defcol ffi-callback-lz-0
  ( eip lr )
  0 ffi-return
endcol

defop swap-over
  0 r1 ldr-sp ,uint16
  cell-size r2 ldr-sp ,uint16
  0 r2 str-sp ,uint16
  cell-size r1 str-sp ,uint16
  emit-next
endop

defcol ffi-callback-lz-1
  ( eip, lr, return value )
  ffi-return
endcol

: ffi-callback-exec
  ( set eip to callback landing zone, will get pushed on call )
  ( todo ldr-pc )
  dict-entry-data uint32@ eip emit-load-int32
  cs-reg eip eip add ,uint16
  emit-exec-uint32
;

: ffi-callback-exec-0
  out' ffi-callback-lz-0 ffi-callback-exec
;

: ffi-callback-exec-1
  out' ffi-callback-lz-1 ffi-callback-exec
;

defop ffi-callback-0
  ( ARM abi: lr = return address, r0-3 = args, safe to assume r4-7 are exec state: cs, fp, eip? store as data after code? )
  ( save eip & lr )
  0 eip r0 mov-lsl ,uint16
  0 pushr .pclr ,uint16
  ( no args to push )
  ffi-callback-exec-0
endop

defop ffi-callback-1
  0 eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-0
endop

defop ffi-callback-2
  0 r1 bit-set eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-0
endop

defop ffi-callback-3
  0 r1 bit-set r2 bit-set eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-0
endop

defop ffi-callback-0-1
  0 eip r0 mov-lsl ,uint16
  0 pushr .pclr ,uint16  
  ffi-callback-exec-1
endop

defop ffi-callback-1-1
  0 eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-1
endop

defop ffi-callback-2-1
  0 r1 bit-set eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-1
endop

defop ffi-callback-3-1
  0 r1 bit-set r2 bit-set eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-1
endop
