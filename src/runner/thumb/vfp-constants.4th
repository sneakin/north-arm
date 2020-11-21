0xFF 23 bsl defconst> float32-infinity
0x1FF 23 bsl defconst> float32-negative-infinity
0xFF 23 bsl 1 logior defconst> float32-nan
0x1FF 23 bsl 1 logior 22 bit-set defconst> float32-quiet-nan
0x80000000 defconst> float32-negative-zero

defcol float64-infinity 0 0x7FF00000 rot endcol
defcol float64-negative-infinity 0 0xFFF00000 rot endcol
defcol float64-nan 1 0x7FF00000 rot endcol
defcol float64-quiet-nan 1 0xFFF80000 rot endcol ( todo verify )
defcol float64-negative-zero 0 0x80000000 rot endcol
