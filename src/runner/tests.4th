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

def test-repeat-0
  arg0 4 int>= IF return0 THEN
  arg0 write-hex-int nl
  arg0 1 + set-arg0
  repeat-frame
end

defcol test-repeat
  ( reuse args and return address; exit by return )
  nl hello
  begin-frame
    nl boo
    arg0 int32 1 int<= IF crap return0 THEN
    arg0 int32 1 - set-arg0
    repeat-frame
  end-frame
endcol

def test-repeat-1
  ( exit by not repeating )
  hello 0 20
  begin-frame
    what arg0 write-hex-int
    arg0 4 int<=
    IF arg0 1 + set-arg0 repeat-frame THEN
  end-frame
end        
