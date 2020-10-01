defcol test-logior
  nl hello
  int32 0x01 int32 0x80 logior
  int32 0x81 equals? IF what ELSE crap THEN

  int32 0x7F int32 0x80 logior
  int32 0xFF equals? IF what ELSE crap THEN
endcol
