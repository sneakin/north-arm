( ARM Thumb Instruction Set: see ARM7TDMI Data Sheet, ARM DDI 0029E )

( Registers: )
: arm-gen-reg
  dup " r" ++ make-const
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
alias> fp r11
alias> sl r10

( 0 0 0 Op:2 Offset:5 Rs:3 Rd:3 Move shifted register )
: move-shifted-reg ( offset rs rd op )
  11 bsl logior
  swap 3 bsl logior
  swap 31 logand 6 bsl logior
;

: mov-lsl ( offset rs rd )
  0 move-shifted-reg
;

: mov-lsr ( offset rs rd )
  1 move-shifted-reg
;

: mov-asr ( offset rs rd )
  2 move-shifted-reg
;

( 0 0 0 1 1 I Op Rn/offset:3 Rs:3 Rd:3 Add/subtract )
: add ( rn rs rd )
  swap 3 bsl logior
  swap 0x7 logand 6 bsl logior
  3 11 bsl logior
;

: sub
  add 9 bit-set
;

: .immed 10 bit-set ;

( 0 0 1 Op:2 Rd:3 Offset:8 Move/compare/add/subtract immediate )
: mov# ( offset rd )
  8 bsl
  swap 0xFF logand logior
  1 13 bsl logior
;

: cmp# mov# 1 11 bsl logior ;
: add# mov# 2 11 bsl logior ;
: sub# mov# 3 11 bsl logior ;

( 0 1 0 0 0 0 Op:4 Rs:3 Rd:3 ALU operations )
: alu-op ( rs rd op )
  6 bsl logior
  swap 3 bsl logior
  1 14 bsl logior
;

: and 0 alu-op ;
: eor 1 alu-op ;
: lsl 2 alu-op ;
: lsr 3 alu-op ;
: asr 4 alu-op ;
: adc 5 alu-op ;
: sbc 6 alu-op ;
: ror 7 alu-op ;
: tst 8 alu-op ;
: neg 9 alu-op ;
: cmp 10 alu-op ;
: cmn 11 alu-op ;
: orr 12 alu-op ;
: mul 13 alu-op ;
: bic 14 alu-op ;
: mvn 15 alu-op ;

( 0 1 0 0 0 1 Op H1 H2 Rs/Hs:3 Rd/Hd:3 Hi register operations/branch exchange )
: hi-reg-op ( rs rd op )
  8 bsl
  swap 0x7 logand logior
  swap 0x7 logand 3 bsl logior
  17 10 bsl logior
;

: .hi1 7 bit-set ;
: .hi2 6 bit-set ;

: add-hilo 0 hi-reg-op .hi2 ;
: add-lohi 0 hi-reg-op .hi1 ;
: add-hihi 0 hi-reg-op .hi1 .hi2 ;

: cmp-hilo 1 hi-reg-op .hi2 ;
: cmp-lohi 1 hi-reg-op .hi1 ;
: cmp-hihi 1 hi-reg-op .hi1 .hi2 ;

: mov-hilo 2 hi-reg-op .hi2 ;
: mov-lohi 2 hi-reg-op .hi1 ;
: mov-hihi 2 hi-reg-op .hi1 .hi2 ;

: bx-lo 3 hi-reg-op ;
: bx-hi 3 hi-reg-op .hi2 ;

( 0 1 0 0 1 Rd Word:8 PC-relative load )
: ldr-pc ( value rd )
  8 bsl
  swap 2 bsr 0xFF logand logior
  9 11 bsl logior
;

( 0 1 0 1 L B 0 Ro:3 Rb:3 Rd:3 Load/store with register offset )
: str ( Ro rb rd )
  swap 3 bsl logior
  swap 6 bsl logior
  5 12 bsl logior
;

: .load 11 bit-set ;
: .byte 10 bit-set ;

: ldr str .load ;

( 0 1 0 1 H S 1 Ro:3 Rb:3 Rd:3 Load/store sign-extended byte/halfword )
: .half 9 bit-set ;
: str-half str .half ;
: ldr-half ldr .half ;
: ldsb ldr .byte ;
: ldsh ldr .half .byte ;

( 0 1 1 B L Offset:5 Rb:3 Rd:3 Load/store with immediate offset )
: str-offset ( offset rb rd )
  swap 3 bsl logior
  swap 2 bsr 31 logand 6 bsl logior
  3 13 bsl logior
;

: ldr-offset
  str-offset .load
;

: .offset-byte 12 bit-set ;

( 1 0 0 0 L Offset:5 Rb:3 Rd:3 Load/store halfword )
: strh ( offset rb rd )
  swap 3 bsl logior
  swap 31 logand 6 bsl logior
  1 15 bsl logior
;

: ldrh strh .load ;

( 1 0 0 1 L Rd:3 Word:8 SP-relative load/store )
: str-sp ( offset rd )
  8 bsl
  swap 2 bsr 0xFF logand logior
  9 12 bsl logior
;

: ldr-sp str-sp .load ;

( 1 0 1 0 SP Rd:3 Word:8 Load address )
: add-pc ( addr rd )
  8 bsl
  swap 2 bsr 0xFF logand logior
  10 12 bsl logior
;

: add-sp add-pc 11 bit-set ;

( 1 0 1 1 0 0 0 0 S SWord:7 Add offset to stack pointer )
: inc-sp ( offset )
  2 bsr
  11 12 bsl logior
;

: dec-sp inc-sp 7 bit-set ;

( 1 0 1 1 L 1 0 R Rlist Push/pop registers )
: pushr ( rlist )
  0xFF logand
  10 bit-set
  11 12 bsl logior
;

: .pclr 8 bit-set ;

: popr pushr .load ;

( 1 1 0 0 L Rb Rlist Multiple load/store )
: stmia ( rb rlist )
  0xFF logand
  swap 3 bsl logior
  12 12 bsl logior
;

: ldmia stmia .load ;

( 1 1 0 1 Cond:4 Soffset:8 Conditional branch )
( Branch if Z set, equal )
: beq ( offset )
  1 bsr 0xFF logand
  13 12 bsl logior
;

: set-branch-cond 8 bsl logior ;

( Branch if Z clear, not equal )
: bne beq 1 set-branch-cond ;
( Branch if C set, unsigned higher or same )
: bcs beq 2 set-branch-cond ;
( Branch if C clear, unsigned lower )
: bcc beq 3 set-branch-cond ;
( Branch if N set, negative )
: bmi beq 4 set-branch-cond ;
( Branch if N clear, positive or zero )
: bpl beq 5 set-branch-cond ;
( Branch if V set, overflow )
: bvs beq 6 set-branch-cond ;
( Branch if V clear, no overflow )
: bvc beq 7 set-branch-cond ;
( Branch if C set and Z clear, unsigned higher )
: bhi beq 8 set-branch-cond ;
( Branch if C clear or Z set, unsigned lower or same )
: bls beq 9 set-branch-cond ;
( Branch if N set and V set, or N clear and V clear, greater or equal )
: bge beq 10 set-branch-cond ;
( Branch if N set and V clear, or N clear and V set, less than )
: blt beq 11 set-branch-cond ;
( Branch if Z clear, and either N set and V set or N clear and V clear, greater than )
: bgt beq 12 set-branch-cond ;
( Branch if Z set, or N set and V clear, or N clear and V set, less than or equal )
: ble beq 13 set-branch-cond ;

( 1 1 0 1 1 1 1 1 Value:8 Software Interrupt )
: swi ( value )
  0xFF logand
  31 8 bsl logior
  13 12 bsl logior
;

( 1 1 1 0 0 Offset:11 Unconditional branch )
: branch ( offset )
  1 bsr 0x7FF logand
  14 12 bsl logior
;

( 1 1 1 1 H Offset:11 Long branch with link )
: bl-hi ( offset-hi )
  0x7FF logand
  15 12 bsl logior
;

: bl-lo ( offset-lo )
  bl-hi 11 bit-set
;

: branch-long ( offset -- 32bit-ins )
  dup 12 bsr bl-hi
  swap 1 bsr bl-lo 16 bsl
  logior
;

: bkpt/1
  0xFF logand 0xBE00 logior
;

: bkpt
  0 bkpt/1
;