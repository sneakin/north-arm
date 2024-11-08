( VFP: see ddi0100e_arm_arm.pdf )

( Register transfers: )

: fmsrs ( Rxf CRm -- ins32 )
  ( ARM to VFP float )
  dup 1 logand 2 bsl
  0
  3 overn 1 bsr
  5 overn
  0
  10
  mcr rot 2 dropn
;

: fmrss ( fn fd )
  ( VFP float to ARM )
  2 overn 1 logand 2 bsl
  0
  4 overn 1 bsr
  4 overn
  0
  10
  mrc rot 2 dropn
;

: fmrxs ( fn rd )
  ( VFP status to ARM )
  0 0 4 overn 4 overn 7 10 mrc
  rot 2 dropn
;

: fmxrs ( rd fn )
  ( ARM register to VFP status )
  0 0 3 overn 5 overn 7 10 mcr
  rot 2 dropn
;

( Load & Store: )

( Single precision L&S: )

: fstores ( offset Rn Fd -- ins32 )
  ( -> Rn imm8 coproc CRd -> ins32 )
  2 overn 4 overn 10 4 overn 1 bsr stc
  swap 1 logand ( fixme? negative test? ) IF coproc-d THEN
  rot 2 dropn
;

: fsts- ( offset Rn Fd -- ins32 )
  rot 2 bsr rot fstores coproc-p
;

: fsts+
  rot 2 bsr rot fstores coproc-p coproc-u
;

( Store a single at Rn+offset. )
: fsts
  3 overn 0 int<
  IF 3 overn negate 3 set-overn fsts-
  ELSE fsts+
  THEN
;

: flds- fsts- .ldc ;
: flds+ fsts+ .ldc ;

( Load a single at Rn+offset. )
: flds fsts .ldc ;

( Store multiple singles. )
: fstms ( count Rn CRs -- ins32 )
  fstores coproc-u
;

( Store multiple singles with auto-increment. )
: fstms+ fstms coproc-w ;
( Store multiple singles with auto-decrement. )
: fstms- fstores coproc-p coproc-w ;

( Load multiple singles. )
: fldms ( count Rn CRs -- ins32 )
  fstms .ldc
;

( Load multiple singles with auto-increment. )
: fldms+ fstms+ .ldc ;
( Load multiple singles with auto-decrement. )
: fldms- fstms- .ldc ;

: vpopn ( count Cr -- ins32 )
  sp swap fldms+
;

: vpop ( Cr -- ins32 )
  1 swap vpopn
;

: vpushn ( count Cr -- ins32 )
  sp swap fstms-
;

: vpush ( Cr -- ins32 )
  1 swap vpushn
;

( Double precision L&S: )

: fstored ( offset Rn Fd -- ins32 )
  ( -> Rn imm8 coproc CRd -> ins32 )
  swap rot swap 11 swap stc
;

: fstd- rot 2 bsr rot fstored coproc-p ;
: fstd+ rot 2 bsr rot fstored coproc-p coproc-u ;

( Store a double at Rn+offset. )
: fstd
  3 overn 0 int<
  IF 3 overn negate 3 set-overn fstd-
  ELSE fstd+
  THEN
;

: fldd+ fstd+ .ldc ;
: fldd- fstd- .ldc ;

( Load a double at Rn+offset. )
: fldd fstd .ldc ;

( Store multiple doubles. )
: fstmd ( count Rn CRs -- ins32 )
  rot 1 bsl rot fstored coproc-u
;

( Store multiple doubles with auto-increment. )
: fstmd+ fstmd coproc-w ;
( Store multiple doubles with auto-decrement. )
: fstmd- fstored coproc-p coproc-w ;

( Load multiple doubles. )
: fldmd ( count Rn CRs -- ins32 )
  fstmd .ldc
;

( Load multiple doubles with auto-increment. )
: fldmd+ fstmd+ .ldc ;
( Load multiple doubles with auto-decrement. )
: fldmd- fstmd- .ldc ;

: vpopnd ( count Cr -- ins32 )
  sp swap fldmd+
;

: vpopd ( Cr -- ins32 )
  1 swap vpopnd
;

: vpushnd ( count Cr -- ins32 )
  sp swap fstmd-
;

: vpushd ( Cr -- ins32 )
  1 swap vpushnd
;

( VFP internal format L&S: )

: fstorex ( count Rn CRs -- ins32 )
  rot 1 bsl 1 logior rot
  fstored
;

: fstmx ( count Rn CRs -- ins32 )
  fstorex coproc-u
;

: fldmx ( count Rn CRs -- ins32 )
  fstmx .ldc
;

( Auto incrementing: )
: fstmx+ fstmx coproc-w ;
: fstmx- fstorex coproc-p coproc-w ;

: fldmx+ fstmx+ .ldc ;
: fldmx- fstmx- .ldc ;

( Data Processing: )

( 32 & 64 bit only differs in coprocessor [and data size], and last bits fiddling; reuse with a32 and a64? )
( todo use f* or v*.type mneumonics? )
( ideally functions get a set of integer and a set of floating point args in registers w/o touching the stack. )

: vfp-cdps
  ( Register low bit gets placed into the op code fields. )
  ( Opc2 CRm CRn CRd Op1 )
  ( Do bit gymnastics to place LSB in Op2 field. )
  3 overn 1 logand 2 bsl 5 overn 1 logand logior 6 overn logior 5 set-overn ( Opc2 ||= N s M 0 )
  2 overn 1 logand 2 bsl 2 overn logior 1 set-overn ( Op1 ||= P D Q R )
  3 overn 1 bsr 3 set-overn ( shift CRn )
  4 overn 1 bsr 4 set-overn ( shift CRm )
  2 overn 1 bsr 2 set-overn ( shift CRd )
  10 cdp
;

: vfp-cdp-op ( fm fn fd opc2 opc -- ins )
  2 overn 6 overn 6 overn 6 overn 5 overn vfp-cdps
  5 set-overn 4 dropn
;

: vfp64-cdp-raw-op ( fm fn fd op2 op1 -- ins )
  2 overn 6 overn 6 overn 6 overn 5 overn 11 cdp
  5 set-overn 4 dropn
;

: vfp64-cdp-op1 ( fm fn fd op2 op1 -- ins )
  2 overn 6 overn 6 overn 6 overn 1 bsr 5 overn 11 cdp
  4 overn 1 logand IF 23 bit-set THEN
  5 set-overn 4 dropn
;

: vfp64-cdp-op2 ( fm fn fd op2 op1 -- ins )
  2 overn 6 overn 1 bsr 6 overn 6 overn 5 overn 11 cdp
  ( 6 overn 1 logand IF 23 bit-set THEN )
  5 set-overn 4 dropn
;

: fadds ( fm fn fd )
  0 3 vfp-cdp-op
;

: fsubs ( fm fn fd )
  2 3 vfp-cdp-op
;

: fmuls ( fm fn fd )
  0 2 vfp-cdp-op
;

: fdivs ( fm fn fd )
  0 8 vfp-cdp-op
;

: fnegs ( fm fd )
  2 swap 2 0xB vfp-cdp-op
;

: fsqrts
  3 swap 2 0xB vfp-cdp-op
;

: fcpys
  0 swap 2 0xB vfp-cdp-op
;

: fabss
  1 swap 2 0xB vfp-cdp-op
;

: fcmps
  8 swap 2 0xB vfp-cdp-op
;

: fcmpzs
  0 10 roll 2 0xB vfp-cdp-op
;

( Float32 conversions: )

: fuitos ( fm fd )
  ( uint32 to float32 )
  16 swap 2 0xB vfp-cdp-op
;

: fsitos ( fm fd )
  ( int32 to float32 )
  17 swap 2 0xB vfp-cdp-op
;

: ftouis ( fm fd )
  ( float32 to uint32 )
  0x18 swap 2 0xB vfp-cdp-op
;

: ftouizs ( fm fd )
  ( float32 to uint32, round to zero )
  0x19 swap 2 0xB vfp-cdp-op
;

: ftosis ( fm fd )
  ( float32 to int32 )
  0x1A swap 2 0xB vfp-cdp-op
;

: ftosizs ( fm fd )
  ( float32 to int32, round to zero )
  0x1B swap 2 0xB vfp-cdp-op
;

: fcvtds ( fm fd )
  ( float32 to float64 )
  1 bsl 0xF swap 2 0xB vfp-cdp-op
;

( Double precision: )

: fmdlrd ( Rxf CRm -- ins32 )
  ( ARM to VFP float64[0:31] )
  0 0 3 overn 5 overn 0 11 mcr
  rot 2 dropn
;

: fmrdld
  ( VFP float64[0:31] to ARM )
  0 0 4 overn 4 overn 0 11 mrc
  rot 2 dropn
;

: fmdhrd ( Rxf CRm -- ins32 )
  ( ARM to float64[32:63] )
  0 0 3 overn 5 overn 1 11 mcr
  rot 2 dropn
;

: fmrdhd
  ( VFP float64[32:63] to ARM )
  0 0 4 overn 4 overn 1 11 mrc
  rot 2 dropn
;

: faddd ( fm fn fd )
  0 3 vfp64-cdp-raw-op
;

: fsubd ( fm fn fd )
  2 3 vfp64-cdp-raw-op
;

: fmuld ( fm fn fd )
  0 2 vfp64-cdp-raw-op
;

: fdivd ( fm fn fd )
  0 8 vfp64-cdp-raw-op
;

: fnegd
  1 swap 2 0xB vfp64-cdp-raw-op
;

: fsqrtd
  1 swap 6 0xB vfp64-cdp-raw-op
;

: fcpyd
  0 swap 2 0xB vfp64-cdp-raw-op
;

: fabsd
  0 swap 6 0xB vfp64-cdp-raw-op
;

: fcmpd
  4 swap 6 0xB vfp64-cdp-raw-op
;

: fcmpzd
  0 5 roll 6 0xB vfp64-cdp-raw-op
;

( Float64 conversions: )

: ftouid ( fm fd )
  ( float64 to uint32 )
  0xC swap 2 0xB vfp64-cdp-op1
;

: ftouizd ( fm fd )
  ( float64 to uint32, round to zero )
  0xC swap 6 0xB vfp64-cdp-op1
;

: ftosid ( fm fd )
  ( float64 to int32 )
  0xD swap 2 0xB vfp64-cdp-op1
;

: ftosizd ( fm fd )
  ( float64 to int32, round to zero )
  0xD swap 6 0xB vfp64-cdp-op1
;

: fuitod
  ( uint32 to float64 )
  8 swap 2 0xB vfp64-cdp-op2
;

: fsitod ( fm fd )
  ( int32 to float64 )
  8 swap 6 0xB vfp64-cdp-op2
;

: fcvtsd ( fm fd )
  ( float64 to float32 )
  7 swap 6 0xB vfp64-cdp-op1
;
