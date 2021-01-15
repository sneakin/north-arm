( Basic FFI callers: )

( todo save state before calling? r4-7 saved by called per ABI. )

( FFI code words that load the function from the data field into R0: )

: emit-fficaller-r1 ( pop-mask )
  0 r0 bit-set pushr ,uint16
  ( Load the import's [r1] address into r0 )
  0 dict-entry-data r1 r0 ldr-offset ,uint16
  r0 r12 mov-lohi ,uint16
  ( LR needs + 1 to return to thumb mode )
  1 r0 mov# ,uint16
  r0 lr mov-lohi ,uint16
  ( pop arguments )
  ( tbd load the called address at end? )
  dup IF popr ELSE r0 mov# THEN ,uint16
  ( make the call )
  pc lr add-hihi ,uint16 ( straight to next? )
  r12 0 bx-hi ,uint16
;

( Void callees: )

defop do-fficall-0-0
  0 emit-fficaller-r1
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop do-fficall-1-0
  0 r0 bit-set emit-fficaller-r1
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop do-fficall-2-0
  0 r0 bit-set r1 bit-set emit-fficaller-r1
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop do-fficall-3-0
  0 r0 bit-set r1 bit-set r2 bit-set emit-fficaller-r1
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop do-fficall-4-0
  0 r0 bit-set r1 bit-set r2 bit-set r3 bit-set emit-fficaller-r1
  0 r0 bit-set popr ,uint16
  emit-next
endop

( Integer and pointer returning callees: )

defop do-fficall-0-1
  0 emit-fficaller-r1
  emit-next
endop

defop do-fficall-1-1
  0 r0 bit-set emit-fficaller-r1
  emit-next
endop

defop do-fficall-2-1
  0 r0 bit-set r1 bit-set emit-fficaller-r1
  emit-next
endop

defop do-fficall-3-1
  0 r0 bit-set r1 bit-set r2 bit-set emit-fficaller-r1
  emit-next
endop

defop do-fficall-4-1
  0 r0 bit-set r1 bit-set r2 bit-set r3 bit-set emit-fficaller-r1
  emit-next
endop

( Callbacks: )

: emit-exec-pc ( cell-offset -- )
  out' exec-r1-abs dict-entry-code uint32@ r2 emit-load-int32
  cs-reg r2 r2 add ,uint16
  cell-size mult r1 ldr-pc ,uint16
  r2 0 bx-lo ,uint16
;

( The C ABI returns by putting LR back in the PC. Callbacks are made to return to a definition that moves LR to PC. )

defop ffi-return
  ( eip lr return-value )
  0 eip bit-set popr .pclr ,uint16
endop

defcol ffi-callback-lz-0
  ( eip lr )
  0 ffi-return
endcol

defcol ffi-callback-lz-1
  ( eip, lr, return value )
  ffi-return
endcol

( todo push the ABI's locals in cs-reg and dict-reg, but before the callback's args. )

: ffi-callback-exec ( landing-zone -- )
  ( set eip to callback landing zone, will get pushed on call )
  dict-entry-data uint32@ eip emit-load-int32
  ( syscalls wipe the registers. State needs to be loaded from after the branch. )
  dhere 0 ,uint16
  dhere 0 ,uint16
  cs-reg eip eip add ,uint16
  2 emit-exec-pc
  ( patch in PC relative state loading )
  dhere over - cs-reg ldr-pc swap uint16!
  dhere over - dict-reg ldr-pc swap uint16!
;

: ffi-callback-exec-0
  out' ffi-callback-lz-0 ffi-callback-exec
;

: ffi-callback-exec-1
  out' ffi-callback-lz-1 ffi-callback-exec
;

( Ops to be copied in trampolines that are called from C with args that are in registers: )
( ARM abi: lr = return address, r0-3 = args0-3, arg4+ on stack )
( TBD safe to assume r4-7 are exec state: cs, fp, eip? store as data after code? )

( Void callbacks: )

defop ffi-callback-0-0
  ( save eip & lr )
  0 eip r0 mov-lsl ,uint16
  0 pushr .pclr ,uint16
  ffi-callback-exec-0
endop

defop ffi-callback-1-0
  ( arg is already in r0 )
  0 eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-0
endop

defop ffi-callback-2-0
  0 r1 bit-set eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-0
endop

defop ffi-callback-3-0
  0 r1 bit-set r2 bit-set eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-0
endop

defop ffi-callback-4-0
  0 r1 bit-set r2 bit-set r3 bit-set eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-0
endop

( Integer and pointer returning callbacks: )

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

defop ffi-callback-4-1
  0 r1 bit-set r2 bit-set r3 bit-set eip bit-set pushr .pclr ,uint16
  ffi-callback-exec-1
endop
