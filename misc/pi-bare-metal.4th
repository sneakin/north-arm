load-core
load-thumb-asm

dhere const> origin

( ~qemu-system-arm -M raspi2 -kernel kernel-boot.bin -monitor stdio~ boots with:
  r0 = core, r1 = board id, r2 = atags, pc = 0x10000, lr = mailbox loop
)

( a32 branch to PC+1 to enter thumb )
( arm:asm[ 1 a# pc pc add , nop ] )
0xE28FF001 ,uint32
0x00000000 ,uint32

0x12 r3 mov# ,ins

( check if core is #0 )
0 r0 cmp# ,ins
( 0 beq ,ins
lr pc mov-hihi ,ins )
( skip to putc )
dhere const> punter
0 ,ins

( 0x48 bne ,ins )

0x13 r3 mov# ,ins

( Start other cores )
( mrc	p15, 0, r4, c1, c0, 1		@ Read Auxiliary Control Register )
( orr	r1, r1, #1<<6			@ Enable SMP )
( mcr	p15, 0, r4, c1, c0, 1 )
( 1 0 0 1 15 r4 mrc ,ins
r4 r9 mov-lohi ,ins
0x20 r5 mov# ,ins
r5 r4 orr ,ins
1 0 0 1 15 r4 mcr ,ins )

( mrrc	p15, 1, r1, r2, c15 )
( r2 15 1 15 r4 mrrc ,ins
r4 r9 mov-lohi ,ins
0x20 r5 mov# ,ins
r5 r4 orr ,ins
r2 15 1 15 r4 mcrr ,ins )

( start each core by writing the desired PC to 0x4000009C. Core 2 is 0x40..AC. 4 int32 slots per core. )
0x4000008C r4 emit-load-int32
pc r5 mov-hilo ,ins
dhere origin int-sub 2 int-add r5 sub# ,ins
r5 r10 mov-lohi ,ins
0x10 r4 r5 str-offset ,ins
0x20 r4 r5 str-offset ,ins
0x30 r4 r5 str-offset ,ins

( Shut off extra cores by jumping to a loop )
( mrc p15, 0, r4, c0, c0, 5 )
(
0 0 0 5 15 r4 mrc ,ins
3 r5 mov# ,ins
r4 r5 and ,ins
0 r5 cmp# ,ins
8 bne ,ins
)

0x12 r6 mov# ,ins
0x34 r7 mov# ,ins
pc r8 mov-hihi ,ins

( load uart0's base address into r7 )
0x3f201000 r7 emit-load-int32

( set baud )
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

( enable uart0 )
0x3 r6 mov# ,ins
8 r6 r6 mov-lsl ,ins
0x01 r6 add# ,ins
0x30 r7 r6 str-offset ,ins

( secondary cores jump here. patch the jump:: )
dhere origin int-sub 16 int-sub bne punter ins!

( set SP to origin on down )
pc sp mov-hihi ,ins
origin dhere int-sub abs-int 4 + dec-sp ,ins

( load uart0's base address into r7 )
0x3f201000 r7 emit-load-int32
( write a byte to the uart )
72 r6 mov# ,ins
r0 r6 adc ,ins
0 r7 r6 str-offset ,ins

( read the multi-processing register )
0 0 0 5 15 r4 mrc ,ins

( idle loop. should wfe and watch mailboxes...jump back to LR? )
( -6 branch ,ins )
-4 branch ,ins

( todo proper uart init, enter interpreter, then start other cores, uart, interrupts, framebuffer, threading )

origin ddump-binary-bytes