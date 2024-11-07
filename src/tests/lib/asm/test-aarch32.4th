' ,ins defined? UNLESS
  " src/lib/asm/aarch32.4th" load
THEN

dhere const> mark

r7 r2 r3 and ,ins
4 BARREL-BSL immed-shift r1 r2 r3 andr ,ins
r2 BARREL-BSL reg-shift r1 r2 r3 andr ,ins
16 16 r2 r3 and# ,ins

r7 r2 r3 eor ,ins
4 BARREL-BSL immed-shift r1 r2 r3 eorr ,ins
r2 BARREL-BSL reg-shift r1 r2 r3 eorr ,ins
16 16 r2 r3 eor# ,ins

r7 r2 r3 sub ,ins
r7 r2 r3 rsm ,ins
r1 r7 r3 add ,ins
r1 r7 r3 adc ,ins
r1 r2 r7 sbc ,ins
r1 r2 r7 rsc ,ins
r1 r2 tst ,ins
r1 r2 teq ,ins
r1 r2 cmp ,ins
r1 r2 cmn ,ins
r1 r2 r3 orr ,ins
r1 r2 mov ,ins
12 16 r1 r2 mov# ,ins
0 BARREL-BSL immed-shift r1 r2 movr ,ins
r1 r2 r3 bic ,ins
r1 r2 mvn ,ins

nop ,ins
nop ,ins

0 1 immed-op r1 r2 and ,ins
0 15 immed-op r1 r2 and .i ,ins
4 15 immed-op r1 r2 and .i ,ins
16 123 immed-op r1 r2 and .i ,ins

16 123 r1 r2 and# ,ins
16 123 r1 r2 add# ,ins

3 BARREL-BSL immed-shift r3 reg-op r1 r2 add ,ins
4 BARREL-BSR immed-shift r3 reg-op r1 r2 add ,ins
5 BARREL-ASR immed-shift r3 reg-op r1 r2 add ,ins
6 BARREL-RSR immed-shift r3 reg-op r1 r2 add ,ins

6 BARREL-RSR immed-shift r3 r1 r2 addr ,ins

r4 BARREL-BSL reg-shift r3 reg-op r1 r2 adc ,ins
r5 BARREL-BSR reg-shift r3 reg-op r1 r2 adc ,ins
r6 BARREL-ASR reg-shift r3 reg-op r1 r2 adc ,ins
r7 BARREL-RSR reg-shift r3 reg-op r1 r2 adc ,ins

r7 BARREL-RSR reg-shift r3 r1 r2 adcr ,ins

0 r3 reg-op r1 r2 sbc ,ins
1 r3 reg-op r1 r2 sbc ,ins
2 r3 reg-op r1 r2 sbc ,ins
3 r3 reg-op r1 r2 sbc ,ins

3 r3 r1 r2 sbcr ,ins

2 BARREL-BSL immed-shift r3 reg-op r1 r2 eor ,ins
r3 BARREL-BSR reg-shift r3 reg-op r1 r2 eor ,ins

2 BARREL-BSL immed-shift r3 r1 r2 eorr ,ins
r3 BARREL-BSR reg-shift r3 r1 r2 eorr ,ins

nop ,ins
nop ,ins

r8 r9 r10 and ,ins
r8 r9 r11 and .eq ,ins
r8 r9 r12 and .ne ,ins
r8 r9 r13 and .cs ,ins
r8 r9 r14 and .cc ,ins
r8 r9 r15 and .mi ,ins
r8 r9 r10 and .pl ,ins
r8 r9 r10 and .vs ,ins
r8 r9 r10 and .vc ,ins
r8 r9 r10 and .hi ,ins
r8 r9 r10 and .ls ,ins
r8 r9 r10 and .ge ,ins
r8 r9 r10 and .lt ,ins
r8 r9 r10 and .gt ,ins
r8 r9 r10 and .le ,ins
r8 r9 r10 and .al ,ins

nop ,ins
nop ,ins

r1 r2 r3 mul ,ins
r3 r2 r1 mul ,ins
r1 r2 r3 mul .a ,ins
r1 r2 r3 r4 mul/4 .a ,ins
r1 r2 r3 r4 mla ,ins
r1 r2 r3 mul .set ,ins
r1 r2 r3 muls ,ins

nop ,ins
nop ,ins

r1 r2 r3 r4 umull ,ins
r1 r2 r3 r4 umull .signed ,ins
r1 r2 r3 r4 smull ,ins
r1 r2 r3 r4 umulls ,ins
r1 r2 r3 r4 smulls ,ins

nop ,ins
nop ,ins

r1 r2 r3 r4 smull ,ins
r1 r2 r3 r4 smull .a ,ins
r1 r2 r3 r4 smlal ,ins
r1 r2 r3 r4 smulls ,ins

nop ,ins
nop ,ins

r1 bx ,ins
r2 bx ,ins
lr bx ,ins

nop ,ins
nop ,ins

r1 r2 r3 strh ,ins
r1 r2 r3 ldrh ,ins

r1 negate r2 r3 strh ,ins
r1 negate r2 r3 ldrh ,ins

r1 r2 r3 ldrsb ,ins
r1 r2 r3 ldrsh ,ins

r1 r2 r3 ldrsb .up ,ins
r1 r2 r3 ldrsh .up ,ins

-15 r1 r2 strhi ,ins
-15 r1 r2 ldrhi ,ins

15 r1 r2 strhi .up ,ins
15 r1 r2 ldrhi .up ,ins

15 r1 r2 strhi ,ins
15 r1 r2 ldrhi ,ins

64 r1 r2 ldrsbi ,ins
100 r1 r2 ldrshi ,ins

nop ,ins
nop ,ins

r1 r2 r3 swp ,ins
r1 r2 r3 swp .b ,ins
r1 r2 r3 swpi ,ins ( fixme )
r1 r2 r3 swpi .b ,ins

nop ,ins
nop ,ins

r2 mrs ,ins
r3 mrsp ,ins

r3 msr ,ins
r5 msr .spsr ,ins

r3 BARREL-BSR reg-shift r3 reg-op msri ,ins
r3 BARREL-BSR reg-shift r3 reg-op msri .spsr ,ins

0 23 immed-op msri .i ,ins
16 23 immed-op msri .i .spsr ,ins
 
nop ,ins
nop ,ins

23 r1 r2 str# ,ins
23 r1 r2 ldr# .up ,ins

0 r3 reg-op r1 r2 str ,ins
0 r3 reg-op r1 r2 ldr ,ins

nop ,ins
nop ,ins

0xFFFF r1 stm ,ins
0xFFFF r2 ldm ,ins

nop ,ins
nop ,ins

123 b ,ins
-123 bl ,ins

nop ,ins
nop ,ins

0x77 r1 2 3 stc ,ins
0x7 r1 2 10 stc ,ins
0x7 r1 2 10 stc .up ,ins
0x7 r1 3 10 stc .up ,ins

0x77 r1 2 3 ldc ,ins
0x7 r1 2 10 ldc ,ins
0x7 r1 2 10 ldc .up ,ins
0x7 r1 3 10 ldc .up ,ins

1 2 3 4 5 6 cdp ,ins
1 2 3 4 5 1 cdp ,ins
1 2 3 4 5 10 cdp ,ins

1 2 3 4 5 6 mrc ,ins
1 2 3 4 5 1 mrc ,ins
1 2 3 4 5 10 mrc ,ins

1 2 3 4 5 6 mcr ,ins
1 2 3 4 5 1 mcr ,ins
1 2 3 4 5 10 mcr ,ins

nop ,ins
nop ,ins

0x1234 swi ,ins
-123 swi ,ins

0x1234 bkpt/1 ,ins
-1 bkpt/1 ,ins
bkpt ,ins

nop ,ins
nop ,ins

r3 dropr ,ins
r10 dropr ,ins

r3 r4 popr ,ins
r10 r2 popr ,ins

r2 r4 pushr ,ins
r3 r5 pushr ,ins

r3 pop ,ins
r4 push ,ins

mark ddump-binary-bytes
