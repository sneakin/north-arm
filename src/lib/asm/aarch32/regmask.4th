: regmask->reglist/2 ( mask count -- ...registers count )
  over r0 logand IF r0 shift 1 + THEN 
  over r1 logand IF r1 shift 1 + THEN 
  over r2 logand IF r2 shift 1 + THEN 
  over r3 logand IF r3 shift 1 + THEN 
  over r4 logand IF r4 shift 1 + THEN 
  over r5 logand IF r5 shift 1 + THEN 
  over r6 logand IF r6 shift 1 + THEN 
  over r7 logand IF r7 shift 1 + THEN 
  over r8 logand IF r8 shift 1 + THEN 
  over r9 logand IF r9 shift 1 + THEN 
  over r10 logand IF r10 shift 1 + THEN 
  over r11 logand IF r11 shift 1 + THEN 
  over r12 logand IF r12 shift 1 + THEN 
  over r13 logand IF r13 shift 1 + THEN 
  over r14 logand IF r14 shift 1 + THEN 
  over r15 logand IF r15 shift 1 + THEN
  swap drop
;

: regmask->reglist 0 regmask->reglist/2 ;
