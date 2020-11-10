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
: mcrr-lo ( rt2 -- ins16 )
  0xF logand
  1 6 bsl logior
  coproc logior
;

: mrrc-lo mcrr-lo 4 bit-set ;

( Rt Coproc OpC CRm )
: mcrr-hi ( CRm Opc Coproc Rt -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior 4 bsl
  swap 0xF logand logior 4 bsl
  swap 0xF logand logior
;

: mcrr
  mcrr-hi 16 bsl
  swap mcrr-lo logior
;

: mrrc
  mcrr-hi 16 bsl
  swap mrrc-lo logior
;

( Load & store: )
( 1 1 1 C 1 1 0 P U N W L Rn:4 )
: coproc-str-lo ( Rn -- ins16 )
  0xF logand coproc logior
;

: .coproc-ldr 1 5 bsl logior ;

( CRd:4 coproc:4 imm:8 )
: coproc-str-hi ( imm8 coproc CRd -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior 8 bsl
  swap 0xFF logand logior
;

: coproc-str
  coproc-str-hi 16 bsl
  swap coproc-str-lo logior
;

( Data processing: )
( 1 1 1 C 1 1 1 0 Op1:4 CRn:4 )
: cdp-lo ( CRn Op1 -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior
  coproc logior
  9 bit-set
;

( CRd:4 coproc:4 Opc2:3 0 CRm:4 )
: cdp-hi ( CRm Opc2 coproc CRd -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior 3 bsl
  swap 0x7 logand logior 5 bsl
  swap 0xF logand logior
;

: cdp ( CRn Op1 CRm Opc2 coproc CRd -- ins32 )
  cdp-hi 16 bsl
  rot swap cdp-lo
  logior
;

( Register transfers: )
( 1 1 1 C 1 1 1 0 Op1:3 L CRn:4 )
: mcr-lo ( CRn Op1 -- ins16 )
  0x7 logand 5 bsl
  swap 0xF logand logior
  coproc logior
  9 bit-set
;

: mrc-lo mcr-lo 4 bit-set ;

( Rxf:4 coproc:4 Op2:3 1 CRm:4 )
: mcr-hi ( CRm Op2 coproc Rxf -- ins16 )
  0xF logand 4 bsl
  swap 0xF logand logior 3 bsl
  swap 0x7 logand logior 1 bsl
  1 logior 4 bsl
  swap 0xF logand logior
;

: mcr ( CRn Op1 CRm Op2 coproc Rxf )
  mcr-hi 16 bsl
  rot swap mcr-lo logior
;

: mrc ( CRn Op1 CRm Op2 coproc Rxf )
  mcr-hi 16 bsl
  rot swap mrc-lo logior
;
