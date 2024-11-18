s[
  src/lib/bit-fields.4th
] load-list

mark> pre-asm-thumb

s[ src/lib/asm/thumb/v1.4th
   src/lib/asm/thumb/v2.4th
   src/lib/asm/thumb/vfp.4th
] load-list

pre-asm-thumb push-mark> asm-thumb
: push-asm-mark asm-thumb push-mark ;
