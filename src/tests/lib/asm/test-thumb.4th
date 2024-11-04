dhere const> origin

tmp" mov" error-line/2

8 r4 r0 mov-lsl ,ins
16 r3 r1 mov-lsr ,ins
16 r2 r2 mov-asr ,ins

tmp" Math" error-line/2

r2 r1 r0 add ,ins
3 r3 r1 add .immed ,ins

r2 r1 r0 sub ,ins
3 r3 r1 sub .immed ,ins

tmp" immediates" error-line/2

255 r2 mov# ,ins
255 r2 cmp# ,ins
127 r2 add# ,ins
15 r2 sub# ,ins

tmp" Data ops" error-line/2

r2 r1 and ,ins
r2 r1 eor ,ins
r2 r1 lsl ,ins
r2 r1 lsr ,ins
r2 r1 asr ,ins
r2 r1 adc ,ins
r2 r1 sbc ,ins
r2 r1 ror ,ins
r2 r1 tst ,ins
r2 r1 neg ,ins
r2 r1 cmp ,ins
r2 r1 cmn ,ins
r2 r1 orr ,ins
r2 r1 mul ,ins
r2 r1 bic ,ins
r2 r1 mvn ,ins

tmp" Hilo" error-line/2

r10 r2 add-hilo ,ins
r2 r10 add-lohi ,ins
r10 r11 add-hihi ,ins
r10 r11 addrr ,ins

tmp" Cmp Hilo" error-line/2

r10 r2 cmp-hilo ,ins
r2 r10 cmp-lohi ,ins
r10 r11 cmp-hihi ,ins
r10 r11 cmprr ,ins

r10 r2 mov-hilo ,ins
r2 r10 mov-lohi ,ins
r10 r11 mov-hihi ,ins
r10 r11 movrr ,ins

tmp" Branch" error-line/2

r2 0 bx-lo ,ins
r10 0 bx-hi ,ins
r10 bx ,ins

tmp" Load" error-line/2

123 r2 ldr-pc ,ins

r3 r2 r1 str ,ins
r3 r2 r1 str .byte ,ins
r3 r2 r1 str-half ,ins

r4 r3 r2 ldr ,ins
r4 r3 r2 ldr .byte ,ins
r3 r2 r1 ldr-half ,ins
r3 r2 r1 ldsb ,ins
r3 r2 r1 ldsh ,ins

8 r2 r1 str-offset ,ins
8 r2 r1 ldr-offset ,ins

8 r2 r1 strh ,ins
8 r2 r1 ldrh ,ins

127 r2 str-sp ,ins
127 r2 ldr-sp ,ins

120 r2 addr-pc ,ins
121 r1 addr-sp ,ins

55 inc-sp ,ins
45 dec-sp ,ins

0xFF pushr ,ins
0x80 pushr .pclr ,ins

0xFF popr ,ins
0x80 popr .pclr ,ins

r2 0xFF stmia ,ins
r3 0xFF ldmia ,ins

0x1FF beq ,ins
0x10 beq ,ins
-0x10 beq ,ins
0x3FF bvs ,ins
0x10 bvs ,ins
0x3FF ble ,ins
0x10 ble ,ins
0x10 bgt ,ins

22 swi ,ins

0x1FF branch ,ins
0x10 branch ,ins
-4 branch ,ins

0x123456 dhere - 4 - branch-link ,uint32

0 r1 emit-load-int32
1 r2 emit-load-int32
0xFF r3 emit-load-int32
0xFFFF r4 emit-load-int32
0xFF0000 r5 emit-load-int32
-1 r6 emit-load-int32

origin ddump-binary-bytes
