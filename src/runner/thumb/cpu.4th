defop aarch32-midr
  ( works in qemu )
  0 r0 bit-set pushr ,uint16
  0 0 0 0 0xF r0 mrc ,uint32
  emit-next
endop
