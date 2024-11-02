' ,ins defined? UNLESS
  " src/lib/asm/aarch32.4th" load
THEN

dhere const> mark

r7 r2 r3 and ,ins
r7 r2 r3 eor ,ins
r7 r2 r3 sub ,ins
r7 r2 r3 rsm ,ins
r1 r7 r3 add ,ins
r1 r7 r3 adc ,ins
r1 r2 r7 sbc ,ins
r1 r2 r7 rsc ,ins
r1 r2 r3 tst ,ins
r1 r2 r3 teq ,ins
r1 r2 r3 cmp ,ins
r1 r2 r3 cmn ,ins
r1 r2 r3 orr ,ins
r1 r2 r3 mov ,ins
r1 r2 r3 bic ,ins
r1 r2 r3 mvn ,ins

nop ,ins
nop ,ins

r1 r2 0 1 immed-op and ,ins
r1 r2 0 15 immed-op and .i ,ins
r1 r2 4 15 immed-op and .i ,ins
r1 r2 16 123 immed-op and .i ,ins

r1 r2 3 BARREL-BSL immed-shift r3 reg-op add ,ins
r1 r2 4 BARREL-BSR immed-shift r3 reg-op add ,ins
r1 r2 5 BARREL-ASR immed-shift r3 reg-op add ,ins
r1 r2 6 BARREL-RSR immed-shift r3 reg-op add ,ins

r1 r2 r4 BARREL-BSL reg-shift r3 reg-op adc ,ins
r1 r2 r5 BARREL-BSR reg-shift r3 reg-op adc ,ins
r1 r2 r6 BARREL-ASR reg-shift r3 reg-op adc ,ins
r1 r2 r7 BARREL-RSR reg-shift r3 reg-op adc ,ins

r1 r2 0 r3 reg-op sbc ,ins
r1 r2 1 r3 reg-op sbc ,ins
r1 r2 2 r3 reg-op sbc ,ins
r1 r2 3 r3 reg-op sbc ,ins

r1 r2 2 BARREL-BSL immed-shift r3 reg-op eor ,ins
r1 r2 r3 BARREL-BSR reg-shift r3 reg-op eor ,ins

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

r1 r2 r3 r4 mul ,ins
r1 r2 r3 r4 mul .a ,ins
r1 r2 r3 r4 mla ,ins
r1 r2 r3 r4 mul .s ,ins
r1 r2 r3 r4 muls ,ins

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

nop ,ins
nop ,ins

r1 r2 r3 strh ,ins
r1 r2 r3 ldrh ,ins

r1 r2 r3 ldrsb ,ins
r1 r2 r3 ldrsh ,ins

r1 r2 r3 ldrsb .up ,ins
r1 r2 r3 ldrsh .up ,ins

r1 r2 15 strhi ,ins
r1 r2 15 ldrhi ,ins

r1 r2 15 strhi .up ,ins
r1 r2 15 ldrhi .up ,ins

r1 r2 64 ldrsbi ,ins
r1 r2 100 ldrshi ,ins

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

r1 r2 r3 str ,ins
r1 r2 r3 ldr ,ins

nop ,ins
nop ,ins

r1 0xFFFF stm ,ins
r2 0xFFFF ldm ,ins

nop ,ins
nop ,ins

123 b ,ins
-123 bl ,ins

nop ,ins
nop ,ins

r1 2 3 0x77 stc ,ins
r1 2 3 0x77 stc ,ins

r1 2 11 0x77 ldc ,ins
r1 2 11 0x77 ldc ,ins

1 2 3 4 5 6 cdp ,ins
1 2 3 11 5 6 cdp ,ins

1 2 3 4 5 6 mrc ,ins
1 2 3 11 5 6 mrc ,ins

1 2 3 4 5 6 mcr ,ins
1 2 3 11 5 6 mcr ,ins

nop ,ins
nop ,ins

0x1234 swi ,ins

mark ddump-binary-bytes
