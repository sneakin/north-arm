0 defvar> return-stack

defop proper-enter-r1
  ( Save eip on the return-stack and interpret the list of words pointed by r1. )
  ( push eip onto the return-stack )
  op-return-stack r2 emit-get-word-data
  cell-size r2 add# ,uint16
  0 r2 eip str-offset ,uint16
  op-return-stack r2 r3 emit-set-word-data
  ( load r1 into eip )
  0 r1 eip mov-lsl ,uint16
  emit-next
endop

defop proper-exit
  ( Return from a list of words. Return address comes from the return-stack. )
  ( pop eip )
  op-return-stack r2 emit-get-word-data
  0 r2 eip ldr-offset ,uint16
  cell-size r2 sub# ,uint16
  op-return-stack r2 r3 emit-set-word-data
  emit-next
endop

defop do-proper
  ( Enter the definition from word's data field storing the return on the return-stack. )
  ( load r1's data+cs into r1 )
  0 dict-entry-data r1 r1 ldr-offset ,uint16
  cs r1 r1 add ,uint16
  op-proper-enter-r1 emit-op-call
  emit-next
endop

: does-proper/1
  ( todo use data field )
  op-do-proper dict-entry-size + over dict-entry-code uint32!
  4 align-data
  dhere swap dict-entry-data uint32!  
;

: does-proper
  out-dict does-proper/1
;

: defproper
  next-token create does-proper
  defcol-read
  op-proper-exit ,op
;

' endcol ' endproper out-immediate/2

: lookup-or-create
  cross-lookup LOOKUP-WORD equals UNLESS
    create out-dict
  THEN
;

: redefproper
  next-token lookup-or-create does-proper/1
  defcol-read
  op-proper-exit ,op
;

: out-loop
  ' pointer
  out-dict dict-entry-data uint32@
  ' jump
; out-immediate-as loop

def proper-init
  arg0 stack-allot return-stack poke
  exit-frame
end

def does-proper
  pointer do-proper dict-entry-code peek arg0 dict-entry-code poke
end

def does-proper>
  arg0 does-proper
  compiling-read
  literal proper-exit swap
  int32 1 +
  here cell-size + swap reverse
  int32 2 dropn
  here cs - arg0 dict-entry-data poke
  exit-frame
end

def defproper
  create> does-proper> exit-frame
end

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
