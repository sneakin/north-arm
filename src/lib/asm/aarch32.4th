( aarch32 assembly words )
( See https://gab.wallawalla.edu/~curt.nelson/cptr380/textbook/advanced%20material/Appendix_B2.pdf )

DEFINED? NORTH-COMPILE-TIME UNLESS
  DEFINED? ,uint32 UNLESS
    " src/lib/byte-data.4th" load
  THEN

  DEFINED? mark> UNLESS
    " src/interp/mark.4th" load
  THEN
THEN

mark> pre-asm-aarch32

( todo mask arguments )
( todo place ins bits last in functions )

: shift3 ( c b a x -- x c b a )
  3 swapn 2 swapn swap
;

( Registers: )

0 const> r0
1 const> r1
2 const> r2
3 const> r3
4 const> r4
5 const> r5
6 const> r6
7 const> r7
8 const> r8
9 const> r9
10 const> r10
11 const> r11
12 const> r12
13 const> r13
14 const> r14
15 const> r15
alias> pc r15
alias> lr r14
alias> sp r13
alias> ip r12
alias> fp r11
alias> sl r10

s" src/lib/asm/aarch32/regmask.4th" load/2

( Condition code modifiers: )

: .condition 28 bsl swap 0xFFFFFFF logand logior ;

: .eq  0 .condition ; ( eq Z " set equal" )
: .ne  1 .condition ; ( ne Z " clear not equal" )
: .cs  2 .condition ; ( cs C " set unsigned higher or same" ) 
: .cc  3 .condition ; ( cc C " clear unsigned lower" )
: .mi  4 .condition ; ( mi N " set negative" )
: .pl  5 .condition ; ( pl N " clear positive or zero" )
: .vs  6 .condition ; ( vs V " set overflow" )
: .vc  7 .condition ; ( vc V " clear no overflow" )
: .hi  8 .condition ; ( hi C " set and Z clear unsigned higher" )
: .ls  9 .condition ; ( ls C " clear or Z set unsigned lower or same" )
: .ge  10 .condition ; ( ge N " equals V greater or equal" )
: .lt  11 .condition ; ( lt N " not equal to V less than" )
: .gt  12 .condition ; ( gt Z " clear AND [N equals V] greater than" )
: .le  13 .condition ; ( le Z " set OR [N not equal to V] less than or equal" )
: .al  14 .condition ; ( al _ " always" )

( Data processing:

4   | 3     | 4      | 1 | 4  | 4  | 12        |
Cond| 0 0 I | Opcode | S | Rn | Rd | Operand 2 | Data Processing / PSR Transfer
Opcode operation, 0..16
Operand 2
Rn operand 1
Rd destination
I operand 2 type: 0 = op2 is register, 1 = op2 is immediate
S set condition codes
)

: .i 0x2000000 logior ; ( todo use seems a bit backward )
: ~.i 0x2000000 lognot logand ;
: .set 0x100000 logior ;

0 const> BARREL-BSL
1 const> BARREL-BSR
2 const> BARREL-ASR
3 const> BARREL-RSR

( For I=0 )
: immed-op ( shift-right/2 immed -- operand2 )
  0xFF logand swap 0xF logand 8 bsl logior
;

( For I=1 )

: immed-shift ( amount type -- shift )
  0x3 logand 1 bsl
  swap 0x1F logand 3 bsl logior
;

: reg-shift ( reg type -- shift )
  0x3 logand 1 bsl 1 logior
  swap 0xF logand 4 bsl logior
;

: reg-op ( shift reg -- operand2 )
  0xF logand swap 0xFF logand 4 bsl logior
;

( Op macros )

: data-op ( operands op -- ins )
  21 bsl 0xE0000000 logior ( op )
  logior ( operands )
;

: data-op-args ( op2 rn rd -- ins )
  12 bsl ( rd )
  swap 16 bsl logior ( rn )
  logior ( op2 )
;

: data-op-reg 2swap reg-op shift ;
: data-op-immed 2swap immed-op shift ;

: data-op1-reg shift reg-op swap ;
: data-op1-immed shift immed-op swap ;

( The data ops: )

: and ( op2 rn rd -- ins ) data-op-args 0 data-op ; ( operand1 AND operand2 )
: andr ( shift-op rm rn rd -- ins ) data-op-reg and ;
: and# ( rshift immed rn rd -- ins ) data-op-immed and .i ;

: eor data-op-args 1 data-op ; ( operand1 EOR operand2 )
: eorr ( shift-op rm rn rd -- ins ) data-op-reg eor ;
: eor# ( rshift immed rn rd -- ins ) data-op-immed eor .i ;

: sub data-op-args 0x2 data-op ; ( operand1 - operand2 )
: subr ( shift-op rm rn rd -- ins ) data-op-reg sub ;
: sub# ( rshift immed rn rd -- ins ) data-op-immed sub .i ;

: rsm data-op-args 0x3 data-op ; ( operand2 - operand1 )
: rsmr ( shift-op rm rn rd -- ins ) data-op-reg rsm ;
: rsm# ( rshift immed rn rd -- ins ) data-op-immed rsm .i ;

: add data-op-args 0x4 data-op ; ( operand1 + operand2 )
: addr ( shift-op rm rn rd -- ins ) data-op-reg add ;
: add# ( rshift immed rn rd -- ins ) data-op-immed add .i ;

: adc data-op-args 0x5 data-op ; ( operand1 + operand2 + carry )
: adcr ( shift-op rm rn rd -- ins ) data-op-reg adc ;
: adc# ( rshift immed rn rd -- ins ) data-op-immed adc .i ;

: sbc data-op-args 0x6 data-op ; ( operand1 - operand2 + carry - 1 )
: sbcr ( shift-op rm rn rd -- ins ) data-op-reg sbc ;
: sbc# ( rshift immed rn rd -- ins ) data-op-immed sbc .i ;

: rsc data-op-args 0x7 data-op ; ( operand2 - operand1 + carry - 1 )
: rscr ( shift-op rm rn rd -- ins ) data-op-reg rsc ;
: rsc# ( rshift immed rn rd -- ins ) data-op-immed rsc .i ;

: tst 0 data-op-args 0x8 data-op .set ; ( as AND, but result is not written )
: tstr ( shift-op rm rn -- ins ) data-op1-reg tst ;
: tst# ( rshift immed rn -- ins ) data-op1-immed tst .i ;

: teq 0 data-op-args 0x9 data-op .set ; ( as EOR, but result is not written )
: teqr ( shift-op rm rn -- ins ) data-op1-reg teq ;
: teq# ( rshift immed rn -- ins ) data-op1-immed teq .i ;

: cmp 0 data-op-args 0xA data-op .set ; ( as SUB, but result is not written )
: cmpr ( shift-op rm rn -- ins ) data-op1-reg cmp ;
: cmp# ( rshift immed rn -- ins ) data-op1-immed cmp .i ;

: cmn 0 data-op-args 0xB data-op .set ; ( as ADD, but result is not written )
: cmnr ( shift-op rm rn -- ins ) data-op1-reg cmn ;
: cmn# ( rshift immed rn -- ins ) data-op1-immed cmn .i ;

: orr data-op-args 0xC data-op ; ( operand1 OR operand2 )
: orrr ( shift-op rm rn rd -- ins ) data-op-reg orr ;
: orr# ( rshift immed rn rd -- ins ) data-op-immed orr .i ;

: mov 0 swap data-op-args 0xD data-op ; ( operand2, operand1 is ignored )
: movr ( shift-op rm rd -- ins ) data-op1-reg mov ;
: mov# ( rshift immed rd -- ins ) data-op1-immed mov .i ;

: bic data-op-args 0xE data-op ; ( operand1 AND NOT operand2, Bit clear )
: bicr ( shift-op rm rn rd -- ins ) data-op-reg bic ;
: bic# ( rshift immed rn rd -- ins ) data-op-immed bic .i ;

: mvn 0 swap data-op-args 0xF data-op ; ( NOT operand2, operand1 is ignored )
: mvnr ( shift-op rm rd -- ins ) data-op1-reg mvn ;
: mvn# ( rshift immed rd -- ins ) data-op1-immed mvn .i ;

( Multiplication

4    | 8               | 4  | 4  | 4  | 4       | 4  |
Cond | 0 0 0 0 0 0 A S | Rd | Rn | Rs | 1 0 0 1 | Rm | Multiply
A 0 = multiply, 1 = multiply and accumulate
S set condition codes
)

: mul/4 ( rn rm rs rd -- ins )
  0xE0000090 ( b1001 )
  swap 16 bsl logior ( rd )
  logior ( rm )
  swap 8 bsl logior ( rs )
  swap 12 bsl logior ( rn )
;

: mul 0 shift3 mul/4 ;

: .a 1 21 bsl logior ;

: mla mul/4 .a ;
: muls mul .set ;

( 64 bit out multiply

4    | 8               | 4    | 4    | 4  | 4       | 4  |
Cond | 0 0 0 0 1 U A S | RdHi | RdLo | Rn | 1 0 0 1 | Rm | Multiply Long
A 0 = multiply, 1 = multiply and accumulate
S set condition codes
U unsigned/signed
)

: .signed 1 22 bsl logior ;

: umull ( rn rm rdhi rdlo -- ins )
  0xE0800090
  swap 12 bsl logior ( rdlo )
  swap 16 bsl logior ( rdhi )
  logior ( rm )
  swap 8 bsl logior ( rn )
;

: umlal umull .a ;
: umulls umull .set ;

: smull umull .signed ;
: smlal umlal .signed ;
: smulls umulls .signed ;

( 16 and 8 bit load and store

4    | 8               | 4  | 4  | 8               | 4 |
Cond | 0 0 0 P U 0 W L | Rn | Rd | 0 0 0 0 1 S H 1 | Rm | Halfword Data Transfer: register offset
P post/pre indexing
U down/up
W writeback
L store/load
Rn base
Rd source/dest
S H 00 swap, 01 unsigned short, 10 signed byte, 11 signed short
Rm offset
)

: .p 0x1000000 logior ;
: .up 0x800000 logior ;
: .n 0x400000 logior ;
: .w 0x200000 logior ;
: .l 0x100000 logior ;

: strh/3 ( rm rn rd -- ins )
  0xE00000B0
  swap 12 bsl logior ( rd )
  swap 16 bsl logior ( rn )
  logior ( rm )
;

: strh ( rm rn rd -- ins )
  3 overn abs-int shift strh/3
  swap 0 int> IF .up THEN
;

: ldrh strh .l ;
: ldrsb strh .l 0xFFFFFF0F logand 0xD0 logior ;
: ldrsh strh .l 0xFFFFFF0F logand 0xF0 logior ;

( 16 and 8 bit load and store w/ immediate offset

4    | 8               | 4  | 4  | 4      | 4       | 4 |
Cond | 0 0 0 P U 1 W L | Rn | Rd | Offset | 1 S H 1 | Offset | Halfword Data Transfer:immediate offset
)

: strhi/3 ( offset rn rd -- ins )
  0xE04000B0
  swap 12 bsl logior ( rd )
  swap 16 bsl logior ( rn )
  over 0xF logand logior ( offset low )
  swap 4 bsr 0xF logand 8 bsl logior ( offset high )
;

: strhi ( offset rn rd -- ins )
  3 overn abs-int shift strhi/3
  swap 0 int> IF .up THEN
;

: ldrhi strhi .l ;
: ldrsbi strhi .l 0xFFFFFF0F logand 0xD0 logior ; 
: ldrshi strhi .l 0xFFFFFF0F logand 0xF0 logior ; 


( Data swap

4    | 8               | 4  | 4  | 8               | 4  |
Cond | 0 0 0 1 0 B 0 0 | Rn | Rd | 0 0 0 0 1 0 0 1 | Rm | Single Data Swap
B word/byte
Rn base
Rd destination
Rm offset
)

: .b 0x400000 logior ;

( todo offset is the right position? )

: swp ( rm rn rd -- ins )
  strh/3 .p 0xFFFFFF0F logand 0x90 logior
;

: swpi ( offset rn rd -- ins )
  swp .b
;

( PSR Transfer

4    | 6           | 5         | 4  | 12
Cond | 0 0 0 1 0 P | 0 0 1 1 1 | Rd | 000000000000 |
P 0 = cspsr, 1 = spsr
)
: mrs ( rd -- ins )
  12 bsl 0xE1070000 logior
;

: mrsp mrs 0x1000000 logior ;

( PSR loading

4    | 5         | 1  | 10         | 8        | 4  |
Cond | 0 0 0 1 0 | Pd | 1010011111 | 00000000 | Rm |
)
: msr ( rm -- ins )
  0xE129f000 logior
;

: .spsr 0x400000 logior ;

( PSR flag loading from an immediate

4    | 5         | 1  | 10         | 12             |
Cond | 0 0 I 1 0 | Pd | 1010001111 | Source operand |
)

: msri ( rm -- ins )
  0xE128f000 logior
;

( Single word load and store

4    | 8               | 4  | 4  | 12     |
Cond | 0 1 I P U B W L | Rn | Rd | Offset | Single Data Transfer
I immediate offset?
P post/pre indexing
U down/up
B word/byte
W writeback
L store/load
Rn base
Rd source/dest
Offset
)

( todo needs auto .up, but the offset may be a shift )

: str# ( offset rn rd -- ins )
  0xE4000000
  swap 12 bsl logior ( rd )
  swap 16 bsl logior ( rn )
  swap 0xFFF logand logior ( offset )
;

: str ( offset rn rd -- ins )
  str# .i
;

: ldr str .l ;
: ldr# str# .l ;

(
4    | 3     | 20                                | 1 | 4 |
Cond | 0 1 1 | . . . . . . . . | . . . . . . . . | 1 | . . . . | Undefined
)

( Block data transfer

4    | 8               | 4  | 16 |
Cond | 1 0 0 P U S W L | Rn | Register List | Block Data Transfer
P post/pre increment indexing
U down/up
S do not load / do load PSR
W writeback
L store/load
)

: .psr 0x400000 logior ;

: stm-op ( reglist rn -- ins )
  16 bsl ( rn )
  swap 0xFFFF logand logior ( reglist )
  0xE8000000 logior
;

: stm ( reglist rn -- ins )
  ( convert single registers to str )
  over regmask->reglist
  dup 1 equals?
  IF drop swap drop 0 shift str
  ELSE dropn stm-op
  THEN
;

: ldm stm .l ;

( Branch exchange

4    | 8               | 8               | 8               | 4 |
Cond | 0 0 0 1 0 0 1 0 | 1 1 1 1 1 1 1 1 | 1 1 1 1 0 0 0 1 | Rn | Branch and Exchange
)

: bx
  0xF logand 0xE12fff10 logior
;

( Branch

4    | 4       | 24 |
Cond | 1 0 1 L | Offset | Branch
L link bit: 1 = branch w/ link
)

SYS:DEFINED? absr IF
  : b 4 - 2 absr 0xFFFFFF logand 0xEA000000 logior ;
ELSE
  : b 4 - 2 bsr 0xFFFFFF logand 0xEA000000 logior ;
THEN

: bl b 0x1000000 logior ;

( Coprocessor data transfer

4    | 8               | 4  | 4   | 4 | 8 |
Cond | 1 1 0 P U N W L | Rn | CRd | CP# | Offset | Coprocessor Data Transfer
P post/pre increment indexing
U down/up
N transfer length
W writeback
L store/load
Rn base register
CRd coprocessor register
CP# coprocessor number
offset
)

: stc ( offset rn crd cp# -- ins )
  0xEC000000
  swap 8 bsl logior ( cp# )
  swap 12 bsl logior ( crd )
  swap 16 bsl logior ( rn )
  swap 0xFF logand logior ( offset )
;

: ldc stc 0x100000 logior ;

( Coprocessor data ops

4    | 4       | 4      | 4   | 4   | 4   | 3  | 1 | 4 |
Cond | 1 1 1 0 | CP Opc | CRn | CRd | CP# | CP | 0 | CRm | Coprocessor Data Operation
CP_Opc operation code
CRn coprocessor operand register
CRd coprocessor destination register
CP# coprocessor number
CP coprocessor info
CRm coprocessor operand register
)

: cdp ( cp crm crn crd cpop cp# -- ins )
  8 bsl ( cp# )
  swap 20 bsl logior ( cpop )
  swap 12 bsl logior ( crd )
  swap 16 bsl logior ( crn )
  logior ( crm )
  swap 5 bsl logior ( cp )
  0xEE000000 logior
;

( Coprocessor register transfer

4    | 4       | 3      | 1 | 4   | 4  | 4   | 3  | 1 | 4 |
Cond | 1 1 1 0 | CP Opc | L | CRn | Rd | CP# | CP | 1 | CRm | Coprocessor Register Transfer
CP_opc coprocessor operation code
L store/load
CRn coprocessor src/destination register
Rd ARM src/destination register
CP# coprocessor number
CP coprocessor info
CRm coprocessor operand register
)

: mcr ( cp crm crn rd cpop cp# -- ins )
  0xF logand 8 bsl ( cp# )
  swap 0x7 logand 21 bsl logior ( cpop )
  swap 12 bsl logior ( rd )
  swap 16 bsl logior ( crn )
  logior ( crm )
  swap 0x7 logand 5 bsl logior ( cp )
  0xEE000010 logior
;

: mrc mcr 0x100000 logior ;

( Software interrupt

4    | 4       | 24 |
Cond | 1 1 1 1 | Ignored by processor | Software Interrupt
)

: swi ( comment -- ins )
  0xFFFFFF logand 0xEF000000 logior
;

( Breakpoint
12                      | 12          | 4       | 4
1 1 1 0 0 0 0 1 0 0 1 0 | immed[15:4] | 0 1 1 1 | immed [3:0]
)

: bkpt/1
  0xFFFF logand dup 4 bsr 8 bsl
  swap 0xF logand logior
  0xE1200070 logior
;

: bkpt 0 bkpt/1 ;

( Signed Divide
4    | 8               | 4  | 4      | 4  | 4       | 4  |
cond | 0 1 1 1 0 0 0 1 | Rd | [1111] | Rm | 0 0 0 1 | Rn |
cond != 0xF
)

: sdiv ( rn rm rd -- ins )
  16 bsl
  swap 8 bsl logior
  logior
  0xE710F010 logior
;

( Unsigned divide
4    | 8               | 4  | 4    | 4  | 4       | 4  |
cond | 0 1 1 1 0 0 1 1 | Rd | 1111 | Rm | 0 0 0 1 | Rn |
)
: udiv ( rn rm rd -- ins )
  16 bsl
  swap 8 bsl logior
  logior
  0xE730F010 logior
;


( Helpers: )

alias> ,ins ,uint32
alias> ins@ uint32@
alias> ins! uint32!

: nop r0 r0 mov ;

: dropi ( base num-words -- ins )
  15 rot dup add#
;

: drop1 ( base -- ins )
  1 dropi
;

: popr ( reglist base -- ins )
  ldm .up .w  
;

: pushr ( reg/ist base -- ins )
  stm .w  
;

: pop1 ( base dest -- ins )
  0 swap bit-set swap popr
;

: push1 ( base src -- ins )
  0 swap bit-set swap pushr
;

: pop sp swap pop1 ;
: push sp swap push1 ;

( Dictionary mark to keep these words from polluting the namespace: )
pre-asm-aarch32 push-mark> asm-aarch32

