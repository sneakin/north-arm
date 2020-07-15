defcol test-write-hex-int
  int32 0x12345 write-hex-int nl
  int32 0x0 write-hex-int nl
  int32 -0x12345 write-hex-int nl
  int32 -0x1 write-hex-int nl
  int32 -0x12 write-hex-int nl
  int32 -0x1FEEDDCC write-hex-int nl
  int32 0xFFEEDDCC write-hex-int nl
endcol
