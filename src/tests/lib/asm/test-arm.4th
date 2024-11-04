dhere const> mark

( Data processing: )

( ADDEQR2,R4,R5 ; If the Z flag is set make R2:=R4+R5 )
r5 r4 r2 add .eq ,uint32

( ADDAL R2,R3,#100 )
100 a# r3 r2 add .al ,uint32

( ADD R2,R3,#100 )
100 a# r3 r2 add ,uint32

( TEQSR4,#3 ; test R4 for equality with 3. The S is in fact redundant as the assembler inserts it automatically.
)
3 a# r4 teq a.s ,uint32

( Operand bit shifting: )

( SUB R4,R5,R7,LSR R2 ; Logical right shift R7 by the number in the bottom byte of R2, subtract result from R5, and put the answer into R4. )
r7 r2 a.lsrr r5 r4 sub ,uint32
r7 r2 a.lslr r5 r4 sub ,uint32
r7 r2 a.rorr r5 r4 sub ,uint32

r7 7 a.lsri r5 r4 sub ,uint32
r4 2 a.lsli r5 r4 sub ,uint32
r4 2 a.rori r5 r4 sub ,uint32

63 a# r5 r4 sub ,uint32
63 0 a.shifti r5 r4 sub ,uint32
255 a# r15 r15 adc ,uint32

1 1 a.shifti r5 r4 sub ,uint32
1 2 a.shifti r5 r4 sub ,uint32
63 2 a.shifti r5 r4 add ,uint32
255 8 a.shifti r5 r4 sub ,uint32
0xFF 4 a.shifti r5 r4 adc ,uint32

1 7 a.shifti r5 r4 sub ,uint32
10 8 a.shifti r5 r4 add ,uint32
13 8 a.shifti r5 r4 adc ,uint32
13 16 a.shifti r5 r4 and ,uint32
13 15 a.shifti r5 r4 and ,uint32
13 24 a.shifti r5 r4 sub ,uint32
15 28 a.shifti r5 r4 sub ,uint32
1 31 a.shifti r5 r4 and ,uint32
13 32 a.shifti r5 r4 and ,uint32

( MOV PC,R14 ; Return from subroutine. )
r14 pc mov ,uint32

( MOVSPC,R14 ; Return from exception and restore CPSR from SPSR_mode. )
r14 pc mov a.s ,uint32

( Instructions: )

r1 r2 r0 mul .lt ,uint32
r14 r8 r2 r0 mla ,uint32

0 branch ,uint32
4 branch ,uint32
8 branch ,uint32
-1 branch ,uint32
-8 branch ,uint32
mark dhere - 8 - branch .link ,uint32

r3 branchx ,uint32

( integer offsets )
10 a# r0 r1 ldr ,uint32
10 a# r0 r1 ldr .up ,uint32
10 a# r0 r1 ldr .up .post ,uint32
10 a# r0 r1 ldr .byte ,uint32
10 a# r0 r1 str ,uint32

( register offset )
r2 r1 r0 str ,uint32
( shifted register offset )
r2 r1 r0 str ,uint32
r5 r1 r0 ldr .byte .write .lt ,uint32

r1 3 a.lsli r2 r0 str .write ,uint32
r2 8 a.rori r1 r0 ldr ,uint32
r4 24 a.lsri r2 r0 str .byte .up ,uint32
( not available on CPU )
r4 r5 a.lslr r2 r1 str ,uint32
0x1 24 a.shifti r3 r0 str ,uint32

svc ,uint32
0xbeeeef svc/1 ,uint32

0xF r1 stm ,uint32
0xFFFF r1 stm .cpsr ,uint32
0xF r1 stm .up .write ,uint32
0xF r1 stm .post ,uint32
0x7 r1 ldm .post ,uint32
0x7 r1 ldm .pre .write ,uint32

mark ddump-binary-bytes
