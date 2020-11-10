( VFP: see ddi0100e_arm_arm.pdf )

: fmsr.32 ( Rxf CRm -- ins32 )
  ( ARM to VFP float )
  ( CRn Op1 CRm Op2 coproc Rxf )
  dup 1 bsr
  0
  0
  4 overn 1 logand 2 bsl
  10
  7 overn
  mcr rot 2 dropn
;

: fmrs.32 ( VFP float to ARM )
  ( CRn Op1 CRm Op2 coproc Rxf )
  over 1 bsr
  0
  0
  5 overn 1 logand 2 bsl
  10
  6 overn
  mrc rot 2 dropn
;

: fmrx.32 ( fn rd )
  ( ARm register to VFP status )
  ( CRn Op1 CRm Op2 coproc Rxf )
  over 7 0 0 10 6 overn mrc
  rot 2 dropn
;

: fmxr.32 ( rd fn )
  ( VFP status to ARM )
  dup 7 0 0 10 7 overn mcr
  rot 2 dropn
;

( 32 & 64 bit only differs in coprocessor [and data size], and last bits fiddling )
( todo use ARM or GCC mneumonics? )
( ideally functions get a set of integer and a set of floating point args in registers w/o touching the stack. )

: vfp-cdp.32
  ( Register low bit gets placed into the op code fields. )
  ( CRn Op1 CRm Opc2 CRd )
  5 overn 1 logand 2 bsl 4 overn 1 logand logior 3 overn logior 2 set-overn ( Opc2 ||= N s M 0 )
  1 overn 1 logand 2 bsl 5 overn logior 4 set-overn ( Op1 ||= P D Q R )
  5 overn 1 bsr 5 set-overn ( shift CRn )
  3 overn 1 bsr 3 set-overn ( shift CRm )
  1 overn 1 bsr 1 set-overn ( shift CRd )
  10 swap cdp
;

: fadd.32 ( fm fn fd )
  3 overn 3 4 overn 0 5 overn vfp-cdp.32
  3 set-overn 2 dropn
;

: fsub.32 ( fm fn fd )
  3 overn 3 4 overn 2 5 overn vfp-cdp.32
  3 set-overn 2 dropn
;

: fmul.32 ( fm fn fd )
  3 overn 2 4 overn 0 5 overn vfp-cdp.32
  3 set-overn 2 dropn
;

: fdiv.32 ( fm fn fd )
  3 overn 8 4 overn 0 5 overn vfp-cdp.32
  3 set-overn 2 dropn
;

: fnegs
  2 0xB 4 overn 2 5 overn vfp-cdp.32
  rot 2 dropn
;

: fabss
  1 0xB 4 overn 2 5 overn vfp-cdp.32
  rot 2 dropn
;

: fcmps
  8 0xB 4 overn 2 5 overn vfp-cdp.32
  rot 2 dropn
;

: fcmpzs
  10 0xB 0 2 5 overn vfp-cdp.32
  swap drop
;

: fuitos ( fm fd )
  ( uint32 to float32 )
  16 0xB 4 overn 2 5 overn vfp-cdp.32
  rot 2 dropn
;

: fsitos ( fm fd )
  ( int32 to float32 )
  17 0xB 4 overn 2 5 overn vfp-cdp.32
  rot 2 dropn
;

: ftouis ( fm fd )
  ( float32 to uint32 )
  0x18 0xB 4 overn 2 5 overn vfp-cdp.32
  rot 2 dropn
;

: ftouizs ( fm fd )
  ( float32 to uint32, round to zero )
  0x19 0xB 4 overn 2 5 overn vfp-cdp.32
  rot 2 dropn
;

: ftosis ( fm fd )
  ( float32 to int32 )
  0x1A 0xB 4 overn 2 5 overn vfp-cdp.32
  rot 2 dropn
;

: ftosizs ( fm fd )
  ( float32 to int32, round to zero )
  0x1B 0xB 4 overn 2 5 overn vfp-cdp.32
  rot 2 dropn
;

: fcvtds ( fm fd )
  ( float32 to float64 )
  0xF 0xB 4 overn 2 5 overn vfp-cdp.32
  rot 2 dropn
;

( Double precision: )

: fmdlr.64 ( Rxf CRm -- ins32 )
  ( ARM to VFP float64[0:31] )
  ( CRn Op1 CRm Op2 coproc Rxf )
  dup 0 0 0 11 7 overn mcr
  rot 2 dropn
;

: fmrdl.64
  ( VFP float64[0:31] to ARM )
  ( CRn Op1 CRm Op2 coproc Rxf )
  over 0 0 0 11 6 overn mrc
  rot 2 dropn
;

: fmdhr.64 ( Rxf CRm -- ins32 )
  ( ARM to float64[32:63] )
  ( CRn Op1 CRm Op2 coproc Rxf )
  dup 1 0 0 11 7 overn mcr
  rot 2 dropn
;

: fmrdh.64
  ( VFP float64[32:63] to ARM )
  ( CRn Op1 CRm Op2 coproc Rxf )
  over 1 0 0 11 6 overn mrc
  rot 2 dropn
;

: fadd.64 ( fm fn fd )
  ( CRn Op1 CRm Opc2 coproc CRd )
  3 overn 3 4 overn 0 11 6 overn cdp
  3 set-overn 2 dropn
;

: fsub.64 ( fm fn fd )
  ( CRn Op1 CRm Opc2 coproc CRd )
  3 overn 3 4 overn 2 11 6 overn cdp
  3 set-overn 2 dropn
;

: fmul.64 ( fm fn fd )
  ( CRn Op1 CRm Opc2 coproc CRd )
  3 overn 2 4 overn 0 11 6 overn cdp
  3 set-overn 2 dropn
;

: fdiv.64 ( fm fn fd )
  ( CRn Op1 CRm Opc2 coproc CRd )
  3 overn 8 4 overn 0 11 6 overn cdp
  3 set-overn 2 dropn
;

: fnegd
  1 0xB 4 overn 2 11 6 overn cdp
  rot 2 dropn
;

: fabsd
  0 0xB 4 overn 6 11 6 overn cdp
  rot 2 dropn
;

: fcmpd
  4 0xB 4 overn 6 11 6 overn cdp
  rot 2 dropn
;

: fcmpzd
  5 0xB 0 6 11 6 overn cdp
  swap drop
;

: ftouid ( fm fd )
  ( float64 to uint32 )
  0xC 0xB 4 overn 2 11 6 overn cdp
  rot 2 dropn
;

: ftouizd ( fm fd )
  ( float64 to uint32, round to zero )
  0xC 0xB 4 overn 6 11 6 overn cdp
  rot 2 dropn
;

: ftosid ( fm fd )
  ( float64 to int32 )
  0xD 0xB 4 overn 2 11 6 overn cdp
  rot 2 dropn
;

: ftosizd ( fm fd )
  ( float64 to int32, round to zero )
  0xD 0xB 4 overn 6 11 6 overn cdp
  rot 2 dropn
;

: fuitod
  ( uint32 to float64 )
  ( CRn Op1 CRm Opc2 coproc CRd )
  8 0xB 4 overn 2 11 6 overn cdp
  rot 2 dropn
;

: fsitod ( fm fd )
  ( int32 to float64 )
  8 0xB 4 overn 6 11 6 overn cdp
  rot 2 dropn
;

: fcvtsd ( fm fd )
  ( float64 to float32 )
  7 0xB 4 overn 6 11 6 overn cdp
  rot 2 dropn
;
