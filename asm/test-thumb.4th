8 r4 r0 mov-lsl ,uint16
16 r3 r1 mov-lsr ,uint16
16 r2 r2 mov-asr ,uint16

r2 r1 r0 add ,uint16
3 r3 r1 add .immed ,uint16

r2 r1 r0 sub ,uint16
3 r3 r1 sub .immed ,uint16

255 r2 mov# ,uint16
255 r2 cmp# ,uint16
127 r2 add# ,uint16
15 r2 sub# ,uint16

r2 r1 and ,uint16
r2 r1 eor ,uint16
r2 r1 lsl ,uint16
r2 r1 lsr ,uint16
r2 r1 asr ,uint16
r2 r1 adc ,uint16
r2 r1 sbc ,uint16
r2 r1 ror ,uint16
r2 r1 tst ,uint16
r2 r1 neg ,uint16
r2 r1 cmp ,uint16
r2 r1 cmn ,uint16
r2 r1 orr ,uint16
r2 r1 mul ,uint16
r2 r1 bic ,uint16
r2 r1 mvn ,uint16

r10 r2 add-hilo ,uint16
r2 r10 add-lohi ,uint16
r10 r11 add-hihi ,uint16

r10 r2 cmp-hilo ,uint16
r2 r10 cmp-lohi ,uint16
r10 r11 cmp-hihi ,uint16

r10 r2 mov-hilo ,uint16
r2 r10 mov-lohi ,uint16
r10 r11 mov-hihi ,uint16

r2 r3 bx-lo ,uint16
r10 r4 bx-hi ,uint16

123 r2 ldr-pc ,uint16

r3 r2 r1 str ,uint16
r3 r2 r1 str .byte ,uint16
r3 r2 r1 str-half ,uint16

r4 r3 r2 ldr ,uint16
r4 r3 r2 ldr .byte ,uint16
r3 r2 r1 ldr-half ,uint16
r3 r2 r1 ldsb ,uint16
r3 r2 r1 ldsh ,uint16

8 r2 r1 str-offset ,uint16
8 r2 r1 ldr-offset ,uint16

8 r2 r1 strh ,uint16
8 r2 r1 ldrh ,uint16

127 r2 str-sp ,uint16
127 r2 ldr-sp ,uint16

120 r2 add-pc ,uint16
121 r1 add-sp ,uint16

55 inc-sp ,uint16
45 dec-sp ,uint16

0xFF pushr ,uint16
0x80 pushr .pclr .uint16

0xFF popr ,uint16
0x80 popr .pclr .uint16

r2 0xFF stmia ,uint16
r3 0xFF ldmia ,uint16

0x1FF beq ,uint16
0x10 beq ,uint16
-0x10 beq ,uint16
0x3FF bvs ,uint16
0x10 bvs ,uint16
0x3FF ble ,uint16
0x10 ble ,uint16
0x10 bgt ,uint16

22 swi ,uint16

0x1FF branch ,uint16
0x10 branch ,uint16
-4 branch ,uint16

0x123456 dhere - 4 - branch-long ,uint32

0 ddump-binary-bytes