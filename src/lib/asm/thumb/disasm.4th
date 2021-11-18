0
' r7
' r6
' r5
' r4
' r3
' r2
' r1
' r0
here const> DISASM-LOW-REGS

: disasm-low-register
  7 logand DISASM-LOW-REGS swap seq-peek cs -
;

0
' pc
' lr
' sp
' ip
' fp
' sl
' r9
' r8
here const> DISASM-HI-REGS

: disasm-hi-register
  7 logand DISASM-HI-REGS swap seq-peek cs -
;

: disasm-register
  0xF logand dup 8 int< IF disasm-low-register ELSE disasm-hi-register THEN
;

: disasm-mov ( op -- shift rs rd instruction count )
  dup 11 bsr 3 logand CASE
    0 WHEN literal mov-lsl ;;
    1 WHEN literal mov-lsr ;;
    2 WHEN literal mov-asr ;;
  ESAC swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  6 bsr 31 logand literal int32
  int32 5
;

: disasm-addsub ( op -- rn rs rd instruction count )
  dup 10 bit-set? IF literal .immed swap THEN
  dup 9 bit-set? IF literal sub ELSE literal add THEN swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  dup 6 bsr disasm-low-register swap
  drop 4
;

: disasm-mcas# ( op -- immed rd instruction count )
  dup 11 bsr 3 logand CASE
    0 WHEN literal mov# ;;
    1 WHEN literal cmp# ;;
    2 WHEN literal add# ;;
    3 WHEN literal sub# ;;
  ESAC swap
  dup 8 bsr disasm-low-register swap
  dup 0xFF logand swap literal int32 swap
  drop 3
;


: disasm-alu-op ( op -- rs rd instruction count )
  dup 6 bsr 0xF logand CASE
    0 WHEN literal and ;;
    1 WHEN literal eor ;;
    2 WHEN literal lsl ;;
    3 WHEN literal lsr ;;
    4 WHEN literal asr ;;
    5 WHEN literal adc ;;
    6 WHEN literal sbc ;;
    7 WHEN literal ror ;;
    8 WHEN literal tst ;;
    9 WHEN literal neg ;;
    10 WHEN literal cmp ;;
    11 WHEN literal cmn ;;
    12 WHEN literal orr ;;
    13 WHEN literal mul ;;
    14 WHEN literal bic ;;
    15 WHEN literal mvn ;;
    literal alu-op rot literal int32
  ESAC swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  drop 3
;

: disasm-bx
  dup 7 bit-set? IF literal blx ELSE literal bx THEN swap
  dup 3 bsr over 6 bit-set? IF disasm-hi-register ELSE disasm-low-register THEN swap
  drop 2
;

: disasm-hilo-op
  dup 8 bsr 3 logand
  dup 3 equals?
  IF drop disasm-bx
  ELSE
    ( literal ,ins rot swap )
    CASE
      0 WHEN literal addrr ;;
      1 WHEN literal cmprr ;;
      2 WHEN literal movrr ;;
      3 WHEN literal bx ;;
    ESAC swap
    dup
    dup 6 bit-set? IF disasm-hi-register ELSE disasm-low-register THEN swap
    dup 3 bsr over 7 bit-set? IF disasm-hi-register ELSE disasm-low-register THEN swap
    drop 3
  THEN
;

: disasm-ldr-pc ( op -- offset rd instruction size )
  literal ldr-pc swap
  dup 8 bsr disasm-low-register swap
  dup 0xFF logand 2 bsl swap literal int32 swap
  drop 3
;

: disasm-data-op
  dup 10 bsr 3 logand CASE
    0 WHEN disasm-alu-op ;;
    1 WHEN disasm-hilo-op ;;
    2 WHEN disasm-ldr-pc ;;
    3 WHEN disasm-ldr-pc ;;
  ESAC
;

: disasm-ldrstr ( op -- ro rb rd instruction count )
  dup 9 bit-set? IF literal .half swap THEN
  dup 10 bit-set? IF literal .byte swap THEN
  dup 11 bit-set? IF literal ldr ELSE literal str THEN swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  dup 6 bsr disasm-low-register swap
  drop 3
;

: disasm-ldr-off ( op -- offset rb rd instruction count )
  dup 12 bit-set? IF literal .offset-byte swap THEN
  dup 11 bit-set? IF literal ldr-offset ELSE literal str-offset THEN swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  dup 6 bsr 31 logand 2 bsl swap literal int32 swap
  drop 3
;

: disasm-ldrh-off ( op -- offset rb rd instruction count )
  dup 11 bit-set? IF literal ldrh ELSE literal strh THEN swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  dup 6 bsr 31 logand ( 2 bsl ) swap literal int32 swap
  drop 3
;

: disasm-ldst-stack ( op -- offset rd instruction count )
  dup 11 bit-set? IF literal ldr-sp ELSE literal str-sp THEN swap
  dup 8 bsr disasm-low-register swap
  dup 0xFF logand 2 bsl swap literal int32 swap
  drop 3
;

: disasm-addr-pcsp ( op -- offset rd instruction count )
  dup 11 bit-set? IF literal addr-pc ELSE literal addr-sp THEN swap
  dup 8 bsr disasm-low-register swap
  dup 0xFF logand 2 bsl swap literal int32 swap
  drop 3
;

: disasm-stack ( op -- ...operands instruction count )
  dup 8 bit-set? IF literal .pclr swap THEN
  dup 10 bit-set?
  ( todo decode popr/pushr register bitfield )
  IF dup 11 bit-set? IF literal popr ELSE literal pushr THEN
  ELSE dup 7 bit-set? IF literal dec-sp ELSE literal inc-sp THEN
  THEN swap
  dup dup 10 bit-set? UNLESS 2 bsl THEN 0xFF logand swap literal int32 swap
  8 bit-set? IF 4 ELSE 3 THEN
;

: disasm-ldm ( op -- rb rlist instruction count )
  dup 11 bit-set? IF literal ldmia ELSE literal stmia THEN swap
  dup 0xFF logand 2 bsl swap literal int32 swap
  dup 8 bsr disasm-low-register swap
  drop 3
;

: disasm-jumper ( op -- ...operands instruction count )
  dup 8 bsr 0xF logand CASE
    0 WHEN literal beq ;;
    1 WHEN literal bne ;;
    2 WHEN literal bcs ;;
    3 WHEN literal bcc ;;
    4 WHEN literal bmi ;;
    5 WHEN literal bpl ;;
    6 WHEN literal bvs ;;
    7 WHEN literal bvc ;;
    8 WHEN literal bhi ;;
    9 WHEN literal bls ;;
    10 WHEN literal bge ;;
    11 WHEN literal blt ;;
    12 WHEN literal bgt ;;
    13 WHEN literal ble ;;
    14 WHEN literal beq s" unknown jump op" error-line/2 ;;
    15 WHEN literal swi ;;
  ESAC swap
  0xFF logand literal int32
  int32 2
;

: disasm-branch ( op -- ...operands instruction count )
  literal branch swap
  dup 0x7FF logand 1 bsl swap
  literal int32 swap
  drop 3
;

: disasm-branch-link ( op -- ...operands instruction count )
  dup 11 bit-set? IF literal bl-lo ELSE literal bl-hi THEN swap
  0x7FF logand literal int32
  int32 2
;

: disasm-op1 ( op -- ...operands instruction count )
  ( most significant nibble mostly determines the kind )
  dup 0xF000 logand 12 bsr ,h space CASE
    ( 2x000? )
    0x0 WHEN disasm-mov ;;
    0x1 WHEN disasm-addsub ;;
    ( 2x001? )
    0x2 WHEN disasm-mcas# ;;
    0x3 WHEN disasm-mcas# ;;
    ( 2x010? )
    0x4 WHEN disasm-data-op ;;
    0x5 WHEN disasm-ldrstr ;;
    ( 2x1??? )
    0x6 WHEN disasm-ldr-off ;;
    0x7 WHEN disasm-ldr-off ;;
    0x8 WHEN disasm-ldrh-off ;;
    0x9 WHEN disasm-ldst-stack ;;
    0xA WHEN disasm-addr-pcsp ;;
    0xB WHEN disasm-stack ;;
    ( 2x11?? )
    0xC WHEN disasm-ldm ;;
    0xD WHEN disasm-jumper ;;
    0xE WHEN disasm-branch ;;
    0xF WHEN disasm-branch-link ;;
    s" Unknown op" error-line/2 int32 0
  ESAC
;

: disasm-branch-link2
  literal branch-link swap
  dup 0x7FF logand 12 bsl swap
  16 bsr 0x7FF logand 1 bsl logior
  literal int32
  int32 3
;

: disasm-sdiv ( op32 -- rm rn rd sdiv 4 )
  literal sdiv swap
  dup 24 bsr disasm-register swap
  dup disasm-register swap
  16 bsr disasm-register
  int32 4
;

: disasm-udiv ( op32 -- rm rn rd udiv 4 )
  literal udiv swap
  dup 24 bsr disasm-register swap
  dup disasm-register swap
  16 bsr disasm-register
  int32 4
;

: disasm-mrs ( op32 -- reg mrs 2 )
  literal mrs swap
  24 bsr disasm-register
  int32 2
;

: disasm-msr ( op32 -- reg mask msr 4 ) ( todo backwards return list )
  literal mrs swap
  dup 24 bsr 0xF logand swap
  literal int32 swap
  24 bsr disasm-register
  int32 3
;

: disasm-mcrr ( op32 -- Rt2 CRm Opc Coproc Rt mcrr 9 )
  literal mcrr swap
  dup 28 bsr disasm-register swap
  dup 24 bsr 0xF logand swap literal int32 swap
  dup 20 bsr 0xF logand swap literal int32 swap
  dup 16 bsr 0xF logand swap literal int32 swap
  dup disasm-register swap
  drop int32 9
;

: disasm-mrrc ( op32 -- Rt2 CRm Opc Coproc Rt mrrc 9 )
  literal mrrc swap
  dup 28 bsr disasm-register swap
  dup 24 bsr 0xF logand swap literal int32 swap
  dup 20 bsr 0xF logand swap literal int32 swap
  dup 16 bsr 0xF logand swap literal int32 swap
  dup disasm-register swap
  drop int32 9
;

: disasm-stc ( op32 -- Rn imm8 coproc CRd stc 8 )
  literal stc swap
  dup 28 bsr 0xF logand swap literal int32 swap
  dup 24 bsr 0xF logand swap literal int32 swap
  dup 16 bsr 0xFF logand swap literal int32 swap
  dup disasm-register swap
  drop int32 8
;

: disasm-ldc ( op32 -- Rn imm8 coproc CRd ldc 8 )
  literal ldc swap
  dup 28 bsr 0xF logand swap literal int32 swap
  dup 24 bsr 0xF logand swap literal int32 swap
  dup 16 bsr 0xFF logand swap literal int32 swap
  dup disasm-register swap
  drop int32 8
;

: disasm-cdp ( op32 -- CRn Op1 CRm Opc2 coproc CRd cdp 13 )
  literal cdp swap
  dup 28 bsr 0xF logand swap literal int32 swap
  dup 24 bsr 0xF logand swap literal int32 swap
  dup 21 bsr 0x7 logand swap literal int32 swap
  dup 16 bsr 0xF logand swap literal int32 swap
  dup 4 bsr 0xF logand swap literal int32 swap
  dup 0xF logand swap literal int32 swap
  drop int32 13
;

: disasm-mcr ( op32 -- CRn Op1 CRm Op2 coproc Rxf mcr 13 )
  literal mcr swap
  dup 28 bsr 0xF logand swap literal int32 swap
  dup 24 bsr 0xF logand swap literal int32 swap
  dup 21 bsr 0x7 logand swap literal int32 swap
  dup 16 bsr 0xF logand swap literal int32 swap
  dup 5 bsr 0x7 logand swap literal int32 swap
  dup 0xF logand swap literal int32 swap
  drop int32 13
;

: disasm-mrc ( op32 -- CRn Op1 CRm Op2 coproc Rxf mrc 13 )
  literal mrc swap
  dup 28 bsr 0xF logand swap literal int32 swap
  dup 24 bsr 0xF logand swap literal int32 swap
  dup 21 bsr 0x7 logand swap literal int32 swap
  dup 16 bsr 0xF logand swap literal int32 swap
  dup 5 bsr 0x7 logand swap literal int32 swap
  dup 0xF logand swap literal int32 swap
  drop int32 13
;

: disasm-op2 ( op32 -- ...words count )
  ( v1 branch )
  dup 0x8000F800 logand 0x8000F000 equals? IF disasm-branch-link2 proper-exit THEN
  ( v2 operations )
  dup 0xF0F0FFF0 logand 0xF0F0FB90 equals? IF disasm-sdiv proper-exit THEN
  dup 0xF0F0FFF0 logand 0xF0F0FBB0 equals? IF disasm-udiv proper-exit THEN
  ( v2 coprocessor )
  dup 0xF00EFFFF logand 0x8000F3EF equals? IF disasm-mrs proper-exit THEN
  dup 0xF00EFFF0 logand 0x8000F380 equals? IF disasm-msr proper-exit THEN
  dup 0x0000FFF0 logand 0xEC40 equals? IF disasm-mcrr proper-exit THEN
  dup 0x0000FFF0 logand 0xEC50 equals? IF disasm-mrrc proper-exit THEN
  dup 0x0000FF10 logand 0xEC00 equals? IF disasm-stc proper-exit THEN
  dup 0x0000FF10 logand 0xEC10 equals? IF disasm-ldc proper-exit THEN
  dup 0x0010FF00 logand 0x00EE00 equals? IF disasm-cdp proper-exit THEN
  dup 0x0010FF10 logand 0x10EE00 equals? IF disasm-mcr proper-exit THEN
  dup 0x0010FF10 logand 0x10EE10 equals? IF disasm-mrc proper-exit THEN
  s" Unknown 32 bit op: " error-string/2 error-hex-uint enl
;

def two-byte-op?
  arg0 0xF000 logand 0xF000 equals? IF true return1 THEN
  arg0 0xF800 logand 0xE800 equals? return1
end

def disasm/3 ( ptr num-bytes size ++ ptr size )
  arg1 2 int< IF here arg0 exit-frame THEN
  arg1 2 - set-arg1
  literal ,ins
  ( arg2 arg1 2 - peek-off .h space )
  arg2 arg1 peek-off-short ,h space
  arg2 arg1 2 - peek-off-short ,h space
  two-byte-op? IF
    arg1 2 - set-arg1
    swap 16 bsl logior ,h space disasm-op2
  ELSE drop disasm-op1
  THEN nl
  arg0 + 1 + set-arg0
  repeat-frame
end

def disasm ( ptr num-bytes ++ ptr size )
  arg1 arg0 0 disasm/3 exit-frame
end

def disasm-word
  ( todo detect if word is aarch32 or thumb )
  ( todo drop the length argument )
  arg1 dict-entry-code @ cs + 1 - arg0 disasm
  exit-frame
end

def write-disasm ( ptr num-cells -- )
  arg0 0 int<= IF nl 2 return0-n THEN
  arg1 @ cs +
  dup literalizes? IF
    arg1 cell-size + set-arg1
    arg0 1 - set-arg0
    arg1 @ write-uint space
  ELSE
    dup dict dict-contains?/2 IF
      2 dropn dup dict-entry-name @ cs + write-string space
      dup ' ,ins equals? IF nl THEN
    ELSE
      s" Unknown word" error-line/2
      2 dropn dup write-hex-uint space
    THEN
  THEN
  drop
  arg1 cell-size + set-arg1
  arg0 1 - set-arg0
  repeat-frame
end
