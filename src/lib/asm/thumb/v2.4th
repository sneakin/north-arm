( ARM Thumb2 Instructions:
  see ARM Architecture Reference Manual: Thumb-2 Supplement
)

: swap-short
  dup 16 bsr 0xFFFF logand
  swap 0xFFFF logand 16 bsl logior
;

( 0 1 0 0 0 1 1 1 1 Rm 0 0 0 )
: blx
  0xF logand 3 bsl
  0x4780 logior
;

( 1 1 1 1 0 S cond:4 imm:6 1 0 J1 0 J2 imm:11 )
: bw
  negative? IF 0 26 bit-set ELSE 0 THEN
  over 17 bit-set? IF 11 bit-set THEN
  over 16 bit-set? IF 13 bit-set THEN
  swap
  ( dup error-hex-uint espace
  dup 0x1f + error-hex-uint )
  1 bsr
  dup 0x7FF logand
  swap 11 bsr 0x3F logand 16 bsl logior
  0xF0008000 logior logior
  swap-short
;

: .bne 1 6 bsl logior ;
: .bcs 2 6 bsl logior ;

( 1 1 1 1, 1 0 0 0, U 1 0 1, 1 1 1 1, Rt:4 imm:12 )
: ldr-pc.w ( imm reg -- ins32 )
  swap negative? IF abs-int 0 ELSE 0x80 THEN
  0xF85F logior
  rot  ( ins imm reg )
  0xF logand 12 bsl
  swap 0xFFF logand
  logior 16 bsl logior
;

( 1 1 1 1, 1 0 1 1, 1 0 0 1, Rn:4 | [1] [1] [1] [1] Rd:4 1 1 1 1 Rm:4 )
: sdiv-hi ( rn -- half-op )
  0xFB90 logior
;

: sdiv-lo ( rm rd -- half-op )
  8 bsl 0xF0F0 logior logior
;

( Signed division: )
: sdiv ( rm rn rd -- thumb-op32 )
  swap sdiv-hi
  rot swap sdiv-lo
  16 bsl logior
;

( 1 1 1 1, 1 0 1 1, 1 0 1 1, Rn:4 | [1] [1] [1] [1] Rd:4 1 1 1 1 Rm:4 )
: udiv-hi ( rn -- half-op )
  0xFBB0 logior
;

( Unsigned division: )
: udiv ( rm rn rd -- thumb-op32 )
  swap udiv-hi
  rot swap sdiv-lo
  16 bsl logior
;

( CPU Status: )

( Status bits: N Z C V Q IT[1:0] J Reserved GE[3:0] IT[7:2] E A I F T M[4:0]
  N negative
  Z zero
  C carry
  V overflow
  Q saturated
  GE SIMD greater than or equal
  IT condition flags for IT blocks
  J Jazelle mode
  T Thumb mode
  E Big endian mode
  A async abort disabled
  I interrupt disable
  F fast interrupt disable
  M mode bits
)

0x1 const> CPSR-C ( write bits 7:0 )
0x2 const> CPSR-X ( bits 15:8 )
0x4 const> CPSR-S ( bits 23:16 )
0x8 const> CPSR-F ( bits 31:24 )

0x10 const> CPSR-MODE-USER
0x11 const> CPSR-MODE-FIQ
0x12 const> CPSR-MODE-IRQ
0x13 const> CPSR-MODE-SUPERVISOR
0x16 const> CPSR-MODE-MONITOR
0x17 const> CPSR-MODE-ABORT
0x1B const> CPSR-MODE-UNDEF
0x1F const> CPSR-MODE-SYSTEM


( 1 1 1 1, 0 0 1 1, 1 1 1 R, 1 1 1 1; 1 0 0 0, Rd:4, 0:8 )
: mrs ( reg -- ins )
  0xF logand 24 bsl 0x8000F3EF logior ( todo 0xf3ef right? )
;

: .spsr 20 bit-set ; ( saved CPSR state )

( 1 1 1 1, 0 0 1 1, 1 0 0 R, Rn:4; 1 0 0 0, mask:4, 0:8 )
: msr ( reg mask -- ins )
  0xF logand 24 bsl
  swap 0xF logand
  0x8000F380
  logior logior
;

( Coprocessor: )

( 1 1 1 C 1 1 )
: coproc 0xEC00 ;

( MRRC & MCRR registers: )
( 1 1 1 C 1 1 0 0 0 1 0 L Rt2:4 )
: mcrr-hi ( rt2 -- ins16 )
  0xF logand
  coproc logior 6 bit-set
;

: mrrc-hi mcrr-hi 4 bit-set ;

( Rt Coproc OpC CRm )
: mcrr-lo ( CRm Opc Coproc Rt -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior 4 bsl
  swap 0xF logand logior 4 bsl
  swap 0xF logand logior
;

: mcrr ( Rt2 CRm Opc Coproc Rt -- ins32 )
  mcrr-lo 16 bsl
  swap mcrr-hi logior
;

: mrrc ( Rt2 CRm Opc Coproc Rt -- ins32 )
  mcrr-lo 16 bsl
  swap mrrc-hi logior
;

( Load & store: )

: coproc-p 8 bit-set ;
: coproc-u 7 bit-set ;
: coproc-d 6 bit-set ;
: coproc-w 5 bit-set ;

( 1 1 1 C 1 1 0 P U N W L Rn:4 )
: stc-hi ( Rn -- ins16 )
  0xF logand coproc logior
;

: .ldc 4 bit-set ;
: ldc-hi stc-hi .ldc ;

( coproc:4 CRd:4 imm:8 )
: stc-lo ( imm8 coproc CRd -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior 8 bsl
  swap 0xFF logand logior
;

: stc ( Rn imm8 coproc CRd -- ins32 )
  stc-lo 16 bsl
  swap stc-hi logior
;

: ldc ( Rn imm8 coproc CRd -- ins32 )
  stc-lo 16 bsl
  swap ldc-hi logior
;

( Data processing: )
( 1 1 1 C 1 1 1 0 Op1:4 CRn:4 )
: cdp-hi ( CRn Op1 -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior
  coproc logior
  9 bit-set
;

( CRd:4 coproc:4 Opc2:3 0 CRm:4 )
: cdp-lo ( CRm Opc2 coproc CRd -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior 3 bsl
  swap 0x7 logand logior 5 bsl
  swap 0xF logand logior
;

: cdp ( CRn Op1 CRm Opc2 coproc CRd -- ins32 )
  cdp-lo 16 bsl
  shift cdp-hi
  logior
;

: .cdp-n 23 bit-set ;

( Register transfers: )
( todo reorder args to match actual asm )

( 1 1 1 C 1 1 1 0 Op1:3 L CRn:4 )
: mcr-hi ( CRn Op1 -- ins16 )
  0x7 logand 5 bsl
  swap 0xF logand logior
  coproc logior
  9 bit-set
;

: mrc-hi mcr-hi 4 bit-set ;

( Rxf:4 coproc:4 Op2:3 1 CRm:4 )
: mcr-lo ( CRm Op2 coproc Rxf -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior 3 bsl
  swap 0x7 logand logior 1 bsl
  1 logior 4 bsl
  swap 0xF logand logior
;

( Transfer to coprocessor. )
: mcr ( CRn Op1 CRm Op2 coproc Rxf )
  mcr-lo 16 bsl
  shift mcr-hi logior
;

( Transfer from coprocessor. )
: mrc ( CRn Op1 CRm Op2 coproc Rxf )
  mcr-lo 16 bsl
  shift mrc-hi logior
;

: cpuid-pfr0
  0 0 1 0 0xF 6 overn mrc
  swap drop
;

: cpuid-pfr1
  0 0 1 1 0xF 6 overn mrc
  swap drop
;

( Table branch byte: branch by the byte stored in table times two. )
: tbb ( index-reg base-reg -- hi lo )
  ( 1 1 1 0  1 0 0 0  1 1 0 1  Rn, 1 1 1 1  0 0 0 0  0 0 0 0  Rm )
  0xF logand 0xE8D0 logior
  swap 0xF logand 0xF000 logior 16 bsl logior
;

( Table branch half word: branch by the short stored in table times two. )
: tbh ( index-reg base-reg -- hi lo )
  ( 1 1 1 0  1 0 0 0  1 1 0 1  Rn, 1 1 1 1  0 0 0 0  0 0 0 1  Rm )
  tbb 0x100000 logior
;
