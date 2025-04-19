s[ src/lib/bit-fields.4th
   src/lib/map/stack.4th
   src/cross/sys-aliases.4th
   src/interp/boot/cross.4th
   src/cross/defining/endop.4th
   src/lib/elf/stub32.4th
   src/lib/elf/stub32-dynamic.4th
   src/lib/elf/stub64.4th
   src/lib/elf/stub.4th
] load-list

SYS:DEFINED? NORTH-COMPILE-TIME IF
  s[ src/lib/asm/thumb.4th
     src/lib/asm/aarch32/fake-thumb.4th
     src/lib/asm/x86.4th
  ] load-list
ELSE
  target-thumb? IF s" src/lib/asm/thumb.4th" load/2 THEN
  target-aarch32? IF s" src/lib/asm/aarch32/fake-thumb.4th" load/2 THEN
  target-x86? IF s" src/lib/asm/x86.4th" load/2 THEN
THEN

s[ src/cross/builder/marks.4th
   src/cross/defining/op.4th
   src/cross/defining/alias.4th
] load-list
