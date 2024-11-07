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
alias> a.add add
alias> a.sub sub

: add ( rs rn rd )
  a.add
;

: sub
  a.sub
;


( todo immediates get shifted? )
: .immed .i ; ( fixme )

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
alias> a.rsc# rsc#

: and dup a.and ;
: eor dup a.eor ;
: lsl swap BARREL-BSL reg-shift swap dup a.movr ;
: lsr swap BARREL-BSR reg-shift swap dup a.movr ;
: asr swap BARREL-ASR reg-shift swap dup a.movr ;
: adc dup a.adc ;
: sbc dup a.sbc ;
: ror swap BARREL-RSR reg-shift swap dup a.movr ;
( : tst a.tst ; )
: neg 0 swap dup a.rsc# ;
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
: bx-hi bx ;

( 0 1 0 0 1 Rd Word:8 PC-relative load )
: ldr-pc ( value rd )
  pc swap ldr# .up .p
;

( 0 1 0 1 L B 0 Ro:3 Rb:3 Rd:3 Load/store with register offset )
alias> a.str str
alias> a.ldr ldr

: str ( Ro rb rd )
  a.str .up .p
;

: .byte .b ;

: ldr a.ldr .up .p ;

( 0 1 0 1 H S 1 Ro:3 Rb:3 Rd:3 Load/store sign-extended byte/halfword )
: .half 9 bit-set ;
: str-half strh .p ;
: ldr-half ldrh .p ;
: ldsb ldrsb .p ;
: ldsh ldrsh .p ;

( 0 1 1 B L Offset:5 Rb:3 Rd:3 Load/store with immediate offset )
: str-offset ( offset rb rd )
  str# .up .p
;

: ldr-offset
  ldr# .up .p
;

: .offset-byte .b ;

( 1 0 0 0 L Offset:5 Rb:3 Rd:3 Load/store halfword )
: strh ( offset rb rd )
  strhi
;

: ldrh ldrhi ;

( 1 0 0 1 L Rd:3 Word:8 SP-relative load/store )
: str-sp ( offset rd )
  swap 16 swap immed-op sp roll str# .up .p
;

: ldr-sp
  swap 16 swap immed-op sp roll ldr# .up .p
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
  sp stm .p .w
;

: .pclr dup 0 .l logand IF pc ELSE lr THEN bit-set ;

: popr sp ldm .w .up ;

( 1 1 0 0 L Rb Rlist Multiple load/store )
: stmia ( rb rlist ) swap stm .w .up ;
: ldmia swap ldm .w .up ;

( 1 1 1 0 0 Offset:11 Unconditional branch )
: branch ( byte-offset -- ins )
  b
;

( 1 1 1 1 H Offset:11 Long branch with link )
: branch-link ( byte-offset -- ins )
  bl
;

: branch-ins ( #ins -- ins )
  2 * 4 + branch
;

: branch-link-ins ( #ins -- ins )
  2 * 4 + branch-link
;

( 1 1 0 1 Cond:4 Soffset:8 Conditional branch )
( Branch if Z set, equal )
: beq ( offset ) branch .eq ;
: beq-ins ( offset ) branch-ins .eq ;

( Branch if Z clear, not equal )
: bne branch .ne ;
: bne-ins branch-ins .ne ;
( Branch if C set, unsigned higher or same )
: bcs branch .cs ;
: bcs-ins branch-ins .cs ;
( Branch if C clear, unsigned lower )
: bcc branch .cc ;
: bcc-ins branch-ins .cc ;
( Branch if N set, negative )
: bmi branch .mi ;
: bmi-ins branch-ins .mi ;
( Branch if N clear, positive or zero )
: bpl branch .pl ;
: bpl-ins branch-ins .pl ;
( Branch if V set, overflow )
: bvs branch .vs ;
: bvs-ins branch-ins .vs ;
( Branch if V clear, no overflow )
: bvc branch .vc ;
: bvc-ins branch-ins .vc ;
( Branch if C set and Z clear, unsigned higher )
: bhi branch .hi ;
: bhi-ins branch-ins .hi ;
( Branch if C clear or Z set, unsigned lower or same )
: bls branch .ls ;
: bls-ins branch-ins .ls ;
( Branch if N set and V set, or N clear and V clear, greater or equal )
: bge branch .ge ;
: bge-ins branch-ins .ge ;
( Branch if N set and V clear, or N clear and V set, less than )
: blt branch .lt ;
: blt-ins branch-ins .lt ;
( Branch if Z clear, and either N set and V set or N clear and V clear, greater than )
: bgt branch .gt ;
: bgt-ins branch-ins .gt ;
( Branch if Z set, or N set and V clear, or N clear and V set, less than or equal )
: ble branch .le ;
: ble-ins branch-ins .le ;

( 1 1 0 1 1 1 1 1 Value:8 Software Interrupt )
0 IF
: swi ( value )
  swi
;
THEN

alias> a.mrs mrs
alias> a.msr msr
alias> a.msri msri
alias> a.mcr mcr
alias> a.mrc mrc
alias> a.cdp cdp

: mrs ( reg ) a.mrs ;
: msr ( reg mask ) swap drop a.msri ;

: coproc-p .p ;
: coproc-u .up ;
: coproc-d 0 .up lognot logand ;
: coproc-w .w ;
: .ldc .l ;
: .cdp-n .n ;

: cdp ( CRn Op1 CRm Opc2 coproc CRd -- ins32 )
  3 overn ( op2 )
  5 overn ( crm )
  8 overn ( crn )
  4 overn ( crd )
  9 overn ( op1 )
  7 overn ( cp# )
  6 set-overn
  6 set-overn
  6 set-overn
  6 set-overn
  6 set-overn
  6 set-overn
  a.cdp
;
 
: mcr ( CRn Op1 CRm Op2 coproc Rxf )
  3 overn ( op2 )
  5 overn ( crm )
  8 overn ( crn )
  4 overn ( rxf )
  9 overn ( op1 )
  7 overn ( cp# )
  6 set-overn
  6 set-overn
  6 set-overn
  6 set-overn
  6 set-overn
  6 set-overn
  a.mcr
;

: mrc ( CRn Op1 CRm Op2 coproc Rxf )
  3 overn ( op2 )
  5 overn ( crm )
  8 overn ( crn )
  4 overn ( rxf )
  9 overn ( op1 )
  7 overn ( cp# )
  6 set-overn
  6 set-overn
  6 set-overn
  6 set-overn
  6 set-overn
  6 set-overn
  a.mrc
;

: cpuid-pfr0
  0 0 1 0 0xF 6 overn mrc
  swap drop
;

: cpuid-pfr1
  0 0 1 1 0xF 6 overn mrc
  swap drop
;

alias> a.stc stc
alias> a.ldc ldc

: stc ( Rn imm8 coproc CRd -- ins32 )
  2swap swap 2swap swap a.stc
;

: ldc ( Rn imm8 coproc CRd -- ins32 )
  2swap swap 2swap swap a.ldc
;

( Change processor endian mode. )
( 1 0 1 1 0 1 1 0 0 1 0 1 E 0 0 0 )
: setend
  0x1 logand
  0xB65 4 bsl logior
;

: bigend 1 setend ;
: lilend 0 setend ;

( Misc Thumb 2: )

: ldr-pc.w ldr-pc .w ;
 
( Helpers: )

: patch-ldr-pc!/2 ( where reg -- )
  ( replaces the instruction at ~where~ with a ~ldr-pc~ for ~dhere~. )
  swap dhere over - target-aarch32? IF 8 - ELSE 2 - THEN roll ldr-pc swap ins!
;

: patch-ldr-pc! ( where offset reg -- )
  ( replaces the instruction at ~where~ with a ~ldr-pc~ that loads from ~dhere + offset~ )
  dhere 4 overn - target-aarch32? IF 8 - ELSE 2 - THEN
  ( add the delta to the offset and poke with a new ldr-pc )
  roll + swap ldr-pc swap ins!
;

s[ src/lib/asm/thumb/helpers.4th
   src/lib/asm/thumb/vfp-constants.4th
   src/lib/asm/thumb/vfp.4th
] load-list