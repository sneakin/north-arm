defcol test-lognot
  nl hello
  int32 1 lognot
  int32 0xFFFFFFFE equals? IF what ELSE crap THEN

  int32 0 lognot
  int32 0xFFFFFFFF equals? IF what ELSE crap THEN

  int32 0xFFFF lognot
  int32 0xFFFF0000 equals? IF what ELSE crap THEN
endcol
