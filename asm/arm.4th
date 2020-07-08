( Registers: )
: arm-gen-reg
  dup literal " r" ++ make-const
;

: arm-gen-registers
  1 - dup arm-gen-reg
  dup 0 equals UNLESS loop THEN
  drop
;

16 arm-gen-registers
alias> pc r15
alias> lr r14
alias> sp r13
alias> ip r12

( ARM Conditions )

: arm-clear-cond
  0x0FFFFFFF logand
;
  
: generate-arm-condition
  ( bits suffix flags doc -- )
  4 overn 2 unsigned-integer/2 28 bsl
  literal " feval arm-clear-cond literal " ++ literal "  logior" swap ++
  4 overn literal " ." ++ set-word!
  4 dropn
;

: generate-arm-conditions
  dup read-terminator equals IF return THEN
  generate-arm-condition
  loop
;

: arm-conditions:
  compiling-read generate-arm-conditions
  drop
;

arm-conditions:
  ( Code Suffix Flags Meaning )
  0000 eq Z q" set equal"
  0001 ne Z q" clear not equal"
  0010 cs C q" set unsigned higher or same"
  0011 cc C q" clear unsigned lower"
  0100 mi N q" set negative"
  0101 pl N q" clear positive or zero"
  0110 vs V q" set overflow"
  0111 vc V q" clear no overflow"
  1000 hi C q" set and Z clear unsigned higher"
  1001 ls C q" clear or Z set unsigned lower or same"
  1010 ge N q" equals V greater or equal"
  1011 lt N q" not equal to V less than"
  1100 gt Z q" clear AND [N equals V] greater than"
  1101 le Z q" set OR [N not equal to V] less than or equal"
  1110 al _ q" always"
;

( ARM instructions:
* Cond 0 0 I Opcode S Rn Rd Operand2 " Data Processing / PSR Transfer"
* Cond 0 0 0 0 0 0 A S Rd Rn Rs 1 0 0 1 Rm Multiply
Cond 0 0 0 0 1 U A S RdHi RdLo Rn 1 0 0 1 Rm " Multiply Long"
Cond 0 0 0 1 0 B 0 0 Rn Rd 0 0 0 0 1 0 0 1 Rm " Single Data Swap"
* Cond 0 0 0 1 0 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 1 Rn " Branch and Exchange"
Cond 0 0 0 P U 0 W L Rn Rd 0 0 0 0 1 S H 1 Rm " Halfword Data Transfer: register offset"
Cond 0 0 0 P U 1 W L Rn Rd Offset 1 S H 1 Offset " Halfword Data Transfer: immediate offset"
* Cond 0 1 I P U B W L Rn Rd Offset " Single Data Transfer"
Cond 0 1 1 1 Undefined
* Cond 1 0 0 P U S W L Rn " Register List Block Data Transfer"
* Cond 1 0 1 L Offset " Branch"
Cond 1 1 0 P U N W L Rn CRd CP# Offset " Coprocessor Data Transfer"
Cond 1 1 1 0 CP Opc CRn CRd CP# CP 0 CRm " Coprocessor Data Operation"
Cond 1 1 1 0 CP Opc L CRn Rd CP# CP 1 CRm " Coprocessor Register Transfer"
* Cond 1 1 1 1 Ignored " Software Interrupt"
)

( ARM mneumonics: )
( Mnemonic Instruction Action See Section: )
( Instructions: )
(
* B Branch R15 := address 4.4
* BL Branch with Link R14 := R15, R15 := address 4.4
* BX Branch and Exchange R15 := Rn, T bit := Rn[0] 4.3
CDP Coprocesor Data Processing, Coprocessor-specific 4.14
LDC Load coprocessor from memory Coprocessor load 4.15
* LDM Load multiple registers Stack manipulation, Pop 4.11
* LDR Load register from memory Rd := [address] 4.9, 4.10
MCR Move CPU register to coprocessor register cRn := rRn {<op>cRm} 4.16
* MLA Multiply Accumulate Rd := [Rm * Rs] + Rn 4.7, 4.8
MRC Move from coprocessor register to CPU register Rn := cRn {<op>cRm} 4.16
MRS Move PSR status/flags to register Rn := PSR 4.6
MSR Move register to PSR status/flags PSR := Rm 4.6
* MUL Multiply Rd := Rm * Rs 4.7, 4.8
x OR op2 AND NOT Rn 4.5
STC Store coprocessor register to memory address := CRn 4.15
* STM Store Multiple Stack manipulation, Push 4.11
* STR Store register to memory <address> := Rd 4.9, 4.10
* SWI Software Interrupt OS call 4.13
SWP Swap register with memory Rd := [Rn], [Rn] := Rm 4.12
)

( Cond 1 1 1 1 Ignored " Software Interrupt" )
( SWI Software Interrupt OS call 4.13 )
: svc/1
  0xF 24 bsl .al logior
;

: svc 0 svc/1 ;

( Cond 1 0 1 L Offset " Branch" )
( B Branch R15 := address 4.4 )
: branch ( offset )
  2 bsr 0xFFFFFF logand
  10 24 bsl logior .al
;

( BL Branch with Link R14 := R15, R15 := address 4.4 )
: .link
  24 bit-set
;

( Cond 0 0 0 1 0 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 1 Rn " Branch and Exchange" )
( BX Branch and Exchange R15 := Rn, T bit := Rn[0] 4.3 )
: branchx ( reg -- ins )
  0x12fff10 logior .al
;

( Cond 0 0 0 0 0 0 A S Rd:4 Rn:4 Rs:4 1 0 0 1 Rm:4 Multiply )
( MUL Multiply Rd := Rm * Rs 4.7, 4.8 )
: mul ( rs rm rd )
  swap 9 4 bsl logior
  swap 16 bsl logior
  swap 8 bsl logior
  .al
;

( MLA Multiply Accumulate Rd := [Rm * Rs] + Rn 4.7, 4.8 )
: mla ( rn rs rm rd )
  mul 21 bit-set
  swap 12 bsl logior
;

( Cond 0 1 I P U B W L Rn Rd Offset " Single Data Transfer" )

: .write 21 bit-set ;

: .byte 22 bit-set ;
: .word 22 bit-clear ;

: .up 23 bit-set ;
: .down 23 bit-clear ;

: .post 24 bit-set ;
: .pre 24 bit-clear ;

: arm-immediate? dup 25 bit-set? ;

( STR Store register to memory <address> := Rd 4.9, 4.10 )
: str ( offset rn rd -- ins )
  ( rd )
  12 bsl
  ( rn )
  swap 16 bsl logior
  ( offset )
  swap arm-immediate? IF
    0xFFF logand
  ELSE
    ( roll 4 bsl logior ) a#
  THEN logior
  ( ins code )
  1 26 bsl logior
  .al
;

: .load 20 bit-set ;

( LDR Load register from memory Rd := [address] 4.9, 4.10 )
: ldr
  str .load
;

( Cond 1 0 0 P U S W L Rn " Register List Block Data Transfer" )

: .cpsr 22 bit-set ;

( STM Store Multiple Stack manipulation, Push 4.11 )
: stm ( reg-bits rn -- ins )
  16 bsl logior
  8 24 bsl logior
  .al
;

: ldm ( reg-bits rn -- ins )
  stm .load
;

( ARM Data Processing op codes: )

( Data instruction op code generator: )

: generate-arm-data-op
  drop
  2 unsigned-integer/2 21 bsl
  swap literal " ARM-DATA-OP-" ++ make-const
;

: generate-arm-data-ops
  dup read-terminator equals IF return THEN
  generate-arm-data-op
  loop
;

: arm-data-ops:
  compiling-read generate-arm-data-ops
  drop
;

arm-data-ops:
( Mnemonic OpCode Action )
AND 0000 " operand1 AND operand2"
EOR 0001 " operand1 EOR operand2"
SUB 0010 " operand1 - operand2"
RSB 0011 " operand2 - operand1"
ADD 0100 " operand1 + operand2"
ADC 0101 " operand1 + operand2 + carry"
SBC 0110 " operand1 - operand2 + carry - 1"
RSC 0111 " operand2 - operand1 + carry - 1"
TST 1000 " as AND, but result is not written"
TEQ 1001 " as EOR, but result is not written"
CMP 1010 " as SUB, but result is not written"
CMN 1011 " as ADD, but result is not written"
ORR 1100 " operand1 OR operand2"
MOV 1101 " operand2, operand1 is ignored"
BIC 1110 " operand1 AND NOT operand2, Bit clear"
MVN 1111 " NOT operand2, operand1 is ignored"
;

( MOV,MVN [single operand instructions.]
<opcode>{cond}{S} Rd,<Op2> => op2 rd opcode [.cond] [.s]
* MOV Move register or constant Rd : = Op2 4.5
* MVN Move negative register Rd := 0xFFFFFFFF EOR Op2 4.5
)

: arm-data-op-rnrd ( rn rd op -- ins )
  rot
  4 bsl logior
  12 bsl logior
;

( Cond:4 0 0 I Opcode:4 S Rn:4 Rd:4 Operand2:12 " Data Processing / PSR Transfer" )

: arm-data-op/4 ( op2 rn rd op -- ins )
  arm-data-op-rnrd logior .al
;

: mov 0 swap ARM-DATA-OP-MOV arm-data-op/4 ;
: mvn 0 swap ARM-DATA-OP-MVN arm-data-op/4 ;

( CMP,CMN,TEQ,TST [instructions which do not produce a result.]
<opcode>{cond} Rn,<Op2> => op2 rn opcode [.cond]

* CMN Compare Negative CPSR flags := Rn + Op2 4.5
* CMP Compare CPSR flags := Rn - Op2 4.5
* TEQ Test bitwise equality CPSR flags := Rn EOR Op2 4.5
* TST Test bits CPSR flags := Rn AND Op2 4.5
)

: cmn 0 ARM-DATA-OP-CMN arm-data-op/4 ;
: cmp 0 ARM-DATA-OP-CMP arm-data-op/4 ;
: teq 0 ARM-DATA-OP-TEQ arm-data-op/4 ;
: tst 0 ARM-DATA-OP-TST arm-data-op/4 ;

( AND,EOR,SUB,RSB,ADD,ADC,SBC,RSC,ORR,BIC
<opcode>{cond}{S} Rd,Rn,<Op2> => op2 rn rd opcode [.cond] [.s]

* ADC Add with carry Rd := Rn + Op2 + Carry 4.5
* ADD Add Rd := Rn + Op2 4.5
* AND AND Rd := Rn AND Op2 4.5
* BIC Bit Clear Rd := Rn AND NOT Op2 4.5
* EOR Exclusive OR Rd := Rn AND NOT Op2
* ORR OR Rd := Rn OR Op2 4.5
* RSB Reverse Subtract Rd := Op2 - Rn 4.5
* RSC Reverse Subtract with Carry Rd := Op2 - Rn - 1 + Carry 4.5
* SBC Subtract with Carry Rd := Rn - Op2 - 1 + Carry 4.5
* SUB Subtract Rd := Rn - Op2 4.5
)

: adc ARM-DATA-OP-ADC arm-data-op/4 ;
: add ARM-DATA-OP-ADD arm-data-op/4 ;
: and ARM-DATA-OP-AND arm-data-op/4 ; ( AND Rd := Rn AND Op2 4.5 )
: bic ARM-DATA-OP-BIC arm-data-op/4 ; ( Bit Clear Rd := Rn AND NOT Op2 4.5 )
: eor ARM-DATA-OP-EOR arm-data-op/4 ; ( Exclusive OR Rd := Rn AND NOT Op2 )
: orr ARM-DATA-OP-ORR arm-data-op/4 ; ( OR Rd := Rn OR Op2 4.5 )
: rsb ARM-DATA-OP-RSB arm-data-op/4 ; ( Reverse Subtract Rd := Op2 - Rn 4.5 )
: rsc ARM-DATA-OP-RSC arm-data-op/4 ; ( Reverse Subtract with Carry Rd := Op2 - Rn - 1 + Carry 4.5 )
: sbc ARM-DATA-OP-SBC arm-data-op/4 ; ( Subtract with Carry Rd := Rn - Op2 - 1 + Carry 4.5 )
: sub ARM-DATA-OP-SUB arm-data-op/4 ; ( Subtract Rd := Rn - Op2 4.5 )

( where: <Op2> is Rm{,<shift>} or <#expression>
{cond} is a two-character condition mnemonic. See Table 4-2: 
{S} set condition codes if S present [implied for CMP, CMN, TEQ, TST].
Rd, Rn and Rm are expressions evaluating to a register number. 
<#expression> if this is used, the assembler will attempt to generate a shifted immediate 8-bit field to match the expression. If this is impossible, it will give an error. 
<shift> is <shiftname> <register> or <shiftname> #expression, or 
RRX [rotate right one bit with extend]. 
<shiftname>s are: ASL, LSL, LSR, ASR, ROR. ASL is a synonym for LSL, they assemble to the same code.

op2: 12 bits of a register or immediate value.
     register [rs shift]
     int8 [ n shift ]
)

( Set condition code flag. )
: a.s 20 bit-set ;

( Set the immediate bit in data ops. )
: a# 25 bit-set ;

( 12 bit field: 0:3 reg, 4 zero, 5:6 kind, 7:11 amount )
: a.shiftri ( reg amount kind -- op2 )
  5 bsl
  swap 0x1F logand 7 bsl
  logior logior
;

: a.lsli ( reg amount -- op2 )
  0 a.shiftri
;

: a.lsri ( reg amount -- op2 )
  1 a.shiftri
;

: a.asri ( reg amount -- op2 )
  2 a.shiftri
;

: a.rori ( reg amount -- op2 )
  3 a.shiftri
;

( 12 bit field: 0:3 reg, 4 one, 5:6 kind, 7 zero, 8:11 register )
: a.shiftrr ( reg rs kind -- op2 )
  1 bsl 1 logior 4 bsl
  swap 8 bsl
  logior logior
;

: a.lslr ( reg rs -- op2 )
  0 a.shiftrr
;

: a.lsrr ( reg rs -- op2 )
  1 a.shiftrr
;

: a.asrr ( reg rs -- op2 )
  2 a.shiftrr
;

: a.rorr ( reg rs -- op2 )
  3 a.shiftrr
;

( Shifts the immediate value right. )
( 12 bit field: 0:7 value 8:11 shift )
: a.shifti ( value shift -- op2 )
  1 bsr 0xF logand 8 bsl
  swap 255 logand
  logior a#
;
