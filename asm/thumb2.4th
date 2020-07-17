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