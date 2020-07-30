defcol test-if-jump
  nl hello
  int32 0 op-size if-jump what
  int32 1 op-size if-jump crap
  nl hello
  int32 0 op-size unless-jump crap
  int32 1 op-size unless-jump what
  what
endcol

defcol test-if
  nl hello
  int32 0 IF crap ELSE what THEN
  int32 1 IF what ELSE crap THEN
  nl hello
  int32 0 UNLESS what ELSE crap THEN
  int32 1 UNLESS crap ELSE what THEN
  what
endcol

defcol test-repeat-0
  begin-frame hello repeat-frame
endcol

defcol test-repeat
  nl hello
  begin-frame
  nl boo
  arg0 int32 0 int<= IF crap return THEN
  arg0 int32 1 - set-arg0
  repeat-frame
endcol

defcol run-tests
  test-if-jump
  test-if 
  int32 4 test-repeat drop
endcol
