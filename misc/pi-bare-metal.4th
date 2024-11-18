( A bare metal program using the Thumb assembler.
  It initializes UART0 and has each core write a byte.

  Helpful sites:
    - https://github.com/bztsrc/raspi3-tutorial/
    - https://github.com/dwelch67/raspberrypi

  Tested using:
    - Real hardware :: todo
    - Qemu raspi2 :: ~qemu-system-arm -M raspi2 -kernel misc/pi-bare-metal.bin -serial stdio~
    - Qemu raspi0 :: ~qemu-system-arm -M raspi0 -kernel misc/pi-bare-metal.bin -serial stdio~
)
( todo detect if Thumb2 is supported for coprocessor ops; adding 1 to PC only works on T2 devices. )
( todo proper uart init, enter interpreter, then start other cores, uart, interrupts, framebuffer, threading )

load-core

0xFE000000 const> MMIO-BASE4 ( pi 4 )
0x3f000000 const> MMIO-BASE2 ( Pi 2+, Zero 2 )
0x20000000 const> MMIO-BASE1 ( Pi 1, Zero )
' target-pi-zero defined? IF MMIO-BASE1 ELSE MMIO-BASE2 THEN var> MMIO-BASE
dhere const> origin

s[ src/lib/asm/aarch32/fake-thumb.4th ] load-list
s[ src/lib/asm/thumb.4th ] load-list

( The Pi boots with:
  r0 = core, r1 = board id, r2 = atags, pc = 0x10000, lr = mailbox loop
)

( enter thumb by adding 1 to PC, for ARMs with Thumb2 )
( 0xE28FF001 ,uint32 ) ( 1 pc pc add a# )
( enter thumb by bx; more portable )
' asm-aarch32-thumb defined? IF
  tmp" Generating aarch32 jump" error-line/2
  asm-aarch32-thumb push-mark

  pc r7 movrr ,ins
  9 r7 add# ,ins
  r7 bx ,ins
  thumb-nop ,ins

  pop-mark
ELSE
  0xe1a0700f ,uint32 ( pc r7 movrr )
  0xe2877009 ,uint32 ( 9 r7 add# )
  0xe12fff17 ,uint32 ( r7 bx )
  0x00000000 ,uint32 ( nop )
THEN

asm-thumb push-mark

(
0x12 r3 mov# ,ins
0x34 r4 mov# ,ins
)

( check if core is #0 )
0 r0 cmp# ,ins
( skip to putc )
dhere const> punter
0 ,ins ( replaced with a bne below )

( debugging sentinels )
0x13 r3 mov# ,ins
pc r8 movrr ,ins

( set SP to origin. grows down from origin. )
pc sp movrr ,ins
origin dhere - abs-int 4 + dec-sp ,ins

( detect and push the correct mmio base )
pc r0 movrr ,ins
7 r0 add# ,ins
r0 lr movrr ,ins
dhere const> branch-mmio-base
0 r0 addr-pc ,ins
r0 bx ,ins
0 r0 bit-set pushr ,ins

( read the CPU ID register )
( CRn Op1 CRm Op2 coproc Rxf mrc )
( MRC{cond} coproc, #opcode1, Rt, CRn, CRm{, #opcode2} )
( mrc p15,0,r4,c0,c0,0 )
( 0 0 0 0 15 r4 mrc ,ins )


( setup hardware clock for uart0 )
( todo wait for empty mailbox )
( build an mbox request )
9 4 * dec-sp ,ins
0 r6 mov# ,ins 32 r6 str-sp ,ins
0 r6 mov# ,ins 28 r6 str-sp ,ins
4000000 ( Hz ) r6 emit-load-int32 24 r6 str-sp ,ins
2 r6 mov# ,ins 20 r6 str-sp ,ins
8 r6 mov# ,ins 16 r6 str-sp ,ins
12 r6 mov# ,ins 12 r6 str-sp ,ins
0x38002 ( MBOX_TAG_SETCLKRATE ) r6 emit-load-int32 8 r6 str-sp ,ins
0 r6 mov# ,ins 4 r6 str-sp ,ins
9 4 * r6 mov# ,ins 0 r6 str-sp ,ins

( send an mbox change property request )
sp r6 movrr ,ins
0xF r5 mov# ,ins
r5 r5 mvn ,ins
r5 r6 and ,ins
8 r6 add# ,ins

9 4 * r0 ldr-sp ,ins
0xB880 r7 emit-load-uint32
r0 r7 addrr ,ins
0x20 r7 r6 str-offset ,ins

( todo wait for response )
( drop msg from stack )
9 4 * inc-sp ,ins

( load uart0's base address into r7 )
0x201000 r7 emit-load-int32
r0 r7 addrr ,ins

( set baud to 115200 )
1 r6 mov# ,ins
0x24 r7 r6 str-offset ,ins
40 r6 mov# ,ins
0x28 r7 r6 str-offset ,ins
0b111000 r6 mov# ,ins
0x2C r7 r6 str-offset ,ins
0b111 r6 mov# ,ins
8 r6 r6 mov-lsl ,ins
0b11111010 r6 add# ,ins
0x38 r7 r6 str-offset ,ins

( todo start an interpreter [that evals a boot string?] )
( todo write-char and read-char )
( todo map gpio pins )
( todo create framebuffer )

( enable uart0 for RX & TX )
0x3 r6 mov# ,ins
8 r6 r6 mov-lsl ,ins
0x01 r6 add# ,ins
0x30 r7 r6 str-offset ,ins

( write an 'A' )
65 r6 mov# ,ins
0 r7 r6 str-offset ,ins

( Start other cores )
( mrc	p15, 0, r4, c1, c0, 1		@ Read Auxiliary Control Register )
( orr	r1, r1, #1<<6			@ Enable SMP )
( mcr	p15, 0, r4, c1, c0, 1 )
( 1 0 0 1 15 r4 mrc ,ins
r4 r9 movrr ,ins
0x20 r5 mov# ,ins
r5 r4 orr ,ins
1 0 0 1 15 r4 mcr ,ins )

( mrrc	p15, 1, r1, r2, c15 )
( r2 15 1 15 r4 mrrc ,ins
r4 r9 movrr ,ins
0x20 r5 mov# ,ins
r5 r4 orr ,ins
r2 15 1 15 r4 mcrr ,ins )

( Only on Pi >1, start each core at origin by writing to 0x4000008C + core offset.
  Core 2 +0x10, 3 +0x20, 4 +0x30. 4 int32 slots per core. )
MMIO-BASE2 r1 emit-load-uint32
r1 r0 cmprr ,ins
dhere
0 bne ,ins

  0x4000008C r6 emit-load-int32
  pc r5 movrr ,ins
  dhere origin - 2 + r5 sub# ,ins
  r5 r10 movrr ,ins
  0x10 r6 r5 str-offset ,ins
  0x20 r6 r5 str-offset ,ins
  0x30 r6 r5 str-offset ,ins

  ( write a 'B' )
  66 r6 mov# ,ins
  0 r7 r6 str-offset ,ins

dhere over - 4 - bne swap ins!

0 r0 mov# ,ins ( fake core0 having r0 = 0 )

( secondary cores jump here. patch the jump: )
dhere punter - 4 - bne punter ins!

( divide memory below code by 8 to set SP to
  [origin - core * 2^12 ] )
pc r7 movrr ,ins
dhere origin - 4 + r6 emit-load-int32
r6 r7 r7 sub ,ins
1 r6 mov# ,ins 12 r6 r6 mov-lsl ,ins
r0 r6 mul ,ins
r6 r7 r7 sub ,ins
2 r7 r7 mov-lsr ,ins
2 r7 r7 mov-lsl ,ins
r7 sp movrr ,ins

( determine MMIO base on each core and place in R1 and ToS )
0 r0 bit-set pushr ,ins
pc r0 movrr ,ins
7 r0 add# ,ins
r0 lr movrr ,ins
dhere const> branch-mmio-base-2
0 r0 addr-pc ,ins
r0 bx ,ins
r0 r1 movrr ,ins
0 r0 bit-set popr ,ins
0 r1 bit-set pushr ,ins

( load uart0's base address into r7 )
0x201000 r7 emit-load-uint32
r1 r7 addrr ,ins

( wait for uart0 to be enabled )
0x30 r7 r6 ldr-offset ,ins
1 r5 mov# ,ins
r5 r6 and ,ins
0 r6 cmp# ,ins
-12 beq ,ins

( write ['I' + core] to the uart )
72 r6 mov# ,ins
r0 r6 adc ,ins
0 r7 r6 str-offset ,ins

( read the multi-processing register )
( CRn Op1 CRm Op2 coproc Rxf mrc )
( MRC{cond} coproc, #opcode1, Rt, CRn, CRm{, #opcode2} )
( mrc p15,0,r0,c0,c0,0 )
( 0 5 0 0 15 r5 mrc ,ins
0 0 0 5 15 r6 mrc ,ins
)

( idle loop. should wfe and watch mailboxes...jump back to LR? )
0 r0 r0 mov-lsl ,ins
-4 branch ,ins

( cpu ID:
3             0x410fd034
2b:      Main 0x410fc075  ISA0 2101110      ISA1 13112111
1, Zero: Main 0x410fb767  ISA0 140011       ISA1 12002111

Register list: https://forums.raspberrypi.com/viewtopic.php?t=126891
)
4 pad-data
dhere branch-mmio-base - r0 addr-pc branch-mmio-base ins!
dhere branch-mmio-base-2 - r0 addr-pc branch-mmio-base-2 ins!

( Zero lacks thumb2. )
asm-aarch32-thumb push-mark
  0 0 0 r3 0 0xF mrc ,ins ( main ID )
  ( [[midr >> 12] & 0xF - 0xB] * 4 )
  12 r3 r0 mov-lsr ,ins
  0xF r1 mov# ,ins
  r1 r0 and ,ins
  0xB r0 sub# ,ins
  2 r0 r0 mov-lsl ,ins
dhere
  0 r1 addr-pc ,ins
  r0 r1 r0 ldr ,ins
  lr bx ,ins

dhere over - 8 - r1 addr-pc swap ins!
MMIO-BASE1 ,uint32
MMIO-BASE2 ,uint32
MMIO-BASE4 ,uint32

pop-mark

( Dump the assembled bytes to standard out. )
origin ddump-binary-bytes
pop-mark
