( ARM Thumb2 Instructions:
  see ARM Architecture Reference Manual: Thumb-2 Supplement
)

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

( Coprocessor: )

( 1 1 1 C 1 1 )
: coproc 0xEC00 ;

( MRRC & MCRR registers: )
( 1 1 1 C 1 1 0 0 0 1 0 L Rt2:4 )
: mcrr-hi ( rt2 -- ins16 )
  0xF logand
  1 6 bsl logior
  coproc logior
;

: mrrc-hi mcrr-hi 4 bit-set ;

( Rt Coproc OpC CRm )
: mcrr-lo ( CRm Opc Coproc Rt -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior 4 bsl
  swap 0xF logand logior 4 bsl
  swap 0xF logand logior
;

: mcrr
  mcrr-lo 16 bsl
  swap mcrr-hi logior
;

: mrrc
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

: stc
  stc-lo 16 bsl
  swap stc-hi logior
;

: ldc
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
  rot swap cdp-hi
  logior
;

: .cdp-n 23 bit-set ;

( Register transfers: )
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
  rot swap mcr-hi logior
;

( Transfer from coprocessor. )
: mrc ( CRn Op1 CRm Op2 coproc Rxf )
  mcr-lo 16 bsl
  rot swap mrc-hi logior
;

: cpuid-pfr0
  0 0 1 0 0xF 6 overn mrc
  swap drop
;

: cpuid-pfr1
  0 0 1 1 0xF 6 overn mrc
  swap drop
;
