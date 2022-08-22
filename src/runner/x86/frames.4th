cell-size 2 * const> frame-byte-size
frame-byte-size defconst> frame-byte-size

defop current-frame
  ebx pop
  eax push
  fp-reg eax modrr movr
  ebx push
  ret
endop

defop begin-frame
endop

defop end-frame
endop

defop return
endop

defop return0-n
endop

defop return1
endop

defop return1-n
endop

defop return2
endop

defop drop-locals
endop
