load-core
load-thumb-asm

dhere const> origin

0x1 bw ,uint32
0x2 bw ,uint32
0x4 bw ,uint32
0x10 bw ,uint32
0x1234 bw ,uint32
0xFFF bw ,uint32
0xFFFF bw ,uint32
0xFFFFF bw ,uint32
-0x1 bw ,uint32
-0x2 bw ,uint32
-0x4 bw ,uint32
-0x10 bw ,uint32
-0x1234 bw ,uint32
-0xFFF bw ,uint32
-0xFFFF bw ,uint32
-0xFFFFF bw ,uint32

0 r0 ldr-pc.w ,uint32
0 r7 ldr-pc.w ,uint32
0 sp ldr-pc.w ,uint32
0 pc ldr-pc.w ,uint32
4 r0 ldr-pc.w ,uint32
8 r7 ldr-pc.w ,uint32
0x100 sp ldr-pc.w ,uint32
0xFFFFF pc ldr-pc.w ,uint32
-4 r0 ldr-pc.w ,uint32
-8 r7 ldr-pc.w ,uint32
-0x100 sp ldr-pc.w ,uint32
-0xFFFFF pc ldr-pc.w ,uint32

r3 mrs ,ins
ip mrs .spsr ,ins

: each-msr ( n -- )
  dup 16 int< IF
    dup dup msr ,ins
    dup dup msr .spsr ,ins
    1 + loop
  ELSE
    drop
  THEN
;

0 each-msr

origin ddump-binary-bytes