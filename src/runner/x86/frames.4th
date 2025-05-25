cell-size 2 * const> frame-byte-size
frame-byte-size defconst> frame-byte-size

defop current-frame
  ebx pop
  eax push
  fp-reg eax modrr movr
  ebx push
  ret
endop

defop set-current-frame
endop

defop begin-frame
  ebx pop
  eax push
  fp-reg eax modrr movr
  ebx push
  ret  
endop

defop end-frame
  ebx pop
  eax fp-reg modrr movr
  eax pop
  ebx push
  ret
endop

defop drop-locals
endop

defop return0
  out' end-frame emit-op-call
  out' exit emit-op-jump
endop

defop return0-n
endop

defop return1
endop

defop return1-1
endop

defop return1-n
endop

defop return2
endop

defop return2-n
endop

defop return2
endop

defop return3
endop

defop return4
endop
