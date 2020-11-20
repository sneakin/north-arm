( VFP Floating point: )

( todo a flop and bin-flop code word that calls a smaller op in data.code words that assist inlining. )
( todo comparisons conditions without 1 or 0 on stack. )

defop vfpscr
  0 r0 bit-set pushr ,uint16
  1 r0 fmrxs ,uint32
  emit-next
endop

defop vfpscr! ( new-value -- )
  ( Only works in privileged mode. )
  r0 1 fmxrs ,uint32
  0 r0 bit-set popr ,uint16
  emit-next
endop

( todo scr modes: rounding, vector, stride, traps; set on every op? )

defop vfpsid
  ( Only works in privileged mode. )
  0 r0 bit-set pushr ,uint16
  0 r0 fmrxs ,uint32
  emit-next
endop

defop vfpexc
  ( Only works in privileged mode. )
  0 r0 bit-set pushr ,uint16
  8 r0 fmrxs ,uint32
  emit-next
endop

( Single precision: )

defop float32-add
  r0 0 fmsrs ,uint32
  1 vpop ,uint32
  1 0 2 fadds ,uint32
  2 r0 fmrss ,uint32
  emit-next
endop

( todo vector operations: up to 4 floats. )
( todo need a way to xfer vectors tofrom banks, bank 0 is scalar )
( todo pop and push could be done in code word for each vector length )
( todo sqrt, exponent, fraction )
( todo vectors from pointer )
( todo fpscr not setting )

defop float32-add-2 ( a2 a1 b2 b1 -- r2 r1 )
  0 r0 bit-set pushr ,uint16
  2 8 vpopn ,uint32
  2 16 vpopn ,uint32
  16 8 24 fadds ,uint32
  2 24 vpushn ,uint32
  0 r0 bit-set popr ,uint16
  emit-next
endop

( Could factor these ops down to single instructions:
defop float32-load0
  r0 0 fmsrs ,uint32
endop
defop float32-load1
  r0 1 fmsrs ,uint32
endop
defop float32-add-102
  1 0 2 fadds ,uint32
endop
defop float32-push-2
  2 r0 fmrss ,uint32
endop
defcol float32-add
  swap float32-load0
  swap float32-load1
  float32-add-102
  float32-push-2
  swap
end
defcol float32-add-2
  rot swap 8 float32-pop-v1.2
  rot swap 16 float32-pop-v2.2
  float32-add-v1v2.2
  float32-push-v3.2
  swap rot
endcol
)

defop float32-sub
  r0 0 fmsrs ,uint32
  1 vpop ,uint32
  1 0 2 fsubs ,uint32
  2 r0 fmrss ,uint32
  emit-next
endop

defop float32-mul
  r0 0 fmsrs ,uint32
  1 vpop ,uint32
  1 0 2 fmuls ,uint32
  2 r0 fmrss ,uint32
  emit-next
endop

defop float32-div
  r0 0 fmsrs ,uint32
  1 vpop ,uint32
  1 0 2 fdivs ,uint32
  2 r0 fmrss ,uint32
  emit-next
endop

defop float32-negate
  r0 0 fmsrs ,uint32
  0 2 fnegs ,uint32
  2 r0 fmrss ,uint32
  emit-next
endop

defop float32-sqrt
  r0 0 fmsrs ,uint32
  0 2 fsqrts ,uint32
  2 r0 fmrss ,uint32
  emit-next
endop

defop float32-abs
  r0 0 fmsrs ,uint32
  0 2 fabss ,uint32
  2 r0 fmrss ,uint32
  emit-next
endop

defop float32-equals?
  r0 0 fmsrs ,uint32
  1 vpop ,uint32
  0 1 fcmps ,uint32
  1 r15 fmrxs ,uint32
  ' beq emit-truther
  emit-next
endop

defop float32<=>
  r0 0 fmsrs ,uint32
  1 vpop ,uint32
  0 1 fcmps ,uint32
  1 r15 fmrxs ,uint32
  emit-comparable-resulter
  emit-next
endop

defop float32-zero?
  r0 0 fmsrs ,uint32
  0 fcmpzs ,uint32
  1 r15 fmrxs ,uint32
  ' beq emit-truther
  emit-next
endop

defop float32->uint32
  r0 0 fmsrs ,uint32
  0 0 ftouizs ,uint32
  0 r0 fmrss ,uint32
  emit-next
endop

defop uint32->float32
  r0 0 fmsrs ,uint32
  0 0 fuitos ,uint32
  0 r0 fmrss ,uint32
  emit-next
endop

defop float32->int32
  r0 0 fmsrs ,uint32
  0 0 ftosizs ,uint32
  0 r0 fmrss ,uint32
  emit-next
endop

defop int32->float32
  r0 2 fmsrs ,uint32
  2 1 fsitos ,uint32
  1 r0 fmrss ,uint32
  emit-next
endop

( Double precision: )

defop float64-add ( bh bl ah al -- rh rl )
  ( Could also do:
  0 r1 bit-set popr ,uint16
  r0 0 fmdlrd ,uint32
  r1 0 fmdhrd ,uint32
  1 vpopd ,uint32
  )
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  1 0 2 faddd ,uint32
  2 r0 fmrdld ,uint32
  2 r1 fmrdhd ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-sub ( bh bl ah al -- rh rl )
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  1 0 2 fsubd ,uint32
  2 r0 fmrdld ,uint32
  2 r1 fmrdhd ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-mul
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  1 0 2 fmuld ,uint32
  2 r0 fmrdld ,uint32
  2 r1 fmrdhd ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-div
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  1 0 2 fdivd ,uint32
  2 r0 fmrdld ,uint32
  2 r1 fmrdhd ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-negate
  0 r1 bit-set popr ,uint16
  r0 0 fmdlrd ,uint32
  r1 0 fmdhrd ,uint32
  0 2 fnegd ,uint32
  2 r0 fmrdld ,uint32
  2 r1 fmrdhd ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-sqrt
  0 r1 bit-set popr ,uint16
  r0 0 fmdlrd ,uint32
  r1 0 fmdhrd ,uint32
  0 2 fsqrtd ,uint32
  2 r0 fmrdld ,uint32
  2 r1 fmrdhd ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-abs
  0 r1 bit-set popr ,uint16
  r0 0 fmdlrd ,uint32
  r1 0 fmdhrd ,uint32
  0 2 fabsd ,uint32
  2 r0 fmrdld ,uint32
  2 r1 fmrdhd ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64-equals? ( ah al bh bl -- true? )
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  0 1 fcmpd ,uint32
  1 r15 fmrxs ,uint32
  ' beq emit-truther
  emit-next
endop

defop float64<=> ( ah al bh bl -- trival )
  0 r0 bit-set pushr ,uint16
  2 0 vpopnd ,uint32
  0 1 fcmpd ,uint32
  1 r15 fmrxs ,uint32
  emit-comparable-resulter
  emit-next
endop

defop float64-zero? ( ah al -- true? )
  0 r1 bit-set popr ,uint16
  r0 0 fmdlrd ,uint32
  r1 0 fmdhrd ,uint32
  0 fcmpzd ,uint32
  1 r15 fmrxs ,uint32
  ' beq emit-truther
  emit-next
endop

defop float64->uint32
  0 r1 bit-set popr ,uint16
  r0 0 fmdlrd ,uint32
  r1 0 fmdhrd ,uint32
  0 0 ftouizd ,uint32
  0 r0 fmrss ,uint32
  emit-next
endop

defop float64->int32
  0 r1 bit-set popr ,uint16
  r0 0 fmdlrd ,uint32
  r1 0 fmdhrd ,uint32
  0 0 ftosizd ,uint32
  0 r0 fmrss ,uint32
  emit-next
endop

defop uint32->float64 ( uint32 -- fh fl )
  r0 0 fmdlrd ,uint32
  0 r0 mov# ,uint16
  r0 0 fmdhrd ,uint32
  0 0 fuitod ,uint32
  0 r0 fmrdld ,uint32
  0 r1 fmrdhd ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop int32->float64
  r0 0 fmdlrd ,uint32
  0 r0 mov# ,uint16
  r0 0 fmdhrd ,uint32
  0 0 fsitod ,uint32
  0 r0 fmrdld ,uint32
  0 r1 fmrdhd ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop

defop float64->float32
  0 r1 bit-set popr ,uint16
  r0 0 fmdlrd ,uint32
  r1 0 fmdhrd ,uint32
  0 0 fcvtsd ,uint32
  0 r0 fmrss ,uint32
  emit-next
endop

defop float32->float64
  r0 0 fmsrs ,uint32
  0 0 fcvtds ,uint32
  0 r0 fmrdld ,uint32
  0 r1 fmrdhd ,uint32
  0 r1 bit-set pushr ,uint16
  emit-next
endop
