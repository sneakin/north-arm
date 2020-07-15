defcol test-logand
  nl hello
  int32 0xFF int32 0x80 logand
  int32 0x80 equals? IF what ELSE crap THEN

  int32 0x7F int32 0x80 logand
  int32 0x0 equals? IF what ELSE crap THEN
endcol
