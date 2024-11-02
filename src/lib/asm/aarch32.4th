( todo reverse operond order, reverse of objdump / standard )
( todo data ops need a shorter handed use of immed-op, reg-op, and .i. )

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

: .condition 28 bsl swap 0xFFFFFFF logand logior ;

  ( Code Suffix Flags Meaning )
: .eq ( eq Z " set equal" )
0 .condition
;

: .ne ( ne Z " clear not equal" )
  1 .condition
;

: .cs ( cs C " set unsigned higher or same" ) 
  2 .condition
;

: .cc ( cc C " clear unsigned lower" )
  3 .condition
;

: .mi ( mi N " set negative" )
  4 .condition
;

: .pl ( pl N " clear positive or zero" )
  5 .condition
;

: .vs ( vs V " set overflow" )
  6 .condition
;

: .vc ( vc V " clear no overflow" )
  7 .condition
;

: .hi ( hi C " set and Z clear unsigned higher" )
  8 .condition
;

: .ls ( ls C " clear or Z set unsigned lower or same" )
  9 .condition
;

: .ge ( ge N " equals V greater or equal" )
  10 .condition
;

: .lt ( lt N " not equal to V less than" )
  11 .condition
;

: .gt ( gt Z " clear AND [N equals V] greater than" )
  12 .condition
;

: .le ( le Z " set OR [N not equal to V] less than or equal" )
  13 .condition
;

: .al ( al _ " always" )
  14 .condition
;

(
4   | 3     | 4      | 1 | 4  | 4  | 12        |
Cond| 0 0 I | Opcode | S | Rn | Rd | Operand 2 | Data Processing / PSR Transfer
Opcode operation, 0..16
Operand 2
Rn operand 1
Rd destination
I operand 2 type: 0 = op2 is register, 1 = op2 is immediate
S set condition codes
)

: .i 0x2000000 logior ;
: .set 0x100000 logior ;

0 const> BARREL-BSL
1 const> BARREL-BSR
2 const> BARREL-ASR
3 const> BARREL-RSR

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

: immed-op ( shift-right/2 immed -- operand2 )
  0xFF logand swap 0xF logand 8 bsl logior
;

: data-op ( operands op -- ins32 )
  21 bsl 0xE0000000 logior ( op )
  logior ( operands )
;

: data-op-args ( rn rd op2 -- ins32 )
  swap 12 bsl logior ( rd<<12 | op2 )
  swap 16 bsl logior ( rn )
;

: and data-op-args 0 data-op ; ( operand1 AND operand2 )
: eor data-op-args 1 data-op ; ( operand1 EOR operand2 )
: sub data-op-args 0x2 data-op ; ( operand1 - operand2 )
: rsm data-op-args 0x3 data-op ; ( operand2 - operand1 )
: add data-op-args 0x4 data-op ; ( operand1 + operand2 )
: adc data-op-args 0x5 data-op ; ( operand1 + operand2 + carry )
: sbc data-op-args 0x6 data-op ; ( operand1 - operand2 + carry - 1 )
: rsc data-op-args 0x7 data-op ; ( operand2 - operand1 + carry - 1 )
: tst data-op-args 0x8 data-op ; ( as AND, but result is not written )
: teq data-op-args 0x9 data-op ; ( as EOR, but result is not written )
: cmp data-op-args 0xA data-op ; ( as SUB, but result is not written )
: cmn data-op-args 0xB data-op ; ( as ADD, but result is not written )
: orr data-op-args 0xC data-op ; ( operand1 OR operand2 )
: mov data-op-args 0xD data-op ; ( operand2, operand1 is ignored )
: bic data-op-args 0xE data-op ; ( operand1 AND NOT operand2, Bit clear )
: mvn data-op-args 0xF data-op ; ( NOT operand2, operand1 is ignored )

: nop r0 r0 r0 mov ;

(
4    | 8               | 4  | 4  | 4  | 4       | 4  |
Cond | 0 0 0 0 0 0 A S | Rd | Rn | Rs | 1 0 0 1 | Rm | Multiply
A 0 = multiply, 1 = multiply and accumulate
S set condition codes
)

: mul ( rd rn rs rm -- ins32 )
  0xE0000090 ( b1001 )
  logior ( rm )
  swap 8 bsl logior ( rs )
  swap 12 bsl logior ( rs )
  swap 16 bsl logior ( rd )
;

: .a 1 21 bsl logior ;
: .s 1 20 bsl logior ;

: mla mul .a ;
: muls mul .s ;

(
4    | 8               | 4    | 4    | 4  | 4       | 4  |
Cond | 0 0 0 0 1 U A S | RdHi | RdLo | Rn | 1 0 0 1 | Rm | Multiply Long
A 0 = multiply, 1 = multiply and accumulate
S set condition codes
U unsigned/signed
)

: .signed 1 22 bsl logior ;

: umull ( rdhi rdlo rn rm -- ins32 )
  0xE0800090
  logior ( rm )
  swap 8 bsl logior ( rn )
  swap 12 bsl logior ( rdlo )
  swap 16 bsl logior ( rdhi )
;

: umlal umull .a ;
: umulls umull .s ;

: smull umull .signed ;
: smlal umlal .signed ;
: smulls umulls .signed ;

(
4    | 8               | 8               | 8               | 4 |
Cond | 0 0 0 1 0 0 1 0 | 1 1 1 1 1 1 1 1 | 1 1 1 1 0 0 0 1 | Rn | Branch and Exchange
)

: bx
  0xF logand 0xE12fff10 logior
;


(
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

( LDRH/STRH/LDRSB/LDRSH )

: .l 0x100000 logior ;
: .p 0x1000000 logior ;
: .up 0x800000 logior ;
: .w 0x200000 logior ;

: strh ( rn rd rm -- ins32 )
  0xE00000B0 logior
  swap 12 bsl logior ( rd )
  swap 16 bsl logior ( rn )
;

: ldrh strh .l ;
: ldrsb strh .l 0xFFFFFF0F logand 0xD0 logior ;
: ldrsh strh .l 0xFFFFFF0F logand 0xF0 logior ;

(
4    | 8               | 4  | 4  | 4      | 4       | 4 |
Cond | 0 0 0 P U 1 W L | Rn | Rd | Offset | 1 S H 1 | Offset | Halfword Data Transfer:immediate offset
)

( LDRH/STRH/LDRSB/LDRSH )

: strhi ( rn rd offset -- ins32 )
  dup 0xF logand 0xE04000B0 logior ( offset low )
  swap 4 bsr 0xF logand 8 bsl logior ( ogfset high )
  swap 12 bsl logior ( rd )
  swap 16 bsl logior ( rn )
;

: ldrhi strhi .l ;
: ldrsbi strhi .l 0xFFFFFF0F logand 0xD0 logior ; 
: ldrshi strhi .l 0xFFFFFF0F logand 0xF0 logior ; 


(
4    | 8               | 4  | 4  | 8               | 4  |
Cond | 0 0 0 1 0 B 0 0 | Rn | Rd | 0 0 0 0 1 0 0 1 | Rm | Single Data Swap
B word/byte
Rn base
Rd destination
Rm offset
)

: swp ( rn rd rm -- ins )
  strh .p 0xFFFFFF0F logand 0x90 logior
;

: swpi ( rn rd rm -- ins )
  strhi .p 0xFFFFFF0F logand 0x90 logior
;

(
4    | 6           | 5         | 4  | 12
Cond | 0 0 0 1 0 P | 0 0 1 1 1 | Rd | 000000000000 |
P 0 = cspsr, 1 = spsr
)
: mrs ( rd -- ins )
  12 bsl 0xE1070000 logior
;

: mrsp mrs 0x1000000 logior ;

(
4    | 5         | 1  | 10         | 8        | 4  |
Cond | 0 0 0 1 0 | Pd | 1010011111 | 00000000 | Rm |
)
: msr ( rm -- ins )
  0xE129f000 logior
;

: .spsr 0x400000 logior ;

(
4    | 5         | 1  | 10         | 12             |
Cond | 0 0 I 1 0 | Pd | 1010001111 | Source operand |
)

: msri ( rm -- ins )
  0xE128f000 logior
;

(
4    | 8               | 4  | 4  | 12     |
Cond | 0 1 I P U B W L | Rn | Rd | Offset | Single Data Transfer
P post/pre indexing
U down/up
B word/byte
W writeback
L store/load
Rn base
Rd source/dest
Offset
)

: .b 0x400000 logior ;

: str ( rn rd offset -- ins32 )
  0xE4000000 logior
  swap 12 bsl logior
  swap 16 bsl logior
;

: ldr str .l ;

(
4    | 3     | 20                                | 1 | 4 |
Cond | 0 1 1 | . . . . . . . . | . . . . . . . . | 1 | . . . . | Undefined
)

(
4    | 8               | 4  | 16 |
Cond | 1 0 0 P U S W L | Rn | Register List | Block Data Transfer
P post/pre increment indexing
U down/up
S do not load / do load PSR
W writeback
L store/load
)

: .psr 0x400000 logior ;

: stm ( rn reglist -- ins )
  0xFFFF logand
  swap 16 bsl logior
  0xE8000000 logior
;

: ldm stm .l ;

(
4    | 4       | 24 |
Cond | 1 0 1 L | Offset | Branch
L link bit: 1 = branch w/ link
)

: b 0xFFFFFF logand 0xEA000000 logior ;
: bl b 0x1000000 logior ;

(
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

: stc ( rn crd cp# offset -- ins32 )
  0xEC000000 logior ( offset )
  swap 8 bsl logior ( cp# )
  swap 12 bsl logior ( crd )
  swap 16 bsl logior ( rn )
;

: ldc str 0x100000 logior ;

(
4    | 4       | 4      | 4   | 4   | 4   | 3  | 1 | 4 |
Cond | 1 1 1 0 | CP Opc | CRn | CRd | CP# | CP | 0 | CRm | Coprocessor Data Operation
CP_Opc operation code
CRn coprocessor operand register
CRd coprocessor destination register
CP# coprocessor number
CP coprocessor info
CRm coprocessor operand register
)

: cdp ( cpop crn crd cp# cp crm -- ins32 )
  0xEE000000 logior ( crm )
  swap 5 bsl logior ( cp )
  swap 8 bsl logior ( cp# )
  swap 12 bsl logior ( crd )
  swap 16 bsl logior ( crn )
  swap 20 bsl logior ( cpop )
;

(
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

: mrc ( cpop crn rd cp# cp crm -- ins32 )
  0xEE000010 logior ( crm )
  swap 5 bsl logior ( cp )
  swap 8 bsl logior ( cp# )
  swap 12 bsl logior ( rd )
  swap 16 bsl logior ( crn )
  swap 20 bsl logior ( cpop )
;

: mcr mrc 0x100000 logior ;

(
4    | 4       | 24 |
Cond | 1 1 1 1 | Ignored by processor | Software Interrupt
)

: swi ( comment -- ins32 )
  0xEF000000 logior
;

( Helpers: )
alias> ,ins ,uint32
alias> ins@ uint32@
alias> ins! uint32!
