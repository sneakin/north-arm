( VFP Floating point: )

( todo a flop and bin-flop code word that calls a smaller op in data.code words that assist inlining. )

defop vfp-status-scr
  0 r0 bit-set pushr ,uint16
  1 r0 fmrx.32 ,uint32
  emit-next
endop

defop vfp-status-id
  0 r0 bit-set pushr ,uint16
  0 r0 fmrx.32 ,uint32
  emit-next
endop

defop vfp-status-exc
  0 r0 bit-set pushr ,uint16
  8 r0 fmrx.32 ,uint32
  emit-next
endop

( Single precision: )

defop float32-add
  r0 0 fmsr.32 ,uint32
  1 vpop ,uint32
  1 0 2 fadd.32 ,uint32
  2 r0 fmrs.32 ,uint32
  emit-next
endop

defop float32-sub
  r0 0 fmsr.32 ,uint32
  1 vpop ,uint32
  1 0 2 fsub.32 ,uint32
  2 r0 fmrs.32 ,uint32
  emit-next
endop

defop float32-mul
  r0 0 fmsr.32 ,uint32
  1 vpop ,uint32
  1 0 2 fmul.32 ,uint32
  2 r0 fmrs.32 ,uint32
  emit-next
endop

defop float32-div
  r0 0 fmsr.32 ,uint32
  1 vpop ,uint32
  1 0 2 fdiv.32 ,uint32
  2 r0 fmrs.32 ,uint32
  emit-next
endop

defop float32-negate
  r0 0 fmsr.32 ,uint32
  0 2 fnegs ,uint32
  2 r0 fmrs.32 ,uint32
  emit-next
endop

defop float32-abs
  r0 0 fmsr.32 ,uint32
  0 2 fabss ,uint32
  2 r0 fmrs.32 ,uint32
  emit-next
endop

defop float32-equals?
  r0 0 fmsr.32 ,uint32
  1 vpop ,uint32
  0 1 fcmps ,uint32
  1 r15 fmrx.32 ,uint32
  ' beq emit-truther
  emit-next
endop

defop float32<=>
  r0 0 fmsr.32 ,uint32
  1 vpop ,uint32
  0 1 fcmps ,uint32
  1 r15 fmrx.32 ,uint32
  emit-comparable-resulter
  emit-next
endop

defop float32-zero?
  r0 0 fmsr.32 ,uint32
  0 fcmpzs ,uint32
  1 r15 fmrx.32 ,uint32
  ' beq emit-truther
  emit-next
endop

defop float32->uint32
  r0 0 fmsr.32 ,uint32
  0 0 ftouizs ,uint32
  0 r0 fmrs.32 ,uint32
  emit-next
endop

defop uint32->float32
  r0 0 fmsr.32 ,uint32
  0 0 fuitos ,uint32
  0 r0 fmrs.32 ,uint32
  emit-next
endop

defop float32->int32
  r0 0 fmsr.32 ,uint32
  0 0 ftosizs ,uint32
  0 r0 fmrs.32 ,uint32
  emit-next
endop

defop int32->float32
  r0 2 fmsr.32 ,uint32
  2 1 fsitos ,uint32
  1 r0 fmrs.32 ,uint32
  emit-next
endop

( Double precision: )

defop float64-add ( bh bl ah al -- rh rl )
  ( Could also do:
  0 r1 bit-set popr ,uint16
  r0 0 fmdlr.64 ,uint32
  r1 0 fmdhr.64 ,uint32
  1 vpopd ,uint32
  )
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  1 0 2 fadd.64 ,uint32
  2 r0 fmrdl.64 ,uint32
  2 r1 fmrdh.64 ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-sub ( bh bl ah al -- rh rl )
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  1 0 2 fsub.64 ,uint32
  2 r0 fmrdl.64 ,uint32
  2 r1 fmrdh.64 ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-mul
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  1 0 2 fmul.64 ,uint32
  2 r0 fmrdl.64 ,uint32
  2 r1 fmrdh.64 ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-div
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  1 0 2 fdiv.64 ,uint32
  2 r0 fmrdl.64 ,uint32
  2 r1 fmrdh.64 ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-negate
  0 r1 bit-set popr ,uint16
  r0 0 fmdlr.64 ,uint32
  r1 0 fmdhr.64 ,uint32
  0 2 fnegd ,uint32
  2 r0 fmrdl.64 ,uint32
  2 r1 fmrdh.64 ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-abs
  0 r1 bit-set popr ,uint16
  r0 0 fmdlr.64 ,uint32
  r1 0 fmdhr.64 ,uint32
  0 2 fabsd ,uint32
  2 r0 fmrdl.64 ,uint32
  2 r1 fmrdh.64 ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-equals? ( ah al bh bl -- true? )
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  0 1 fcmpd ,uint32
  1 r15 fmrx.32 ,uint32
  ' beq emit-truther
  emit-next
endop

defop float64<=> ( ah al bh bl -- trival )
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  0 1 fcmpd ,uint32
  1 r15 fmrx.32 ,uint32
  emit-comparable-resulter
  emit-next
endop

defop float64-zero? ( ah al -- true? )
  0 r1 bit-set popr ,uint16
  r0 0 fmdlr.64 ,uint32
  r1 0 fmdhr.64 ,uint32
  0 fcmpzd ,uint32
  1 r15 fmrx.32 ,uint32
  ' beq emit-truther
  emit-next
endop

defop float64->uint32
  0 r1 bit-set popr ,uint16
  r0 0 fmdlr.64 ,uint32
  r1 0 fmdhr.64 ,uint32
  0 0 ftouizd ,uint32
  0 r0 fmrs.32 ,uint32
  emit-next
endop

defop float64->int32
  0 r1 bit-set popr ,uint16
  r0 0 fmdlr.64 ,uint32
  r1 0 fmdhr.64 ,uint32
  0 0 ftosizd ,uint32
  0 r0 fmrs.32 ,uint32
  emit-next
endop

defop uint32->float64 ( uint32 -- fh fl )
  r0 0 fmdlr.64 ,uint32
  0 r0 mov# ,uint16
  r0 0 fmdhr.64 ,uint32
  0 0 fuitod ,uint32
  0 r0 fmrdl.64 ,uint32
  0 r1 fmrdh.64 ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop int32->float64
  r0 0 fmdlr.64 ,uint32
  0 r0 mov# ,uint16
  r0 0 fmdhr.64 ,uint32
  0 0 fsitod ,uint32
  0 r0 fmrdl.64 ,uint32
  0 r1 fmrdh.64 ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64->float32
  0 r1 bit-set popr ,uint16
  r0 0 fmdlr.64 ,uint32
  r1 0 fmdhr.64 ,uint32
  0 0 fcvtsd ,uint32
  0 r0 fmrs.32 ,uint32
  emit-next
endop

defop float32->float64
  r0 0 fmsr.32 ,uint32
  0 0 fcvtds ,uint32
  0 r0 fmrdl.64 ,uint32
  0 r1 fmrdh.64 ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop
