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
( todo detect which board this is on to dynamic set this: )

load-core
load-thumb-asm

0xFE000000 const> MMIO-BASE4 ( pi 4 )
0x3f000000 const> MMIO-BASE2 ( Pi 2+, Zero 2 )
0x20000000 const> MMIO-BASE1 ( Pi 1, Zero )
MMIO-BASE2 const> MMIO-BASE
dhere const> origin

( The Pi boots with:
  r0 = core, r1 = board id, r2 = atags, pc = 0x10000, lr = mailbox loop
)

( enter thumb by adding 1 to PC, for ARMs with Thumb2 )
( 0xE28FF001 ,uint32 ) ( 1 pc pc add a# )
( enter thumb by bx; more portable )
0xe1a0700f ,uint32 ( pc r7 mov )
0xe2877005 ,uint32 ( 5 r7 r7 add a# )
0xe12fff17 ,uint32 ( r7 branchx )
0x00000000 ,uint32 ( nop )

0x12 r3 mov# ,ins
0x34 r4 mov# ,ins

( read the CPU ID register )
( CRn Op1 CRm Op2 coproc Rxf mrc )
( MRC{cond} coproc, #opcode1, Rt, CRn, CRm{, #opcode2} )
( mrc p15,0,r4,c0,c0,0 )
( 0 0 0 0 15 r4 mrc ,ins )

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
origin dhere int-sub abs-int 4 int-add dec-sp ,ins

( setup hardware clock for uart0 )
( todo wait for empty mailbox )
( build an mbox request )
9 4 int-mul dec-sp ,ins
0 r6 mov# ,ins 32 r6 str-sp ,ins
0 r6 mov# ,ins 28 r6 str-sp ,ins
4000000 ( Hz ) r6 emit-load-int32 24 r6 str-sp ,ins
2 r6 mov# ,ins 20 r6 str-sp ,ins
8 r6 mov# ,ins 16 r6 str-sp ,ins
12 r6 mov# ,ins 12 r6 str-sp ,ins
0x38002 ( MBOX_TAG_SETCLKRATE ) r6 emit-load-int32 8 r6 str-sp ,ins
0 r6 mov# ,ins 4 r6 str-sp ,ins
9 4 int-mul r6 mov# ,ins 0 r6 str-sp ,ins

( send an mbox change property request )
sp r6 movrr ,ins
0xF r5 mov# ,ins
r5 r5 mvn ,ins
r5 r6 and ,ins
8 r6 add# ,ins

MMIO-BASE 0xB880 int-add r7 emit-load-int32
0x20 r7 r6 str-offset ,ins

( todo wait for response )
( drop msg from stack )
9 4 int-mul inc-sp ,ins

( load uart0's base address into r7 )
MMIO-BASE 0x201000 int-add r7 emit-load-int32

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

( todo map gpio pins )

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

( start each core at origin by writing to 0x4000008C + core offset.
  Core 2 +0x10, 3 +0x20, 4 +0x30. 4 int32 slots per core. )
MMIO-BASE MMIO-BASE2 equals? [IF]
  0x4000008C r6 emit-load-int32
  pc r5 movrr ,ins
  dhere origin int-sub 2 int-add r5 sub# ,ins
  r5 r10 movrr ,ins
  0x10 r6 r5 str-offset ,ins
  0x20 r6 r5 str-offset ,ins
  0x30 r6 r5 str-offset ,ins

  ( write a 'B' )
  66 r6 mov# ,ins
  0 r7 r6 str-offset ,ins
[THEN]

( secondary cores jump here. patch the jump: )
dhere punter int-sub 4 int-sub bne punter ins!

( divide memory below code by 8 to set SP to
  [origin - core * 2^12 ] )
pc r7 movrr ,ins
dhere origin int-sub 4 int-add r6 emit-load-int32
r6 r7 r7 sub ,ins
1 r6 mov# ,ins 12 r6 r6 mov-lsl ,ins
r0 r6 mul ,ins
r6 r7 r7 sub ,ins
r7 sp movrr ,ins

( load uart0's base address into r7 )
MMIO-BASE 0x201000 int-add r7 emit-load-int32

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

( Dump the assembled bytes to standard out. )
origin ddump-binary-bytes