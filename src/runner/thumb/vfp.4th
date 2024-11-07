( VFP Floating point: )

( todo a flop and bin-flop code word that calls a smaller op in data.code words that assist inlining. )
( todo comparisons conditions without 1 or 0 on stack. )

defop vfpscr
  0 r0 bit-set pushr ,ins
  1 r0 fmrxs ,ins
  emit-next
endop

defop vfpscr! ( new-value -- )
  ( Only works in privileged mode. )
  r0 1 fmxrs ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop

( todo scr modes: rounding, vector, stride, traps; set on every op? )

defop vfpsid
  ( Only works in privileged mode. )
  0 r0 bit-set pushr ,ins
  0 r0 fmrxs ,ins
  emit-next
endop

defop vfpexc
  ( Only works in privileged mode. )
  0 r0 bit-set pushr ,ins
  8 r0 fmrxs ,ins
  emit-next
endop

( Single precision: )

defop float32-add
  r0 1 fmsrs ,ins
  2 vpop ,ins
  2 1 0 fadds ,ins
  0 r0 fmrss ,ins
  emit-next
endop

( todo vector operations: up to 4 floats. )
( todo need a way to xfer vectors tofrom banks, bank 0 is scalar )
( todo pop and push could be done in code word for each vector length )
( todo sqrt, exponent, fraction )
( todo vectors from pointer )
( todo fpscr not setting )

thumb2? IF
defop float32-add-2 ( a2 a1 b2 b1 -- r2 r1 )
  0 r0 bit-set pushr ,ins
  2 8 vpopn ,ins
  2 16 vpopn ,ins
  16 8 24 fadds ,ins
  2 24 vpushn ,ins
  0 r0 bit-set popr ,ins
  emit-next
endop
THEN

( Could factor these ops down to single instructions:
defop float32-load0
  r0 0 fmsrs ,ins
endop
defop float32-load1
  r0 1 fmsrs ,ins
endop
defop float32-add-102
  1 0 2 fadds ,ins
endop
defop float32-push-2
  2 r0 fmrss ,ins
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
  r0 1 fmsrs ,ins
  2 vpop ,ins
  2 1 0 fsubs ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop float32-mul
  r0 1 fmsrs ,ins
  2 vpop ,ins
  2 1 0 fmuls ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop float32-div
  r0 1 fmsrs ,ins
  2 vpop ,ins
  2 1 0 fdivs ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop float32-negate
  r0 1 fmsrs ,ins
  1 2 fnegs ,ins
  2 r0 fmrss ,ins
  emit-next
endop

defop float32-sqrt
  r0 1 fmsrs ,ins
  1 2 fsqrts ,ins
  2 r0 fmrss ,ins
  emit-next
endop

defop float32-abs
  r0 0 fmsrs ,ins
  0 2 fabss ,ins
  2 r0 fmrss ,ins
  emit-next
endop

defop float32-equals?
  r0 0 fmsrs ,ins
  2 vpop ,ins
  0 2 fcmps ,ins
  1 r15 fmrxs ,ins ( fixme to PC? )
  ' beq-ins emit-truther
  emit-next
endop

defop float32<=>
  r0 0 fmsrs ,ins
  2 vpop ,ins
  2 0 fcmps ,ins
  1 r15 fmrxs ,ins
  emit-comparable-resulter
  emit-next
endop

defop float32-zero?
  r0 0 fmsrs ,ins
  0 fcmpzs ,ins
  1 r15 fmrxs ,ins
  ' beq-ins emit-truther
  emit-next
endop

defop float32->uint32
  r0 0 fmsrs ,ins
  0 0 ftouizs ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop float32->uint32-rounded
  r0 0 fmsrs ,ins
  0 0 ftouis ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop uint32->float32
  r0 0 fmsrs ,ins
  0 0 fuitos ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop float32->int32
  r0 0 fmsrs ,ins
  0 0 ftosizs ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop float32->int32-rounded
  r0 1 fmsrs ,ins
  1 0 ftosis ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop int32->float32
  r0 2 fmsrs ,ins ( bit of a test of the asm word )
  2 0 fsitos ,ins
  0 r0 fmrss ,ins
  emit-next
endop

( Double precision: )

defop float64-add ( bh bl ah al -- rh rl )
  ( Could also do:
  0 r1 bit-set popr ,ins
  r0 0 fmdlrd ,ins
  r1 0 fmdhrd ,ins
  1 vpopd ,ins
  )
  0 r0 bit-set pushr ,ins
  2 0 vpopnd ,ins
  1 0 2 faddd ,ins
  2 r0 fmrdld ,ins
  2 r1 fmrdhd ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop float64-sub ( bh bl ah al -- rh rl )
  0 r0 bit-set pushr ,ins
  2 0 vpopnd ,ins
  1 0 2 fsubd ,ins
  2 r0 fmrdld ,ins
  2 r1 fmrdhd ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop float64-mul
  0 r0 bit-set pushr ,ins
  2 0 vpopnd ,ins
  1 0 2 fmuld ,ins
  2 r0 fmrdld ,ins
  2 r1 fmrdhd ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop float64-div
  0 r0 bit-set pushr ,ins
  2 0 vpopnd ,ins
  1 0 2 fdivd ,ins
  2 r0 fmrdld ,ins
  2 r1 fmrdhd ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop float64-negate
  0 r1 bit-set popr ,ins
  r0 0 fmdlrd ,ins
  r1 0 fmdhrd ,ins
  0 2 fnegd ,ins
  2 r0 fmrdld ,ins
  2 r1 fmrdhd ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop float64-sqrt
  0 r1 bit-set popr ,ins
  r0 0 fmdlrd ,ins
  r1 0 fmdhrd ,ins
  0 2 fsqrtd ,ins
  2 r0 fmrdld ,ins
  2 r1 fmrdhd ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop float64-abs
  0 r1 bit-set popr ,ins
  r0 0 fmdlrd ,ins
  r1 0 fmdhrd ,ins
  0 2 fabsd ,ins
  2 r0 fmrdld ,ins
  2 r1 fmrdhd ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop float64-equals? ( ah al bh bl -- true? )
  0 r0 bit-set pushr ,ins
  2 0 vpopnd ,ins
  0 1 fcmpd ,ins
  1 r15 fmrxs ,ins
  ' beq-ins emit-truther
  emit-next
endop

defop float64<=> ( ah al bh bl -- trival )
  0 r0 bit-set pushr ,ins
  2 0 vpopnd ,ins
  1 0 fcmpd ,ins
  1 r15 fmrxs ,ins
  emit-comparable-resulter
  emit-next
endop

defop float64-zero? ( ah al -- true? )
  0 r1 bit-set popr ,ins
  r0 0 fmdlrd ,ins
  r1 0 fmdhrd ,ins
  0 fcmpzd ,ins
  1 r15 fmrxs ,ins
  ' beq-ins emit-truther
  emit-next
endop

defop float64->uint32
  0 r1 bit-set popr ,ins
  r0 0 fmdlrd ,ins
  r1 0 fmdhrd ,ins
  0 0 ftouizd ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop float64->int32
  0 r1 bit-set popr ,ins
  r0 0 fmdlrd ,ins
  r1 0 fmdhrd ,ins
  0 0 ftosizd ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop uint32->float64 ( uint32 -- fh fl )
  r0 0 fmdlrd ,ins
  0 r0 mov# ,ins
  r0 0 fmdhrd ,ins
  0 0 fuitod ,ins
  0 r0 fmrdld ,ins
  0 r1 fmrdhd ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop int32->float64
  r0 0 fmdlrd ,ins
  0 r0 mov# ,ins
  r0 0 fmdhrd ,ins
  0 0 fsitod ,ins
  0 r0 fmrdld ,ins
  0 r1 fmrdhd ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defop float64->float32
  0 r1 bit-set popr ,ins
  r0 0 fmdlrd ,ins
  r1 0 fmdhrd ,ins
  0 0 fcvtsd ,ins
  0 r0 fmrss ,ins
  emit-next
endop

defop float32->float64
  r0 0 fmsrs ,ins
  0 0 fcvtds ,ins
  0 r0 fmrdld ,ins
  0 r1 fmrdhd ,ins
  0 r1 bit-set pushr ,ins
  emit-next
endop

defalias> float32 uint32
defalias> float64 uint64 ( fixme coming up undefined? )
