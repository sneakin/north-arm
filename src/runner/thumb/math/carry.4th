: emit-sign-extender ( src-reg dest-reg -- )
  ( sign extend what last set the flags into dest-reg )
  6 bvc ,ins ( no overflow so skip to using actual sign bit )
  0 over mov# ,ins
  4 bcc ,ins ( sign is in carry bit. skip when positive )
  dup dup mvn ,ins ( -1 for hi )
  0 branch ,ins
  31 shift mov-asr ,ins ( actual sign extension )
;

defop int-adc
  0 r1 bit-set popr ,ins
  r1 r0 adc ,ins
  emit-next
endop
  
defop int-sbc
  0 r1 bit-set popr ,ins
  r0 r1 sbc ,ins
  r1 r0 movrr ,ins
  emit-next
endop
  
defop uint-add3 ( carry a b -- lo hi )
  0 r1 bit-set r2 bit-set popr ,ins
  0 r4 bit-set pushr ,ins
  ( use R3 as the hi bytes, R4 as a zero for adc )
  0 r3 mov# ,ins
  0 r4 mov# ,ins
  r1 r0 r0 add ,ins
  r4 r3 adc ,ins
  r2 r0 r0 add ,ins
  r4 r3 adc ,ins
  0 r4 bit-set popr ,ins
  0 r0 bit-set pushr ,ins
  r3 r0 movrr ,ins
  emit-next
endop

defop uint-addc ( a b -- lo hi )
  0 r1 bit-set popr ,ins
  r1 r0 r0 add ,ins
  0 r0 bit-set pushr ,ins
  0 r0 mov# ,ins
  r0 r0 adc ,ins
  emit-next
endop

defop int-add3 ( carry a b -- lo hi )
  ( registers: b, a, c, ahi, bhi )
  0 r1 bit-set r2 bit-set popr ,ins
  0 r4 bit-set pushr ,ins
  ( sign extension )
  31 r0 r4 mov-asr ,ins
  31 r1 r3 mov-asr ,ins
  ( a + b )
  r1 r0 r0 add ,ins
  r4 r3 adc ,ins
  ( c + [a+b] )
  31 r2 r4 mov-asr ,ins ( r4 now carry_hi )
  r2 r0 r0 add ,ins
  r4 r3 adc ,ins
  ( store result )
  0 r4 bit-set popr ,ins
  0 r0 bit-set pushr ,ins
  r3 r0 movrr ,ins
  emit-next
endop

defop int-addc ( a b -- lo hi )
  0 r1 bit-set popr ,ins 
  ( do the add )
  r1 r0 r0 add ,ins
  0 r0 bit-set pushr ,ins
  r0 r0 emit-sign-extender
  emit-next
endop

defop int-addc ( a b -- lo hi )
  0 r2 bit-set popr ,ins
  ( extend the signs )
  31 r0 r1 mov-asr ,ins
  31 r2 r3 mov-asr ,ins
  ( do the add )
  r2 r0 r0 add ,ins
  r3 r1 adc ,ins
  ( store the result )
  0 r0 bit-set pushr ,ins
  r1 r0 movrr ,ins
  emit-next
endop
