( Linux tlaps these according to https://www.kernel.org/doc/Documentation/arm64/cpu-feature-registers.txt )

defop aarch32-midr
  ( works in qemu )
  0 r0 bit-set pushr ,uint16
  0 0 0 0 0xF r0 mrc ,uint32
  emit-next
endop

defop cpuid-pfr0
  0 r0 bit-set pushr ,uint16
  r0 cpuid-pfr0 ,uint32
  emit-next
endop

defop cpuid-pfr1
  0 r0 bit-set pushr ,uint16
  r0 cpuid-pfr1 ,uint32
  emit-next
endop

defop cpuid-isa0
  0 r0 bit-set pushr ,uint16
  0 0 2 0 0xF r0 mrc ,uint32
  emit-next
endop

defop cpuid-isa1
  0 r0 bit-set pushr ,uint16
  0 0 2 1 0xF r0 mrc ,uint32
  emit-next
endop
