( Register value to symbolic decoding: )

SYS:DEFINED? asm-thumb UNLESS s" src/lib/asm/thumb.4th" load/2 THEN

( todo ldr-pc data should be output as a hex dump; point the entry's data at it?  )
( todo floating point ops )

SYS:DEFINED? NORTH-COMPILE-TIME IF
  sys:: next-asm-word
    next-token asm-thumb mark-dict @ from-out-addr out-origin @ dict-lookup/4
    UNLESS not-found/2 0
    ELSE to-out-addr rot 2 dropn
    THEN
  ;

  sys:alias> asm' next-asm-word

  sys:: [asm'] out-off' literal next-asm-word ; cross-immediate-as asm'
ELSE
  : next-asm-word
    next-token asm-thumb mark-dict @ as-code-pointer cs dict-lookup/4
    UNLESS not-found/2 0
    ELSE rot 2 dropn
    THEN
  ;

  alias> asm' next-asm-word

  : [asm'] literal literal next-asm-word dup IF cs - THEN ; immediate-as asm'
THEN

0
asm' r7
asm' r6
asm' r5
asm' r4
asm' r3
asm' r2
asm' r1
asm' r0
here
SYS:DEFINED? NORTH-COMPILE-TIME IF
  dhere to-out-addr swap 9 ,seq
  const-offset> DISASM-LOW-REGS
  : disasm-low-register 7 logand DISASM-LOW-REGS swap seq-peek ;
ELSE
  const> DISASM-LOW-REGS
  : disasm-low-register 7 logand DISASM-LOW-REGS swap seq-peek cs - ;
THEN

0
asm' pc
asm' lr
asm' sp
asm' ip
asm' fp
asm' sl
asm' r9
asm' r8
here
SYS:DEFINED? NORTH-COMPILE-TIME IF
  dhere to-out-addr swap 9 ,seq
  const-offset> DISASM-HI-REGS
  : disasm-hi-register 7 logand DISASM-HI-REGS swap seq-peek ;
ELSE
  const> DISASM-HI-REGS
  : disasm-hi-register 7 logand DISASM-HI-REGS swap seq-peek cs - ;
THEN

: disasm-register
  0xF logand dup 8 int< IF disasm-low-register ELSE disasm-hi-register THEN
;

( 16 bit ops: )

: disasm-mov ( op -- shift rs rd instruction count )
  dup 11 bsr 3 logand CASE
    0 WHEN asm' mov-lsl ;;
    1 WHEN asm' mov-lsr ;;
    2 WHEN asm' mov-asr ;;
  ESAC swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  6 bsr 31 logand literal int32
  int32 5
;

: disasm-addsub ( op -- rn rs rd instruction count )
  dup 10 bit-set? IF asm' .immed swap THEN
  dup 9 bit-set? IF asm' sub ELSE asm' add THEN swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  dup 10 bit-set? IF
    6 bsr 0x7 logand literal int32
    int32 5
  ELSE
    6 bsr disasm-low-register
    int32 4
  THEN
;

: disasm-mcas# ( op -- immed rd instruction count )
  dup 11 bsr 3 logand CASE
    0 WHEN asm' mov# ;;
    1 WHEN asm' cmp# ;;
    2 WHEN asm' add# ;;
    3 WHEN asm' sub# ;;
  ESAC swap
  dup 8 bsr disasm-low-register swap
  dup 0xFF logand swap literal int32 swap
  drop 4
;


: disasm-alu-op ( op -- rs rd instruction count )
  dup 6 bsr 0xF logand CASE
    0 WHEN asm' and ;;
    1 WHEN asm' eor ;;
    2 WHEN asm' lsl ;;
    3 WHEN asm' lsr ;;
    4 WHEN asm' asr ;;
    5 WHEN asm' adc ;;
    6 WHEN asm' sbc ;;
    7 WHEN asm' ror ;;
    8 WHEN asm' tst ;;
    9 WHEN asm' neg ;;
    10 WHEN asm' cmp ;;
    11 WHEN asm' cmn ;;
    12 WHEN asm' orr ;;
    13 WHEN asm' mul ;;
    14 WHEN asm' bic ;;
    15 WHEN asm' mvn ;;
    asm' alu-op rot literal int32
  ESAC swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  drop 3
;

: disasm-bx
  dup 7 bit-set? IF asm' blx ELSE asm' bx THEN swap
  dup 3 bsr over 6 bit-set? IF disasm-hi-register ELSE disasm-low-register THEN swap
  drop 2
;

: disasm-hilo-op
  dup 8 bsr 3 logand
  dup 3 equals?
  IF drop disasm-bx
  ELSE
    ( asm' ,ins rot swap )
    CASE
      0 WHEN asm' addrr ;;
      1 WHEN asm' cmprr ;;
      2 WHEN asm' movrr ;;
      3 WHEN asm' bx ;;
    ESAC swap
    dup dup 7 bit-set? IF disasm-hi-register ELSE disasm-low-register THEN swap
    dup 3 bsr over 6 bit-set? IF disasm-hi-register ELSE disasm-low-register THEN swap
    drop 3
  THEN
;

: disasm-ldr-pc ( op -- offset rd instruction size )
  asm' ldr-pc swap
  dup 8 bsr disasm-low-register swap
  dup 0xFF logand 2 bsl swap literal int32 swap
  drop 4
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
  dup 9 bit-set? IF asm' .half swap THEN
  dup 10 bit-set? IF asm' .byte swap THEN
  dup 11 bit-set? IF asm' ldr ELSE asm' str THEN swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  dup 6 bsr disasm-low-register swap
  4
  over 9 bit-set? IF 1 + THEN
  over 10 bit-set? IF 1 + THEN
  swap drop
;

: disasm-ldr-off ( op -- offset rb rd instruction count )
  dup 12 bit-set? IF asm' .offset-byte swap THEN
  dup 11 bit-set? IF asm' ldr-offset ELSE asm' str-offset THEN swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  dup 6 bsr 31 logand 2 bsl swap literal int32 swap
  12 bit-set? IF 6 ELSE 5 THEN
;

: disasm-ldrh-off ( op -- offset rb rd instruction count )
  dup 11 bit-set? IF asm' ldrh ELSE asm' strh THEN swap
  dup disasm-low-register swap
  dup 3 bsr disasm-low-register swap
  dup 6 bsr 31 logand 2 bsl swap literal int32 swap
  drop 5
;

: disasm-ldst-stack ( op -- offset rd instruction count )
  dup 11 bit-set? IF asm' ldr-sp ELSE asm' str-sp THEN swap
  dup 8 bsr disasm-low-register swap
  dup 0xFF logand 2 bsl swap literal int32 swap
  drop 4
;

: disasm-addr-pcsp ( op -- offset rd instruction count )
  dup 11 bit-set? IF asm' addr-sp ELSE asm' addr-pc THEN swap
  dup 8 bsr disasm-low-register swap
  dup 0xFF logand 2 bsl swap literal int32 swap
  drop 3
;

: disasm-stack ( op -- ...operands instruction count )
  dup 10 bit-set? IF
    ( todo decode popr/pushr register bitfield )
    dup 8 bit-set? IF asm' .pclr swap THEN
    dup 11 bit-set? IF asm' popr ELSE asm' pushr THEN swap
    dup 0xFF logand swap literal int32 swap
    int32 8 bit-set? IF 4 ELSE 3 THEN
  ELSE
    dup 7 bit-set? IF asm' dec-sp ELSE asm' inc-sp THEN swap
    dup 0x7F logand 2 bsl swap literal int32 swap
    drop 3
  THEN
;

: disasm-setend
  0x8 logand IF asm' bigend ELSE asm' lilend THEN
  int32 1
;

: disasm-cps
  1 swap
  dup 0 bit-set? IF asm' cps.f rot 1 int-add swap THEN
  dup 1 bit-set? IF asm' cps.i rot 1 int-add swap THEN
  dup 2 bit-set? IF asm' cps.a rot 1 int-add swap THEN
  dup 4 bit-set? IF asm' cpsid ELSE asm' cpsie THEN
  rot swap drop
;

: disasm-cpu-flag-op
  dup 0xFFE0 logand 0xB660 equals?
  IF disasm-cps
  ELSE
    dup 0xFFF7 logand 0xB650 equals?
    IF disasm-setend
    ELSE disasm-stack
    THEN
  THEN
;

: disasm-ldm ( op -- rb rlist instruction count )
  dup 11 bit-set? IF asm' ldmia ELSE asm' stmia THEN swap
  dup 0xFF logand swap literal int32 swap
  dup 8 bsr disasm-low-register swap
  drop 4
;

: disasm-jumper ( op -- ...operands instruction count )
  dup 8 bsr 0xF logand CASE
    0 WHEN asm' beq ;;
    1 WHEN asm' bne ;;
    2 WHEN asm' bcs ;;
    3 WHEN asm' bcc ;;
    4 WHEN asm' bmi ;;
    5 WHEN asm' bpl ;;
    6 WHEN asm' bvs ;;
    7 WHEN asm' bvc ;;
    8 WHEN asm' bhi ;;
    9 WHEN asm' bls ;;
    10 WHEN asm' bge ;;
    11 WHEN asm' blt ;;
    12 WHEN asm' bgt ;;
    13 WHEN asm' ble ;;
    14 WHEN asm' beq s" unknown jump op" error-line/2 ;;
    15 WHEN asm' swi ;;
  ESAC swap
  0xFF logand over asm' swi equals? UNLESS
    sign-extend-byte 1 bsl
  THEN literal int32
  int32 3
;

: disasm-branch ( op -- ...operands instruction count )
  asm' branch swap
  dup 0x7FF logand 1 bsl 11 sign-extend-from swap
  literal int32 swap
  drop 3
;

: disasm-branch-link ( op -- ...operands instruction count )
  dup 11 bit-set? IF asm' bl-lo ELSE asm' bl-hi THEN swap
  0x7FF logand 11 sign-extend-from literal int32
  int32 3
;

: disasm-op1 ( op -- ...operands instruction count )
  ( most significant nibble mostly determines the kind )
  dup 0xF000 logand 12 bsr CASE
    ( 2x000? )
    0x0 WHEN disasm-mov ;;
    0x1 WHEN dup 0x800 logand IF disasm-addsub ELSE disasm-mov THEN ;;
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
    0xB WHEN disasm-cpu-flag-op ;;
    ( 2x11?? )
    0xC WHEN disasm-ldm ;;
    0xD WHEN disasm-jumper ;;
    0xE WHEN disasm-branch ;;
    0xF WHEN disasm-branch-link ;;
    s" Unknown op" error-line/2 int32 0
  ESAC
;

( 32 bit ops: )

: disasm-branch-link2
  asm' branch-link swap
  dup 0x7FF logand 12 bsl swap
  16 bsr 0x7FF logand 1 bsl logior 22 sign-extend-from
  literal int32
  int32 3
;

: disasm-sdiv ( op32 -- rm rn rd sdiv 4 )
  asm' sdiv swap
  dup 24 bsr disasm-register swap
  dup disasm-register swap
  16 bsr disasm-register
  int32 4
;

: disasm-udiv ( op32 -- rm rn rd udiv 4 )
  asm' udiv swap
  dup 24 bsr disasm-register swap
  dup disasm-register swap
  16 bsr disasm-register
  int32 4
;

: disasm-ldr-pc.w ( op32 -- imm int32 reg ldr-pc.w 4 )
  asm' ldr-pc.w swap
  dup 28 bsr disasm-register swap
  16 bsr 0xFFF logand literal int32
  int32 4
;

: disasm-mrs ( op32 -- reg mrs 2 )
  asm' mrs swap
  24 bsr disasm-register
  int32 2
;

: disasm-msr ( op32 -- reg mask msr 4 ) ( todo backwards return list )
  asm' msr swap
  dup 24 bsr 0xF logand swap
  literal int32 swap
  disasm-register
  int32 4
;

: swap-nibbles dup 16 bsl swap 16 bsr 0xFFFF logand logior ;

: disasm-mcrr ( op32 -- Rt2 CRm Opc Coproc Rt mcrr 9 )
  asm' mcrr
  dup 28 bsr disasm-register swap
  dup 24 bsr 0xF logand swap literal int32 swap
  dup 20 bsr 0xF logand swap literal int32 swap
  dup 16 bsr 0xF logand swap literal int32 swap
  dup disasm-register swap
  drop int32 9
;

: disasm-mrrc ( op32 -- Rt2 CRm Opc Coproc Rt mrrc 9 )
  asm' mrrc swap
  dup 28 bsr disasm-register swap
  dup 24 bsr 0xF logand swap literal int32 swap
  dup 20 bsr 0xF logand swap literal int32 swap
  dup 16 bsr 0xF logand swap literal int32 swap
  dup disasm-register swap
  drop int32 9
;

( todo flags )
( todo standardized ordering of args )
( toda reverse arg lists )

: disasm-stc-flags ( counter op32 -- ops... counter op32 )
  dup 5 bit-set? IF swap 1 + swap asm' coproc-w shift THEN
  dup 6 bit-set? IF swap 1 + swap asm' coproc-d shift THEN
  dup 7 bit-set? IF swap 1 + swap asm' coproc-u shift THEN
  dup 8 bit-set? IF swap 1 + swap asm' coproc-p shift THEN
;

: disasm-stc ( op32 -- imm8 Rn CRd coproc stc flags... 9+#flags )
  0 swap disasm-stc-flags
  asm' stc shift
  dup 24 bsr 0xF logand shift literal int32 shift
  dup 28 bsr 0xF logand shift literal int32 shift
  dup 0xF logand ( shift literal int32 shift ) disasm-register shift
  dup 16 bsr 0xFF logand shift literal int32 shift
  drop 9 +
;

: disasm-ldc ( op32 -- imm8 Rn CRd coproc ldc flags... 9+#flags )
  0 swap disasm-stc-flags
  asm' ldc shift
  dup 24 bsr 0xF logand shift literal int32 shift
  dup 28 bsr 0xF logand shift literal int32 shift
  dup 0xF logand ( shift literal int32 shift ) disasm-register shift
  dup 16 bsr 0xFF logand shift literal int32 shift
  drop 8 +
;

: disasm-cdp ( op32 -- cp crm crn crd cpop cp# 13 )
  asm' cdp
  swap swap-nibbles
  dup 8 bsr 0xF logand swap literal int32 swap
  dup 20 bsr 0xF logand swap literal int32 swap
  dup 12 bsr 0xF logand swap literal int32 swap
  dup 16 bsr 0xF logand swap literal int32 swap
  dup 0xF logand swap literal int32 swap
  dup 5 bsr 0x7 logand swap literal int32 swap
  drop int32 13
;

: disasm-mcr ( op32 -- cp crm crn rd cpop cp# mcr 12 )
  asm' mcr
  swap swap-nibbles
  dup 8 bsr 0xF logand swap literal int32 swap
  dup 21 bsr 0x7 logand swap literal int32 swap
  dup 12 bsr 0xF logand disasm-register swap
  dup 16 bsr 0xF logand swap literal int32 swap
  dup 0xF logand swap literal int32 swap
  dup 5 bsr 0x7 logand swap literal int32 swap
  drop int32 12
;

: disasm-mrc ( op32 -- cp crm crn rd cpop cp# mrc 12 )
  asm' mrc
  swap swap-nibbles
  dup 8 bsr 0xF logand swap literal int32 swap
  dup 21 bsr 0x7 logand swap literal int32 swap
  dup 12 bsr 0xF logand disasm-register swap
  dup 16 bsr 0xF logand swap literal int32 swap
  dup 0xF logand swap literal int32 swap
  dup 5 bsr 0x7 logand swap literal int32 swap
  drop int32 12
;

: disasm-tbb ( op32 -- index base tbb 6 )
  dup 0x100000 logand IF asm' tbh ELSE asm' tbb THEN swap
  dup 0xF logand disasm-register swap
  dup 16 bsr 0xF logand disasm-register swap
  drop int32 6
;

: disasm-op2 ( op32 -- ...words count )
  ( v2 operations )
  dup 0xF0F0FFF0 logand 0xF0F0FB90 equals? IF disasm-sdiv proper-exit THEN
  dup 0xF0F0FFF0 logand 0xF0F0FBB0 equals? IF disasm-udiv proper-exit THEN
  dup 0x0000FFEF logand 0xF8CF equals? IF disasm-ldr-pc.w proper-exit THEN
  ( v2 coprocessor )
  dup 0xF00EFFFF logand 0x8000F3EF equals? IF disasm-mrs proper-exit THEN
  dup 0xF00EFFF0 logand 0x8000F380 equals? IF disasm-msr proper-exit THEN
  dup 0xFFE0FFF0 logand 0xF000E8D0 equals? IF disasm-tbb proper-exit THEN
  dup 0x0000FFF0 logand 0xEC40 equals? IF disasm-mcrr proper-exit THEN
  dup 0x0000FFF0 logand 0xEC50 equals? IF disasm-mrrc proper-exit THEN
  dup 0x0000FF10 logand 0xEC00 equals? IF disasm-stc proper-exit THEN
  dup 0x0000FF10 logand 0xEC10 equals? IF disasm-ldc proper-exit THEN
  dup 0x0010FF00 logand 0x00EE00 equals? IF disasm-cdp proper-exit THEN
  dup 0x0010FF10 logand 0x10EE00 equals? IF disasm-mcr proper-exit THEN
  dup 0x0010FF10 logand 0x10EE10 equals? IF disasm-mrc proper-exit THEN
  ( v1 branch )
  dup 0xF800F000 logand 0xF800F000 equals? IF disasm-branch-link2 proper-exit THEN
  drop 0
;

def two-shorts-op?
  arg0 0xF000 logand 0xF000 equals? IF true return1 THEN
  arg0 0xE800 logand 0xE800 equals? return1
end

def disasm/3 ( ptr num-bytes size ++ ptr size )
  arg1 2 int< IF here arg0 exit-frame THEN
  arg1 2 - set-arg1
  asm' ,ins
  arg2 arg1 peek-off-short
  arg2 arg1 2 - peek-off-short
  two-shorts-op? IF
    swap 16 bsl logior disasm-op2
    dup IF
      arg1 2 - set-arg1
    ELSE
      drop arg2 arg1 peek-off-short disasm-op1
    THEN
  ELSE drop disasm-op1
  THEN
  arg0 + 1 + set-arg0
  repeat-frame
end

def disasm ( ptr num-bytes ++ ptr size )
  arg1 arg0 0 disasm/3 exit-frame
end

def is-thumb-op? ( word -- yes? )
  arg0 is-op? IF
    arg0 dict-entry-code @ 1 logand IF true set-arg0 return0 THEN
  THEN
  false set-arg0
end

def disasm-word
  ( todo detect if word is aarch32 or thumb )
  arg0 is-thumb-op? IF
    arg0 dict-entry-code @ cs + 0xFFFFFFFE logand dup @ swap cell-size + swap disasm
  ELSE 0
  THEN exit-frame
end

def write-disasm ( ptr num-cells -- )
  arg0 0 int<= IF 2 return0-n THEN
  arg1 @ cs +
  dup literalizes? IF
    arg1 cell-size + set-arg1
    arg0 1 - set-arg0
    dup ' int32 equals? IF
      arg1 @ write-int
    ELSE
      arg1 @ write-uint
    THEN space
  ELSE
    dup asm-thumb mark-dict @ as-code-pointer dict-contains?/2 IF
      2 dropn dup dict-entry-name @ cs + write-string space
      dup asm' ,ins cs + equals? IF nl arg0 cell-size uint< UNLESS space space THEN THEN
    ELSE
      s" ( Unknown-Word: ) " write-string/2
      2 dropn dup write-hex-uint
      arg0 cell-size uint< IF nl ELSE space THEN
    THEN
  THEN
  drop
  arg1 cell-size + set-arg1
  arg0 1 - set-arg0
  repeat-frame
end

def write-word-disasm ( word -- decompiled? )
  arg0 disasm-word
  dup IF space space write-disasm true
  ELSE false
  THEN set-arg0
end

SYS:DEFINED? NORTH-COMPILE-TIME IF
  OUT:DEFINED? decompile-op-fn IF
    out' write-word-disasm out' decompile-op-fn set-out-var!
  THEN
ELSE
  SYS:DEFINED? decompile-op-fn IF
    ' write-word-disasm decompile-op-fn !
  THEN
THEN
