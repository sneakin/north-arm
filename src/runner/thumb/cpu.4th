( Linux traps these according to https://www.kernel.org/doc/Documentation/arm64/cpu-feature-registers.txt )

defop push-cpsr
  0 r0 bit-set pushr ,ins
  r0 mrs ,ins
  emit-next
endop

defop push-spsr
  0 r0 bit-set pushr ,ins
  r0 mrs .spsr ,ins
  emit-next
endop

defop aarch32-midr
  ( works in qemu )
  0 r0 bit-set pushr ,ins
  r0 cpuid-midr ,ins
  emit-next
endop

defop aarch32-acr
  ( works in qemu )
  0 r0 bit-set pushr ,ins
  2 0 1 r0 0 0xF mrc ,ins
  emit-next
endop

defop cpuid-pfr0
  0 r0 bit-set pushr ,ins
  r0 cpuid-pfr0 ,ins
  emit-next
endop

defop cpuid-pfr1
  0 r0 bit-set pushr ,ins
  r0 cpuid-pfr1 ,ins
  emit-next
endop

defop cpuid-isa0
  0 r0 bit-set pushr ,ins
  0 2 0 r0 0 0xF mrc ,ins
  emit-next
endop

defop cpuid-isa1
  0 r0 bit-set pushr ,ins
  1 2 0 r0 0 0xF mrc ,ins
  emit-next
endop
