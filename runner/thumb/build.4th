forth/compiler.4th load
asm/words.4th load
asm/byte-data.4th load
asm/thumb.4th load
elf/stub32.4th load
runner/thumb/words.4th load

write-elf32-header
dhere

pc r3 mov-hilo ,uint16
4 r0 ldr-pc ,uint16
r0 r3 r5 add ,uint16
r0 pc add-lohi ,uint16
0xBEEFBEEF ,uint32

runner/thumb/ops.4th load
runner/thumb/init.4th load

( todo needs to branch to code's seq )
op-init dict-entry-size + over - 8 - .s over 8 + uint32!

( todo load itself into dictionary )

dup 1 + write-elf32-ending

0 ddump-binary-bytes
dhere .s
