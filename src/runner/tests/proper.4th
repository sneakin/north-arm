defproper test-proper-a
  what
  return-stack peek write-hex-uint nl
  ok
endproper

defproper test-proper-b
  boo test-proper-a
endproper

defproper test-proper-c
  hello test-proper-b ok
endproper

def test-proper
  int32 128 proper-init
  return-stack peek write-hex-uint nl
  test-proper-c
  return-stack peek write-hex-uint nl
end
