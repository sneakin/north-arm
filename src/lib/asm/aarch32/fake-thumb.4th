( ARM Thumb ops translated to equivalent A32: )

" src/lib/asm/aarch32.4th" load

alias> a.movr movr

: thumb-nop nop ;

: mov-lsl ( offset rs rd )
  rot BARREL-BSL immed-shift rot a.movr
;

: mov-lsr ( offset rs rd )
  rot BARREL-BSR immed-shift rot a.movr
;

: mov-asr ( offset rs rd )
  rot BARREL-ASR immed-shift rot a.movr
;

( 0 0 0 1 1 I Op Rn/offset:3 Rs:3 Rd:3 Add/subtract )
0 IF
: add ( rn rs rd )
  add
;

: sub
  sub
;
THEN

( todo immediates get shifted? )
: .immed ~.i ;

( 0 0 1 Op:2 Rd:3 Offset:8 Move/compare/add/subtract immediate )
alias> a.mov# mov#
alias> a.cmp# cmp#
alias> a.add# add#
alias> a.sub# sub#

: mov# ( offset rd )
  16 shift a.mov#
;

: cmp# 16 shift a.cmp# ;
: add# 16 shift dup a.add# ;
: sub# 16 shift dup a.sub# ;

( 0 1 0 0 0 0 Op:4 Rs:3 Rd:3 ALU operations )
alias> a.and and
alias> a.eor eor
alias> a.adc adc
alias> a.sbc sbc
alias> a.tst tst
alias> a.cmp cmp
alias> a.cmn cmn
alias> a.orr orr
alias> a.mul mul
alias> a.bic bic
alias> a.mvn mvn

: and dup a.and ;
: eor dup a.eor ;
: lsl swap BARREL-BSL reg-shift swap dup a.movr ;
: lsr swap BARREL-BSR reg-shift swap dup a.movr ;
: asr swap BARREL-ASR reg-shift swap dup a.movr ;
: adc dup a.adc ;
: sbc dup a.sbc ;
: ror swap BARREL-RSR reg-shift swap dup a.movr ;
( : tst a.tst ; )
: neg dup a.mvn ;
( : cmp a.cmp ; )
( : cmn a.cmn ; )
: orr dup a.orr ;
: mul dup a.mul ;
: bic dup a.bic ;
( : mvn a.mvn ; )


( 0 1 0 0 0 1 Op H1 H2 Rs/Hs:3 Rd/Hd:3 Hi register operations/branch exchange )

: hilo-operands swap 8 + swap ;
: lohi-operands 8 + ;
: hihi-operands 8 + swap 8 + swap ;

: add-hilo dup add ;
: add-lohi dup add ;
: add-hihi dup add ;
: addrr dup add ;

: cmp-hilo cmp ;
: cmp-lohi cmp ;
: cmp-hihi cmp ;
: cmprr cmp ;

: mov-hilo mov ;
: mov-lohi mov ;
: mov-hihi mov ;
: movrr mov ;

: bx-lo bx ;
: bx-hi 8 + bx ;

( 0 1 0 0 1 Rd Word:8 PC-relative load )
: ldr-pc ( value rd )
  swap 16 swap immed-op pc roll ldr# .up
;

( 0 1 0 1 L B 0 Ro:3 Rb:3 Rd:3 Load/store with register offset )
alias> a.str str
alias> a.ldr ldr

: str ( Ro rb rd )
  a.str .up
;

: .byte .b ;

: ldr a.ldr .up ;

( 0 1 0 1 H S 1 Ro:3 Rb:3 Rd:3 Load/store sign-extended byte/halfword )
: .half 9 bit-set ;
: str-half strh ;
: ldr-half ldrh ;
: ldsb ldrsb ;
: ldsh ldrsh ;

( 0 1 1 B L Offset:5 Rb:3 Rd:3 Load/store with immediate offset )
: str-offset ( offset rb rd )
  str# .up
;

: ldr-offset
  ldr# .up
;

: .offset-byte .b ;

( 1 0 0 0 L Offset:5 Rb:3 Rd:3 Load/store halfword )
: strh ( offset rb rd )
  strhi
;

: ldrh ldrhi ;

( 1 0 0 1 L Rd:3 Word:8 SP-relative load/store )
: str-sp ( offset rd )
  swap 16 swap immed-op sp roll str# .up
;

: ldr-sp
  swap 16 swap immed-op sp roll ldr# .up
;

( 1 0 1 0 SP Rd:3 Word:8 Load address )
: addr-pc ( addr rd )
  16 shift pc swap a.add#
;

: addr-sp 16 shift sp swap a.add# ;

( 1 0 1 1 0 0 0 0 S SWord:7 Add offset to stack pointer )
: inc-sp ( offset )
  0 swap sp sp a.add#
;

: dec-sp
  0 swap sp sp a.sub#
;

( 1 0 1 1 L 1 0 R Rlist Push/pop registers )
: pushr ( rlist )
  sp stm .w
;

: .pclr dup 0 .l logand IF pc ELSE lr THEN bit-set ;

: popr pushr .l ;

( 1 1 0 0 L Rb Rlist Multiple load/store )
: stmia ( rb rlist ) swap stm ;
: ldmia swap ldm ;

( 1 1 0 1 Cond:4 Soffset:8 Conditional branch )
( Branch if Z set, equal )
: beq ( offset ) b .eq ;

( Branch if Z clear, not equal )
: bne b .ne ;
( Branch if C set, unsigned higher or same )
: bcs b .cs ;
( Branch if C clear, unsigned lower )
: bcc b .cc ;
( Branch if N set, negative )
: bmi b .mi ;
( Branch if N clear, positive or zero )
: bpl b .pl ;
( Branch if V set, overflow )
: bvs b .vs ;
( Branch if V clear, no overflow )
: bvc b .vc ;
( Branch if C set and Z clear, unsigned higher )
: bhi b .hi ;
( Branch if C clear or Z set, unsigned lower or same )
: bls b .ls ;
( Branch if N set and V set, or N clear and V clear, greater or equal )
: bge b .ge ;
( Branch if N set and V clear, or N clear and V set, less than )
: blt b .lt ;
( Branch if Z clear, and either N set and V set or N clear and V clear, greater than )
: bgt b .gt ;
( Branch if Z set, or N set and V clear, or N clear and V set, less than or equal )
: ble b .le ;

( 1 1 0 1 1 1 1 1 Value:8 Software Interrupt )
0 IF
: swi ( value )
  swi
;
THEN

( 1 1 1 0 0 Offset:11 Unconditional branch )
: branch ( offset )
  b
;

( 1 1 1 1 H Offset:11 Long branch with link )
: branch-link ( offset -- 32bit-ins )
  bl
;

: bkpt/1
  swi
;

: bkpt
  0 swi
;

( Change processor endian mode. )
( 1 0 1 1 0 1 1 0 0 1 0 1 E 0 0 0 )
: setend
  0x1 logand
  0xB65 4 bsl logior
;

: bigend 1 setend ;
: lilend 0 setend ;

( Helpers: )

0 IF
: emit-load-int32 ( n reg )
  ( 0xAAbbccdd )
  2 overn 24 bsr 0xFF logand 2 overn mov# ,ins ( init reg with highest byte )
  2 overn 0xFF000000 logand IF 8 over dup mov-lsl ,ins ( reg<<8 ) THEN
  ( 0xaaBBccdd )
  2 overn 16 bsr 0xFF logand
  dup 0 equals IF drop ELSE 2 overn add# ,ins ( add byte to reg<<8 ) THEN
  2 overn 0xFFFF0000 logand IF 8 over dup mov-lsl ,ins ( reg<<8 ) THEN
  ( 0xaabbCCdd )
  2 overn 8 bsr 0xFF logand
  dup 0 equals IF drop ELSE 2 overn add# ,ins ( add byte to reg<<8 ) THEN
  2 overn 0xFFFFFF00 logand IF 8 over dup mov-lsl ,ins ( reg<<8 ) THEN
  ( 0xaabbccDD )
  2 overn 0xFF logand
  dup 0 equals IF drop ELSE 2 overn add# ,ins ( add byte to reg<<8 ) THEN
  2 dropn
;
THEN

" src/lib/asm/thumb/helpers.4th" load