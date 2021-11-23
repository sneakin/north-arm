load-core
load-thumb-asm
s[ src/lib/asm/thumb/disasm.4th
   src/lib/assert.4th
] load-list

( Thumb v1's ops: )

def test-thumb-disasm-mov-lsl
  9 r3 r2 mov-lsl disasm-op1
  5 assert-equals
  literal int32 assert-equals
  9 assert-equals
  literal r3 assert-equals
  literal r2 assert-equals
  literal mov-lsl assert-equals
end

def test-thumb-disasm-mov-lsr
  20 r0 r7 mov-lsr disasm-op1
  5 assert-equals
  literal int32 assert-equals
  20 assert-equals
  literal r0 assert-equals
  literal r7 assert-equals
  literal mov-lsr assert-equals
end

def test-thumb-disasm-mov-asr
  9 r3 r2 mov-asr disasm-op1
  5 assert-equals
  literal int32 assert-equals
  9 assert-equals
  literal r3 assert-equals
  literal r2 assert-equals
  literal mov-asr assert-equals
end

def test-thumb-disasm-add
  r4 r3 r2 add disasm-op1
  4 assert-equals
  literal r4 assert-equals
  literal r3 assert-equals
  literal r2 assert-equals
  literal add assert-equals
end

def test-thumb-disasm-add-immed
  255 r3 r2 add .immed disasm-op1
  5 assert-equals
  literal int32 assert-equals
  literal 7 assert-equals
  literal r3 assert-equals
  literal r2 assert-equals
  literal add assert-equals
end

def test-thumb-disasm-sub
  r4 r3 r2 sub disasm-op1
  4 assert-equals
  literal r4 assert-equals
  literal r3 assert-equals
  literal r2 assert-equals
  literal sub assert-equals
end

def test-thumb-disasm-sub-immed
  255 r3 r2 sub .immed disasm-op1
  5 assert-equals
  literal int32 assert-equals
  literal 7 assert-equals
  literal r3 assert-equals
  literal r2 assert-equals
  literal sub assert-equals
end

def test-thumb-disasm-mcas#
  0xFFF r2 arg0 exec-cs disasm-op1
  3 assert-equals
  literal int32 assert-equals
  literal 0xFF assert-equals
  literal r2 assert-equals
  arg0 assert-equals
end

def test-thumb-disasm-mov#
  literal mov# test-thumb-disasm-mcas#
end
  
def test-thumb-disasm-cmp#
  literal cmp# test-thumb-disasm-mcas#
end

def test-thumb-disasm-add#
  literal add# test-thumb-disasm-mcas#
end

def test-thumb-disasm-sub#
  literal sub# test-thumb-disasm-mcas#
end  

def test-thumb-disasm-alu-op
  r2 r1 arg0 exec-cs disasm-op1
  3 assert-equals
  literal r2 assert-equals
  literal r1 assert-equals
  arg0 assert-equals
end

def test-thumb-disasm-alu-ops
  literal and test-thumb-disasm-alu-op
  literal eor test-thumb-disasm-alu-op
  literal lsl test-thumb-disasm-alu-op
  literal lsr test-thumb-disasm-alu-op
  literal asr test-thumb-disasm-alu-op
  literal adc test-thumb-disasm-alu-op
  literal sbc test-thumb-disasm-alu-op
  literal ror test-thumb-disasm-alu-op
  literal tst test-thumb-disasm-alu-op
  literal neg test-thumb-disasm-alu-op
  literal cmp test-thumb-disasm-alu-op
  literal cmn test-thumb-disasm-alu-op
  literal orr test-thumb-disasm-alu-op
  literal mul test-thumb-disasm-alu-op
  literal bic test-thumb-disasm-alu-op
  literal mvn test-thumb-disasm-alu-op
end

def test-thumb-disasm-hilo
  r0 r10 arg0 exec-cs disasm-op1
  3 assert-equals
  literal r0 assert-equals
  literal sl assert-equals
  arg0 assert-equals

  r10 r7 arg0 exec-cs disasm-op1
  3 assert-equals
  literal sl assert-equals
  literal r7 assert-equals
  arg0 assert-equals

  r10 r9 arg0 exec-cs disasm-op1
  3 assert-equals
  literal sl assert-equals
  literal r9 assert-equals
  arg0 assert-equals
end

def test-thumb-disasm-addrr
  r3 r2 addrr disasm-op1
  4 assert-equals
  literal r3 assert-equals
  literal r2 assert-equals
  literal r2 assert-equals
  literal add assert-equals

  literal addrr test-thumb-disasm-hilo
end

def test-thumb-disasm-cmprr
  r3 r2 cmprr disasm-op1
  3 assert-equals
  literal r3 assert-equals
  literal r2 assert-equals
  literal cmp assert-equals

  literal cmprr test-thumb-disasm-hilo
end

def test-thumb-disasm-movrr
  r3 r2 movrr disasm-op1
  5 assert-equals
  literal int32 assert-equals
  0 assert-equals
  literal r3 assert-equals
  literal r2 assert-equals
  literal mov-lsl assert-equals

  0 literal movrr test-thumb-disasm-hilo
end

def test-thumb-disasm-bx
  r2 bx disasm-op1
  2 assert-equals
  literal r2 assert-equals
  literal bx assert-equals

  r9 bx disasm-op1
  2 assert-equals
  literal r9 assert-equals
  literal bx assert-equals
end

def test-thumb-disasm-ldr-pc
  0xFFFF r3 ldr-pc disasm-op1
  4 assert-equals
  literal int32 assert-equals
  0x3FC assert-equals
  literal r3 assert-equals
  literal ldr-pc assert-equals
end

def test-thumb-disasm-ldr
  r1 r2 r3 ldr disasm-op1
  4 assert-equals
  literal r1 assert-equals
  literal r2 assert-equals
  literal r3 assert-equals
  literal ldr assert-equals

  r1 r2 r3 ldsb disasm-op1
  5 assert-equals
  literal r1 assert-equals
  literal r2 assert-equals
  literal r3 assert-equals
  literal ldr assert-equals
  literal .byte assert-equals

  r1 r2 r3 ldsh disasm-op1
  6 assert-equals
  literal r1 assert-equals
  literal r2 assert-equals
  literal r3 assert-equals
  literal ldr assert-equals
  literal .byte assert-equals
  literal .half assert-equals

  r1 r2 r3 ldr-half disasm-op1
  5 assert-equals
  literal r1 assert-equals
  literal r2 assert-equals
  literal r3 assert-equals
  literal ldr assert-equals
  literal .half assert-equals
end

def test-thumb-disasm-ldr-offset
  0xFFF r4 r3 ldr-offset disasm-op1
  5 assert-equals
  literal int32 assert-equals
  0x7C assert-equals
  literal r4 assert-equals
  literal r3 assert-equals
  literal ldr-offset assert-equals

  0xFFF r4 r3 ldr-offset .offset-byte disasm-op1
  6 assert-equals
  literal int32 assert-equals
  0x7C assert-equals
  literal r4 assert-equals
  literal r3 assert-equals
  literal ldr-offset assert-equals
  literal .offset-byte assert-equals
end

def test-thumb-disasm-ldrh
  0xFF r2 r1 ldrh disasm-op1
  5 assert-equals
  literal int32 assert-equals
  0x7C assert-equals
  literal r2 assert-equals
  literal r1 assert-equals
  literal ldrh assert-equals
end

def test-thumb-disasm-ldr-sp
  0xFFF r1 ldr-sp disasm-op1
  4 assert-equals
  literal int32 assert-equals
  0x3FC assert-equals
  literal r1 assert-equals
  literal ldr-sp assert-equals
end

def test-thumb-disasm-str
  r1 r2 r3 str disasm-op1
  4 assert-equals
  literal r1 assert-equals
  literal r2 assert-equals
  literal r3 assert-equals
  literal str assert-equals

  r1 r2 r3 str .byte disasm-op1
  5 assert-equals
  literal r1 assert-equals
  literal r2 assert-equals
  literal r3 assert-equals
  literal str assert-equals
  literal .byte assert-equals

  r1 r2 r3 str .byte .half disasm-op1
  6 assert-equals
  literal r1 assert-equals
  literal r2 assert-equals
  literal r3 assert-equals
  literal str assert-equals
  literal .byte assert-equals
  literal .half assert-equals

  r1 r2 r3 str-half disasm-op1
  5 assert-equals
  literal r1 assert-equals
  literal r2 assert-equals
  literal r3 assert-equals
  literal str assert-equals
  literal .half assert-equals
end

def test-thumb-disasm-str-offset
  0xFFF r4 r3 str-offset disasm-op1
  5 assert-equals
  literal int32 assert-equals
  0x7C assert-equals
  literal r4 assert-equals
  literal r3 assert-equals
  literal str-offset assert-equals

  0xFFF r4 r3 str-offset .offset-byte disasm-op1
  6 assert-equals
  literal int32 assert-equals
  0x7C assert-equals
  literal r4 assert-equals
  literal r3 assert-equals
  literal str-offset assert-equals
  literal .offset-byte assert-equals
end

def test-thumb-disasm-strh
  0xFF r2 r1 strh disasm-op1
  5 assert-equals
  literal int32 assert-equals
  0x7C assert-equals
  literal r2 assert-equals
  literal r1 assert-equals
  literal strh assert-equals
end

def test-thumb-disasm-str-sp
  0xFFF r1 str-sp disasm-op1
  4 assert-equals
  literal int32 assert-equals
  0x3FC assert-equals
  literal r1 assert-equals
  literal str-sp assert-equals
end

def test-thumb-disasm-addr-pc
  0xFFF r3 addr-pc disasm-op1
  3 assert-equals
  literal int32 assert-equals
  0x3FC assert-equals
  literal r3 assert-equals
  literal addr-pc assert-equals
end

def test-thumb-disasm-addr-sp
  0xFFF r3 addr-sp disasm-op1
  3 assert-equals
  literal int32 assert-equals
  0x3FC assert-equals
  literal r3 assert-equals
  literal addr-sp assert-equals
end

def test-thumb-disasm-inc-sp
  0xFFF inc-sp disasm-op1
  3 assert-equals
  literal int32 assert-equals
  0x1FC assert-equals
  literal inc-sp assert-equals
end

def test-thumb-disasm-dec-sp
  0xFFF dec-sp disasm-op1
  3 assert-equals
  literal int32 assert-equals
  0x1FC assert-equals
  literal dec-sp assert-equals
end

def test-thumb-disasm-ldmia
  r4 0xFF ldmia disasm-op1
  4 assert-equals
  literal r4 assert-equals  
  literal int32 assert-equals
  0xFF assert-equals
  literal ldmia assert-equals  
end

def test-thumb-disasm-stmia
  r7 0xFF stmia disasm-op1
  4 assert-equals
  literal r7 assert-equals  
  literal int32 assert-equals
  0xFF assert-equals
  literal stmia assert-equals  
end

def test-thumb-disasm-pushr
  0xFF pushr disasm-op1
  3 assert-equals
  literal int32 assert-equals
  0xFF assert-equals
  literal pushr assert-equals
end

def test-thumb-disasm-popr
  0xFF popr disasm-op1
  3 assert-equals
  literal int32 assert-equals
  0xFF assert-equals
  literal popr assert-equals
end

def test-thumb-disasm-swi
  0xFFF swi disasm-op1
  3 assert-equals
  literal int32 assert-equals
  0xFF assert-equals
  literal swi assert-equals
end

def test-thumb-disasm-branch-op
  0xFF arg0 exec-cs disasm-op1
  3 assert-equals
  literal int32 assert-equals
  0xFE assert-equals
  arg0 assert-equals

  -128 arg0 exec-cs disasm-op1
  3 assert-equals
  literal int32 assert-equals
  -128 assert-equals
  arg0 assert-equals
end

def test-thumb-disasm-branchers
  literal beq test-thumb-disasm-branch-op
  literal bne test-thumb-disasm-branch-op
  literal bcs test-thumb-disasm-branch-op
  literal bcc test-thumb-disasm-branch-op
  literal bmi test-thumb-disasm-branch-op
  literal bpl test-thumb-disasm-branch-op
  literal bvs test-thumb-disasm-branch-op
  literal bvc test-thumb-disasm-branch-op
  literal bhi test-thumb-disasm-branch-op
  literal bls test-thumb-disasm-branch-op
  literal bge test-thumb-disasm-branch-op
  literal blt test-thumb-disasm-branch-op
  literal bgt test-thumb-disasm-branch-op
  literal ble test-thumb-disasm-branch-op
end

def test-thumb-disasm-branch
  0xFFFF branch disasm-op1
  3 assert-equals
  literal int32 assert-equals
  0xFFE assert-equals
  literal branch assert-equals
end

( Thumb v1's 32 bit op: )

def test-thumb-disasm-branch-link
  0x1234 branch-link disasm-op2
  3 assert-equals
  literal int32 assert-equals
  0x1234 assert-equals
  literal branch-link assert-equals
end

def test-thumb-disasm-v1
  test-thumb-disasm-mov-lsl
  test-thumb-disasm-mov-lsr
  test-thumb-disasm-mov-asr
  test-thumb-disasm-add
  test-thumb-disasm-add-immed
  test-thumb-disasm-sub
  test-thumb-disasm-sub-immed
  test-thumb-disasm-mov#
  test-thumb-disasm-add#
  test-thumb-disasm-sub#
  test-thumb-disasm-cmp#
  test-thumb-disasm-alu-ops
  test-thumb-disasm-addrr
  test-thumb-disasm-cmprr
  test-thumb-disasm-movrr
  test-thumb-disasm-bx
  test-thumb-disasm-ldr-pc
  test-thumb-disasm-ldr
  test-thumb-disasm-ldr-offset
  test-thumb-disasm-ldrh
  test-thumb-disasm-ldr-sp
  test-thumb-disasm-str
  test-thumb-disasm-str-offset
  test-thumb-disasm-strh
  test-thumb-disasm-str-sp
  test-thumb-disasm-addr-pc
  test-thumb-disasm-addr-sp
  test-thumb-disasm-inc-sp
  test-thumb-disasm-dec-sp
  test-thumb-disasm-ldmia
  test-thumb-disasm-stmia
  test-thumb-disasm-pushr
  test-thumb-disasm-popr
  test-thumb-disasm-swi
  test-thumb-disasm-branchers
  test-thumb-disasm-branch
  test-thumb-disasm-branch-link
end

( Thumb v2's 16 bit ops: )

def test-thumb-disasm-setend
  lilend disasm-op1
  1 assert-equals
  literal lilend assert-equals

  bigend disasm-op1
  1 assert-equals
  literal bigend assert-equals
end

def test-thumb-disasm-v2
  test-thumb-disasm-setend
end

( Thumb v2's 32 bit ops: )

def test-thumb-disasm-sdiv
  r9 r6 r0 sdiv disasm-op2
  4 assert-equals
  literal r9 assert-equals
  literal r6 assert-equals
  literal r0 assert-equals
  literal sdiv assert-equals
end

def test-thumb-disasm-udiv
  r2 r6 r10 udiv disasm-op2
  4 assert-equals
  literal r2 assert-equals
  literal r6 assert-equals
  literal sl assert-equals
  literal udiv assert-equals
end

def test-thumb-disasm-mrs
  r10 mrs disasm-op2
  2 assert-equals
  literal sl assert-equals
  literal mrs assert-equals
end

def test-thumb-disasm-msr
  r10 4 msr disasm-op2
  4 assert-equals
  literal sl assert-equals
  literal int32 assert-equals
  4 assert-equals
  literal msr assert-equals
end

def test-thumb-disasm-mcrr
  r4 3 2 1 r10 mcrr disasm-op2
  9 assert-equals
  literal r4 assert-equals
  literal int32 assert-equals
  literal 3 assert-equals
  literal int32 assert-equals
  literal 2 assert-equals
  literal int32 assert-equals
  literal 1 assert-equals
  literal sl assert-equals
  literal mcrr assert-equals
end

def test-thumb-disasm-mrrc
  r4 3 2 1 r10 mrrc disasm-op2
  9 assert-equals
  literal r4 assert-equals
  literal int32 assert-equals
  literal 3 assert-equals
  literal int32 assert-equals
  literal 2 assert-equals
  literal int32 assert-equals
  literal 1 assert-equals
  literal sl assert-equals
  literal mrrc assert-equals
end

def test-thumb-disasm-stc
  r10 123 4 5 stc disasm-op2
  8 assert-equals
  literal sl assert-equals
  literal int32 assert-equals
  literal 123 assert-equals
  literal int32 assert-equals
  literal 4 assert-equals
  literal int32 assert-equals
  literal 5 assert-equals
  literal stc assert-equals
end

def test-thumb-disasm-ldc
  r10 123 4 5 ldc disasm-op2
  8 assert-equals
  literal sl assert-equals
  literal int32 assert-equals
  literal 123 assert-equals
  literal int32 assert-equals
  literal 4 assert-equals
  literal int32 assert-equals
  literal 5 assert-equals
  literal ldc assert-equals
end

def test-thumb-disasm-cdp
  3 12 4 5 6 7 cdp disasm-op2
  13 assert-equals
  literal int32 assert-equals
  literal 3 assert-equals
  literal int32 assert-equals
  literal 12 assert-equals
  literal int32 assert-equals
  literal 4 assert-equals
  literal int32 assert-equals
  literal 5 assert-equals
  literal int32 assert-equals
  literal 6 assert-equals
  literal int32 assert-equals
  literal 7 assert-equals
  literal cdp assert-equals
end

def test-thumb-disasm-mcr
  3 7 4 5 6 r4 mcr disasm-op2
  12 assert-equals
  literal int32 assert-equals
  literal 3 assert-equals
  literal int32 assert-equals
  literal 7 assert-equals
  literal int32 assert-equals
  literal 4 assert-equals
  literal int32 assert-equals
  literal 5 assert-equals
  literal int32 assert-equals
  literal 6 assert-equals
  literal r4 assert-equals
  literal mcr assert-equals
end

def test-thumb-disasm-mrc
  3 7 4 5 6 r4 mrc disasm-op2
  12 assert-equals
  literal int32 assert-equals
  literal 3 assert-equals
  literal int32 assert-equals
  literal 7 assert-equals
  literal int32 assert-equals
  literal 4 assert-equals
  literal int32 assert-equals
  literal 5 assert-equals
  literal int32 assert-equals
  literal 6 assert-equals
  literal r4 assert-equals
  literal mrc assert-equals
end

def test-thumb-disasm-op2
  test-thumb-disasm-sdiv
  test-thumb-disasm-udiv
  test-thumb-disasm-mrs
  test-thumb-disasm-msr
  test-thumb-disasm-mcrr
  test-thumb-disasm-mrrc
  test-thumb-disasm-stc
  test-thumb-disasm-ldc
  test-thumb-disasm-cdp
  test-thumb-disasm-mcr
  test-thumb-disasm-mrc
end

def test-thumb-disasm
  test-thumb-disasm-v1
  test-thumb-disasm-v2
  test-thumb-disasm-op2
end
