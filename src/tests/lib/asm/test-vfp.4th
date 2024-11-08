' mov-lsl defined? UNLESS
  " src/lib/asm/thumb.4th" load
THEN

dhere .s
1 2 3 4 stc ,ins
1 2 3 4 ldc ,ins
1 2 3 4 ldc coproc-p ,ins

0 0 0 fsts ,ins
32 r1 3 fsts ,ins
-32 r1 3 fsts ,ins
1023 r1 3 fsts ,ins
-1023 r1 3 fsts ,ins

0 0 0 fsts+ ,ins
1 r1 3 fsts+ ,ins
2 r1 2 fsts+ ,ins
3 r1 1 fsts+ ,ins
-8 r6 1 fsts+ ,ins
8 r6 1 fsts+ ,ins
-8 r6 1 fsts- ,ins
8 r6 1 fsts- ,ins
16 r6 1 fsts+ ,ins
-16 r6 1 fsts+ ,ins
255 r1 2 fsts+ ,ins

thumb-nop ,ins
thumb-nop ,ins

0 0 0 flds- ,ins
-4 3 r4 flds- ,ins
4 3 r4 flds- ,ins
-4 3 r4 flds+ ,ins
4 3 r4 flds+ ,ins

thumb-nop ,ins
thumb-nop ,ins

0 0 0 fstms ,ins
3 2 8 fstms ,ins
3 2 8 fstms+ ,ins
3 2 8 fstms- ,ins

0 0 0 fldms ,ins
3 2 8 fldms ,ins
3 2 8 fldms+ ,ins
3 2 8 fldms- ,ins

thumb-nop ,ins
thumb-nop ,ins

0 0 0 fstd+ ,ins
1 r1 2 fstd+ ,ins
2 r1 2 fstd+ ,ins
-4 r1 2 fstd+ ,ins
32 0 0 fstd ,ins
-32 2 4 fstd ,ins

thumb-nop ,ins
thumb-nop ,ins

-4 r3 4 fldd+ ,ins
4 r3 4 fldd+ ,ins
-4 r3 4 fldd- ,ins
4 r3 4 fldd- ,ins
0 r0 0 fldd+ ,ins
32 0 0 fldd ,ins
-32 2 4 fldd ,ins

0 r0 0 fldmd ,ins
1 r1 0 fstmd ,ins
1 r2 1 fstmd ,ins
2 r3 0 fstmd ,ins
2 r4 1 fstmd ,ins
4 r5 0 fstmd ,ins
4 r6 1 fstmd ,ins
4 r6 1 fstmd+ ,ins
4 r6 1 fstmd- ,ins

thumb-nop ,ins
thumb-nop ,ins

1 1 0 fldmx ,ins
2 1 3 fldmx+ ,ins
3 1 3 fldmx- ,ins
1 0 0 fldmx+ ,ins
4 0 2 fldmx+ ,ins

thumb-nop ,ins
thumb-nop ,ins

1 2 3 fadds ,ins
4 5 6 fsubs ,ins
7 8 9 fmuls ,ins
10 11 12 fdivs ,ins
13 14 fnegs ,ins
1 2 fsqrts ,ins
3 4 fcpys ,ins
5 6 fabss ,ins
7 8 fcmps ,ins
9 fcmpzs ,ins

thumb-nop ,ins
thumb-nop ,ins

1 2 3 faddd ,ins
4 5 6 fsubd ,ins
7 8 9 fmuld ,ins
10 11 12 fdivd ,ins
13 14 fnegd ,ins
1 2 fsqrtd ,ins
3 4 fcpyd ,ins
5 6 fabsd ,ins
7 8 fcmpd ,ins
9 fcmpzd ,ins

thumb-nop ,ins
thumb-nop ,ins

1 2 fuitos ,ins
3 4 fsitos ,ins
5 6 ftouis ,ins
7 8 ftouizs ,ins
9 10 ftosis ,ins
11 12 ftosizs ,ins
13 14 fcvtds ,ins

thumb-nop ,ins
thumb-nop ,ins

1 2 fmdlrd ,ins
3 4 fmrdld ,ins
5 6 fmdhrd ,ins
7 8 fmrdhd ,ins
9 10 ftosis ,ins
11 12 ftosizs ,ins
13 14 fcvtds ,ins
3 4 fcvtds ,ins

thumb-nop ,ins
thumb-nop ,ins

1 2 ftouid ,ins
3 4 ftouizd ,ins
5 6 ftosid ,ins
7 8 ftosizd ,ins
9 10 fuitod ,ins
11 12 fsitod ,ins
13 14 fcvtsd ,ins

.s ddump-binary-bytes