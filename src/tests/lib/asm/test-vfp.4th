load-core load-thumb-asm

dhere .s
1 2 3 4 stc ,uint32
1 2 3 4 ldc ,uint32
1 2 3 4 ldc coproc-p ,uint32

0 0 0 fsts ,uint32
32 r1 3 fsts ,uint32
-32 r1 3 fsts ,uint32
1023 r1 3 fsts ,uint32
-1023 r1 3 fsts ,uint32

0 0 0 fsts+ ,uint32
1 r1 3 fsts+ ,uint32
2 r1 2 fsts+ ,uint32
3 r1 1 fsts+ ,uint32
-8 r6 1 fsts+ ,uint32
8 r6 1 fsts+ ,uint32
-8 r6 1 fsts- ,uint32
8 r6 1 fsts- ,uint32
16 r6 1 fsts+ ,uint32
-16 r6 1 fsts+ ,uint32
255 r1 2 fsts+ ,uint32

nop ,uint16
0 0 0 flds- ,uint32
-4 3 r4 flds- ,uint32
4 3 r4 flds- ,uint32
-4 3 r4 flds+ ,uint32
4 3 r4 flds+ ,uint32
.s
nop ,uint16
0 0 0 fstms ,uint32
3 2 8 fstms ,uint32
3 2 8 fstms+ ,uint32
3 2 8 fstms- ,uint32

0 0 0 fldms ,uint32
3 2 8 fldms ,uint32
3 2 8 fldms+ ,uint32
3 2 8 fldms- ,uint32
.s
nop ,uint16
0 0 0 fstd+ ,uint32
1 r1 2 fstd+ ,uint32
2 r1 2 fstd+ ,uint32
-4 r1 2 fstd+ ,uint32
32 0 0 fstd ,uint32
-32 2 4 fstd ,uint32

nop ,uint16
-4 r3 4 fldd+ ,uint32
4 r3 4 fldd+ ,uint32
-4 r3 4 fldd- ,uint32
4 r3 4 fldd- ,uint32
0 r0 0 fldd+ ,uint32
32 0 0 fldd ,uint32
-32 2 4 fldd ,uint32

0 r0 0 fldmd ,uint32
1 r1 0 fstmd ,uint32
1 r2 1 fstmd ,uint32
2 r3 0 fstmd ,uint32
2 r4 1 fstmd ,uint32
4 r5 0 fstmd ,uint32
4 r6 1 fstmd ,uint32
4 r6 1 fstmd+ ,uint32
4 r6 1 fstmd- ,uint32

nop ,uint16
1 1 0 fldmx ,uint32
2 1 3 fldmx+ ,uint32
3 1 3 fldmx- ,uint32
1 0 0 fldmx+ ,uint32
4 0 2 fldmx+ ,uint32

.s ddump-binary-bytes