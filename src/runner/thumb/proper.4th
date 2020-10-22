0 defvar> return-stack

defop proper-enter-r1
  ( Save eip on the return-stack and interpret the list of words pointed by r1. )
  ( push eip onto the return-stack )
  out' return-stack r2 emit-get-word-data
  cell-size r2 add# ,uint16
  0 r2 eip str-offset ,uint16
  out' return-stack r2 r3 emit-set-word-data
  ( load r1 into eip )
  0 r1 eip mov-lsl ,uint16
  emit-next
endop

defop proper-exit
  ( Return from a list of words. Return address comes from the return-stack. )
  ( pop eip )
  out' return-stack r2 emit-get-word-data
  0 r2 eip ldr-offset ,uint16
  cell-size r2 sub# ,uint16
  out' return-stack r2 r3 emit-set-word-data
  emit-next
endop

defop do-proper
  ( Enter the definition from word's data field storing the return on the return-stack. )
  ( load r1's data+cs into r1 )
  0 dict-entry-data r1 r1 ldr-offset ,uint16
  cs-reg r1 r1 add ,uint16
  out' proper-enter-r1 emit-op-call
  emit-next
endop
