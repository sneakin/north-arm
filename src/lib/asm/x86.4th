( X86 Assembler limited to ops needed for a Forth runner.
  See 24594.pdf: AMD64 Architecture Programmer’s Manual Volume 3: General-Purpose and System Instructions

x86 instructions follow the form:
  prefixes* opcode [modrm sib?]? immediate?
)

16 var> x86-bits

NORTH-STAGE 0 equals? [IF]
  : 16bit? x86-bits 16 equals? ;
  : 32bit? x86-bits 32 equals? ;
  : 64bit? x86-bits 64 equals? ;

  : x86-bits! set-x86-bits ;
[ELSE]
  : 16bit? x86-bits peek 16 equals? ;
  : 32bit? x86-bits peek 32 equals? ;
  : 64bit? x86-bits peek 64 equals? ;

  : x86-bits! x86-bits poke ;
[THEN]

( Prefixes: )

: oper-size 0x66 ;
: addr-size 0x67 ;
: seg-cs 0x2e ;
: seg-ds 0x3E ;
: seg-es 0x26 ;
: seg-fs 0x64 ;
: seg-gs 0x65 ;
: seg-ss 0x36 ;
: lock 0xF0 ;
: rep 0xF3 ;
: repn 0xF2 ;

( Forth template: ~[sib] modrm OPCODE~ or ~register OPCODE~
  ~[sib] modrm~ is full 64 bit relying on ~OPCODE~ to convert to a real bytes and prefix.
 )

( REX prefix:
REX.W 3 0 = Default operand size 1 = 64-bit operand size
REX.R 2 1-bit extension of the ModRM reg field1, permitting access to 16 registers. 
REX.X 1 1-bit extension of the SIB index field1, permitting access to 16 registers. 
REX.B 0 1-bit extension of the ModRM r/m field1, SIB base field1, or opcode reg field, permitting access to 16 registers.
)

: rex 0x40 ;
: rex.w 0x8 logior ;
: rex.r 0x4 logior ;
: rex.x 0x2 logior ;
: rex.b 0x1 logior ;

( Registers: )

( modr/m registers: )
0 const> [bx+si]
1 const> [bx+di]
2 const> [bp+si]
3 const> [bp+di]
4 const> [si]
4 const> modrm-sib
5 const> [di]
6 const> [bp]
6 const> modrm-immed
7 const> [bx]

( ModRM registers: ModRM.reg1; ModRM.r/m [mod = 11b]; ModRM.r/m [mod ≠ 11b] ) 
( rAX, MMX0, XMM0, YMM0; rAX, MMX0, XMM0, YMM0; [rAX] )
( rCX, MMX1, XMM1, YMM1; rCX, MMX1, XMM1, YMM1; [rCX] )
( rDX, MMX2, XMM2, YMM2; rDX, MMX2, XMM2, YMM2; [rDX] )
( rBX, MMX3, XMM3, YMM3; rBX, MMX3, XMM3, YMM3; [rBX] )
( AH, rSP, MMX4, XMM4, YMM4; AH, rSP, MMX4, XMM4, YMM4; SIB )
( CH, rBP, MMX5, XMM5, YMM5; CH, rBP, MMX5, XMM5, YMM5; [rBP] )
( DH, rSI, MMX6, XMM6, YMM6; DH, rSI, MMX6, XMM6, YMM6; [rSI] )
( BH, rDI, MMX7, XMM7, YMM7; BH, rDI, MMX7, XMM7, YMM7; [rD] )

( Register constants, not actual instruction bits. )
0x00 const> al
0x01 const> cl
0x02 const> dl
0x03 const> bl
0x04 const> ah
0x05 const> ch
0x06 const> dh
0x07 const> bh

0x10 const> ax
0x11 const> cx
0x12 const> dx
0x13 const> bx
0x14 const> sp
0x15 const> bp
0x16 const> si
0x17 const> di

0x20 const> eax
0x21 const> ecx
0x22 const> edx
0x23 const> ebx
0x24 const> esp
0x25 const> ebp
0x26 const> esi
0x27 const> edi

0x30 const> rax
0x31 const> rcx
0x32 const> rdx
0x33 const> rbx
0x34 const> rsp
0x35 const> rbp
0x36 const> rsi
0x37 const> rdi
0x38 const> r8
0x39 const> r9
0x3A const> r10
0x3B const> r11
0x3C const> r12
0x3D const> r13
0x3E const> r14
0x3F const> r15

def reg8?
  arg0 bh al in-range? return1
end

def reg16?
  arg0 di ax in-range? return1
end

def reg32?
  arg0 edi eax in-range? return1
end

def reg64?
  arg0 r15 rax in-range? return1
end

def reg64-extended?
  arg0 r15 r8 in-range? return1
end

( ModR/M field )
				 
0 const> modrm-mode-ind ( register indirect, or displacement only )
1 const> modrm-mode-byte ( one byte displacement )
2 const> modrm-mode-long ( four byte displacement )
3 const> modrm-mode-reg ( register addressing )

: modrm/3 ( r/m reg mode -- pseudo-modrm )
  0xFF logand 16 bsl
  swap 0xFF logand 8 bsl logior
  swap 0xFF logand logior
;

( Accessors: )

: modrm-mode 16 bsr 0xFF logand ;
: modrm-reg 8 bsr 0xFF logand ;
: modrm-mem 0xFF logand ;

: modrm-reg! ( modrm new-mem -- modrm )
  0xFF logand 8 bsl swap 0xFFFF00FF logand logior
;

( ModR/M byte: mode[2], regA[3], r/m[3] )
: modrm-byte ( pseudo-modrm -- byte )
  dup modrm-mode 3 logand 3 bsl
  over modrm-reg 7 logand logior 3 bsl
  over modrm-mem 7 logand logior
  swap drop
;

( Mode predicates: )

: modrm-indirect? dup modrm-mode modrm-mode-ind equals? ;
: modrm-reg? dup modrm-mode modrm-mode-reg equals? ;

: modrm-mode-byte? dup modrm-mode modrm-mode-byte equals? ;
: modrm-mode-long? dup modrm-mode modrm-mode-long equals? ;
: modrm-offset? modrm-mode-byte? over modrm-mode-long? swap drop or ;

: modrm-sib?
  modrm-reg? lognot
  over modrm-mem 0xF logand modrm-sib equals?
  and
;

( Constructors: )

: modrm ( regB regA )
  modrm-mode-ind modrm/3
;

: modrr ( regB regA )
  modrm-mode-reg modrm/3
;

: modrm+ ( offset regB regA || offset sib sp regA )
  over 7 logand modrm-sib equals? IF 4 overn ELSE 3 overn THEN
  0xFF uint<= IF modrm-mode-byte ELSE modrm-mode-long THEN modrm/3
;

: modrmx ( sib RegA )
  modrm-sib swap modrm
;

: modrm+x ( sib reg )
  modrm-sib swap modrm+
;

( SIB: scale[2], index[3], base[3]; effective_address = scale * index + base + offset )
( Scaling factors: )
0 const> x1
1 const> x2
2 const> x4
3 const> x8

4 const> sib-none

: sib ( base index scale -- pseudo-sib )
  0xFF logand 16 bsl
  swap 0xFF logand 8 bsl logior
  swap 0xFF logand logior
;

: sib-base 0xFF logand ;
: sib-index 8 bsr 0xFF logand ;
: sib-scale 16 bsr 0xFF logand ;

: sib-byte ( psuedo-sib -- sib-byte )
  dup sib-scale 3 logand 3 bsl
  over sib-index 7 logand logior 3 bsl
  over sib-base 7 logand logior
  swap drop
;

( fixme using this or modrm-mem is wrong especially with a sib )
: modrm-dest-reg
  modrm-sib? IF over sib-base ELSE dup modrm-mem THEN
;

( Syntax in Forth:
Intel assembler line
=> ideal Forth
=> actual Forth

op reg, imm
=> imm reg op
=> op modrm-immed reg modrm-mode-byte modrm/3 imm

op [basereg+indexreg*scale], imm
=> imm [base index scale ] op
=> op modrm-immed modrm-sib modrm-mode-size modrm/3 basereg indexreg scale sib imm

op [basereg+indexreg*scale+offset], imm
=> imm [base index scale offset ] op
=> op modrm-immed modrm-sib modrm-mode-size modrm/3 basereg indexreg scale sib offset immed

op [basereg+index], imm
=> imm [reg index ] op
=> op modrm-immed modrm-sib modrm-mode-size modrm basereg sib-none x1 sib index imm

op [index], imm
=> imm @[ index ] op
=> op modrm-immed index modrm-mode-ind modrm/3 imm

op reg, reg
=> reg reg op
=> op reg reg modrr

op reg, [basereg+indexreg*scale]
=> [base index scale ] reg op
=> op modrm-sib reg modrm-mode-reg modrm basereg indexreg scale sib

op reg, [basereg+index]
=> [base index ] reg op
=> op modrm-sib reg modrm-mode-reg modrm basereg sib-none x1 sib index

op reg, [index]
=> @[ index ] reg op
=> op index reg modrm-mode-ind modrm

reg => register name
mem => base-reg + offset + index * scale => 

Operands fill out the ModRM byte, possibly a SIB, and with 64 bit instructions bits in the REX extend.
Emitted bytes depend on bit size of operands or explicitly.
)

: emit-op-size
  16bit? IF
    reg32? IF oper-size ,uint8 THEN
    ( reg64? IF oper-size ,uint8 THEN ) ( todo error )
  ELSE
    reg16? IF oper-size ,uint8 THEN
  THEN drop
;

: needs-rex? ( [sib] modrm ++ yes? )
  dup modrm-reg reg64? swap drop IF true proper-exit THEN
  modrm-sib? IF
    over sib-index reg64? swap drop IF true proper-exit THEN
    over sib-base reg64? swap drop IF true proper-exit THEN
  ELSE
    dup modrm-mem reg64? swap drop IF true proper-exit THEN
  THEN false
;

: emit-rex-modrm ( [sib] modrm ++ )
  needs-rex? UNLESS proper-exit THEN
  ( set rex.w if anything is 64 bit )
  rex
  2 overn modrm-reg reg64? swap drop IF rex.w THEN
  ( set rex.r if modrm reg is 64 bit extended )
  2 overn modrm-reg reg64-extended? swap drop IF rex.r THEN
  2 overn modrm-sib? IF
    drop
    3 overn sib-base reg64? swap drop IF rex.w THEN
    ( set rex.x if sib index is 64 bit extended )
    3 overn sib-index reg64-extended? swap drop IF rex.x THEN
    ( set rex.b if sib base is 64 bit extended )
    3 overn sib-base reg64-extended? swap drop IF rex.b THEN
  ELSE
    ( set rex.b if modrm r/m is 64 bit extended )
    modrm-mem
    reg64? IF swap rex.w swap THEN
    reg64-extended? swap drop IF rex.b THEN
  THEN ,uint8
;

: emit-rex-b ( register -- )
  reg64? IF
    reg64-extended? IF rex rex.w rex.b ELSE rex rex.w THEN ,uint8
  THEN drop
;

: emit-register-data ( data register -- )
  reg8? IF
    drop ,uint8
  ELSE
    reg16? IF
      drop ,uint16
    ELSE
      reg32? IF
	drop ,uint32
      ELSE reg64? IF drop ,uint64
		  ELSE
		    s" Unknown register" error-line/2
		    2 dropn ( todo error )
		  THEN
      THEN
    THEN
  THEN
;

: emit-modrm ( [sib] modrm -- )
  dup modrm-byte ,uint8
  ( todo )
  modrm-reg? IF
    drop
  ELSE
    modrm-sib? IF swap sib-byte ,uint8 THEN
    modrm-offset? IF
      modrm-mode modrm-mode-byte equals? IF ,uint8 ELSE ,uint32 THEN
    ELSE
      drop
    THEN
  THEN
;

: emit-prefixes ( modrm register -- modrm )
  emit-op-size emit-rex-modrm
;

( Instructions: )

( NOP 90 Performs no operation.
NOP reg/mem16 | 0F 1F /0 | Performs no operation on a 16-bit register or memory operand.
NOP reg/mem32 | 0F 1F /0 | Performs no operation on a 32-bit register or memory operand.
NOP reg/mem64 | 0F 1F /0 | Performs no operation on a 64-bit register or memory operand. )
: nop
  0 modrm-reg!
  modrm-dest-reg emit-prefixes
  0x0F ,uint8 0x1F ,uint8
  emit-modrm
;

( Data moving: )

( MOV reg8, imm8	| B0 +rb ib | Move an 8-bit immediate value into an 8-bit register.
MOV reg16, imm16	| B8 +rw iw | Move a 16-bit immediate value into a 16-bit register.
MOV reg32, imm32	| B8 +rd id | Move an 32-bit immediate value into a 32-bit register.
MOV reg64, imm64	| B8 +rq iq | Move an 64-bit immediate value into a 64-bit register.
 )

( 0x88 - 0x8C, 0x8E )
( 0xA0 - 0xA3 )
( 0xB0, 0xB8 )
( 0xC6, 0xC7 )
: mov# ( number rd )
  reg8? IF
    0xB0 + ,uint8 ,uint8
  ELSE
    dup emit-op-size
    reg64? IF dup emit-rex-b THEN
    dup 0x7 logand 0xB8 + ,uint8
    emit-register-data
  THEN
THEN
;

( MOV reg/mem8, imm8	| C6 /0 ib | Move an 8-bit immediate value to an 8-bit register or 
memory operand.
MOV reg/mem16, imm16	| C7 /0 iw | Move a 16-bit immediate value to a 16-bit register or memory operand.
MOV reg/mem32, imm32	| C7 /0 id | Move a 32-bit immediate value to a 32-bit register or memory operand.
MOV reg/mem64, imm32	| C7 /0 id | Move a 32-bit signed immediate value to a 64-bit register or memory operand. )
: movm#
  dup modrm-mem emit-prefixes
  dup modrm-mem reg8? IF
    drop 0xC6 ,uint8 emit-modrm ,uint8
  ELSE
    drop 0xC7 ,uint8 emit-modrm
    16bit? IF ,uint16 ELSE ,uint32 THEN
  THEN
;

( MOV reg8, reg/mem8		| 8A /r | Move the contents of an 8-bit register or memory operand to an 8-bit destination register.
MOV reg16, reg/mem16		| 8B /r | Move the contents of a 16-bit register or memory operand to a 16-bit destination register.
MOV reg32, reg/mem32		| 8B /r | Move the contents of a 32-bit register or memory operand to a 32-bit destination register.
MOV reg64, reg/mem64		| 8B /r | Move the contents of a 64-bit register or memory operand to a 64-bit destination register. )
: movr ( ...modrm -- )
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x8A ELSE 0x8B THEN ,uint8 drop
  emit-modrm  
;

( MOV reg16/32/64/mem16, segReg	| 8C /r | Move the contents of a segment register to a 16-bit, 32- bit, or 64-bit destination register or to a 16-bit memory operand.
MOV segReg, reg/mem16		| 8E /r | Move the contents of a 16-bit register or memory operand to a segment register.
MOV AL, moffset8		| A0 | Move 8-bit data at a specified memory offset to the AL register.
MOV AX, moffset16		| A1 | Move 16-bit data at a specified memory offset to the AX register.
MOV EAX, moffset32		| A1 | Move 32-bit data at a specified memory offset to the EAX register.
MOV RAX, moffset64		| A1 | Move 64-bit data at a specified memory offset to the RAX register.
MOV moffset8, AL		| A2 | Move the contents of the AL register to an 8-bit memory offset.
MOV moffset16, AX		| A3 | Move the contents of the AX register to a 16-bit memory offset.
MOV moffset32, EAX		| A3 | Move the contents of the EAX register to a 32-bit memory offset.
MOV moffset64, RAX		| A3 | Move the contents of the RAX register to a 64-bit memory offset.
 )

( MOV reg/mem8, reg8		| 88 /r | Move the contents of an 8-bit register to an 8-bit destination register or memory operand.
MOV reg/mem16, reg16		| 89 /r | Move the contents of a 16-bit register to a 16-bit destination register or memory operand.
MOV reg/mem32, reg32		| 89 /r | Move the contents of a 32-bit register to a 32-bit destination register or memory operand.
MOV reg/mem64, reg64		| 89 /r | Move the contents of a 64-bit register to a 64-bit destination register or memory operand.
 )
: movm ( modrm )
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x88 ELSE 0x89 THEN ,uint8 drop
  emit-modrm  
;

( MOVBE reg16, mem16	| 0F 38 F0 /r | Load the low word of a general-purpose register from a 16-bit memory location while swapping the bytes.
MOVBE reg32, mem32	| 0F 38 F0 /r | Load the low doubleword of a general-purpose register from a 32-bit memory location while swapping the bytes.
MOVBE reg64, mem64	| 0F 38 F0 /r | Load a 64-bit register from a 64-bit memory location while swapping the bytes. )
: movber
  dup modrm-reg emit-prefixes
  0x0F ,uint8 0x38 ,uint8 0xF0 ,uint8
  emit-modrm
;

( MOVBE mem16, reg16	| 0F 38 F1 /r | Store the low word of a general-purpose register to a 16-bit memory location while swapping the bytes.
MOVBE mem32, reg32	| 0F 38 F1 /r | Store the low doubleword of a general-purpose register to a 32-bit memory location while swapping the bytes.
MOVBE mem64, reg64	| 0F 38 F1 /r | Store the contents of a 64-bit general-purpose register to a 64-bit memory location while swapping the bytes. )
: movbem
  dup modrm-reg emit-prefixes
  0x0F ,uint8 0x38 ,uint8 0xF1 ,uint8
  emit-modrm
;

( MOVSX reg16, reg/mem8	| 0F BE /r | Move the contents of an 8-bit register or memory location to a 16-bit register with sign extension.
MOVSX reg32, reg/mem8	| 0F BE /r | Move the contents of an 8-bit register or memory location to a 32-bit register with sign extension.
MOVSX reg64, reg/mem8	| 0F BE /r | Move the contents of an 8-bit register or memory location to a 64-bit register with sign extension.
MOVSX reg32, reg/mem16	| 0F BF /r | Move the contents of an 16-bit register or memory location to a 32-bit register with sign extension.
MOVSX reg64, reg/mem16	| 0F BF /r | Move the contents of an 16-bit register or memory location to a 64-bit register with sign extension. )
: movsx
  dup modrm-reg emit-prefixes
  0x0F ,uint8 0xBE ,uint8
  emit-modrm
;

( MOVSXD reg64, reg/mem32	| 63 /r | Move the contents of a 32-bit register or memory operand to a 64-bit register with sign extension )
: movsxd
  dup modrm-reg emit-prefixes
  0x63 ,uint8
  emit-modrm
;

( MOVZX reg16, reg/mem8	| 0F B6 /r | Move the contents of an 8-bit register or memory operand to a 16-bit register with zero-extension.
MOVZX reg32, reg/mem8	| 0F B6 /r | Move the contents of an 8-bit register or memory operand to a 32-bit register with zero-extension.
MOVZX reg64, reg/mem8	| 0F B6 /r | Move the contents of an 8-bit register or memory operand to a 64-bit register with zero-extension.
MOVZX reg32, reg/mem16	| 0F B7 /r | Move the contents of a 16-bit register or memory operand to a 32-bit register with zero-extension.
MOVZX reg64, reg/mem16	| 0F B7 /r | Move the contents of a 16-bit register or memory operand to a 64-bit register with zero-extension. )

( Memory access: )

( LEA reg16, mem	| 8D /r | Store effective address in a 16-bit register.
LEA reg32, mem		| 8D /r | Store effective address in a 32-bit register.
LEA reg64, mem		| 8D /r | Store effective address in a 64-bit register. )
: lea ( modrm -- )
  dup modrm-reg emit-prefixes
  0x8D ,uint8
  emit-modrm
;

( STOS mem8	| AA | Store the contents of the AL register to ES:rDI, and then increment or decrement rDI.
STOS mem16	| AB | Store the contents of the AX register to ES:rDI, and then increment or decrement rDI.
STOS mem32	| AB | Store the contents of the EAX register to ES:rDI, and then increment or decrement rDI.
STOS mem64	| AB | Store the contents of the RAX register to ES:rDI, and then increment or decrement rDI.
STOSB		| AA | Store the contents of the AL register to ES:rDI, and then increment or decrement rDI.
STOSW		| AB | Store the contents of the AX register to ES:rDI, and then increment or decrement rDI.
STOSD		| AB | Store the contents of the EAX register to ES:rDI, and then increment or decrement rDI.
STOSQ		| AB | Store the contents of the RAX register to ES:rDI, and then increment or decrement rDI. )

: st-indirect ( reg-src offset reg-base ) ( mov )
;

( LDS reg16, mem16:16	| C5 /r | Load DS:reg16 with a far pointer from memory.
[Redefined as VEX [2-byte prefix] in 64-bit mode.]
LDS reg32, mem16:32	| C5 /r | Load DS:reg32 with a far pointer from memory. 
[Redefined as VEX [2-byte prefix] in 64-bit mode.]
LES reg16, mem16:16	| C4 /r | Load ES:reg16 with a far pointer from memory. 
[Redefined as VEX [3-byte prefix] in 64-bit mode.]
LES reg32, mem16:32	| C4 /r | Load ES:reg32 with a far pointer from memory.
[Redefined as VEX [3-byte prefix] in 64-bit mode.]
LFS reg16, mem16:16	| 0F B4 /r | Load FS:reg16 with a 32-bit far pointer from memory.
LFS reg32, mem16:32	| 0F B4 /r | Load FS:reg32 with a 48-bit far pointer from memory.
LGS reg16, mem16:16	| 0F B5 /r | Load GS:reg16 with a 32-bit far pointer from memory.
LGS reg32, mem16:32	| 0F B5 /r | Load GS:reg32 with a 48-bit far pointer from memory.
LSS reg16, mem16:16	| 0F B2 /r | Load SS:reg16 with a 32-bit far pointer from memory.
LSS reg32, mem16:32	| 0F B2 /r | Load SS:reg32 with a 48-bit far pointer from memory.
LODS mem8		| AC | Load byte at DS:rSI into AL and then increment or decrement rSI.
LODS mem16		| AD | Load word at DS:rSI into AX and then increment or decrement rSI.
LODS mem32		| AD | Load doubleword at DS:rSI into EAX and then increment or decrement rSI.
LODS mem64		| AD | Load quadword at DS:rSI into RAX and then increment or decrement rSI.
LODSB			| AC | Load byte at DS:rSI into AL and then increment or decrement rSI.
LODSW			| AD | Load the word at DS:rSI into AX and then increment or decrement rSI.
LODSD			| AD | Load doubleword at DS:rSI into EAX and then increment or decrement rSI.
LODSQ			| AD | Load quadword at DS:rSI into RAX and then increment or decrement rSI. )

: ld-indirect ( offset reg-base rd ) ( mov )
;

: st-indirect-byte ( reg-src offset reg-base ) ( mov )
;

: ld-indirect-byte ( offset reg-base rd ) ( mov )
;

( Stack operations: )

( POP		| DS 1F | Pop the top of the stack into the DS register. 
[Invalid in 64-bit mode.]
POP ES          | 07 | Pop the top of the stack into the ES register. 
[Invalid in 64-bit mode.]
POP SS          | 17 | Pop the top of the stack into the SS register. 
[Invalid in 64-bit mode.] )

( POP reg16	| 58 +rw | Pop the top of the stack into a 16-bit register.
POP reg32	| 58 +rd | Pop the top of the stack into a 32-bit register.
[No prefix for encoding this in 64-bit mode.]
POP reg64	| 58 +rq | Pop the top of the stack into a 64-bit register. )
: pop ( reg )
  0x7 logand 0x58 int-add ,uint8
;

( POP reg/mem16 | 8F /0 | Pop the top of the stack into a 16-bit register or memory location.
POP reg/mem32	| 8F /0 | Pop the top of the stack into a 32-bit register or memory location.
[No prefix for encoding this in 64-bit mode.]
POP reg/mem64	| 8F /0 | Pop the top of the stack into a 64-bit register or memory location. )
: popm ( modrm -- )
  0 modrm-reg!
  modrm-dest-reg emit-prefixes
  0x8F ,uint8
  emit-modrm
;

( PUSH			| CS 0E | Push the CS selector onto the stack. [Invalid in 64-bit mode]
PUSH			| SS 16 | Push the SS selector onto the stack. [Invalid in 64-bit mode.]
PUSH			| DS 1E | Push the DS selector onto the stack. [Invalid in 64-bit mode.]
PUSH			| ES 06 | Push the ES selector onto the stack. [Invalid in 64-bit mode.]
PUSH			| FS 0F A0 | Push the FS selector onto the stack. 
PUSH			| GS 0F A8 | Push the GS selector onto the stack. )

( PUSH reg16		| 50 +rw | Push the contents of a 16-bit register onto the stack.
PUSH reg32		| 50 +rd | Push the contents of a 32-bit register onto the stack. [No prefix for encoding this in 64-bit mode.]
PUSH reg64		| 50 +rq | Push the contents of a 64-bit register onto the stack. )
: push ( reg )
  0x7 logand 0x50 int-add ,uint8
;

( PUSH imm8		| 6A ib | Push an 8-bit immediate value [sign-extended to 16, 32, or 64 bits] onto the stack.
PUSH imm16		| 68 iw | Push a 16-bit immediate value onto the stack.
PUSH imm32		| 68 id | Push a 32-bit immediate value onto the stack. [No prefix for encoding this in 64-bit mode.]
PUSH imm64		| 68 id | Push a sign-extended 32-bit immediate value onto the stack. )
: push# ( immed )
  dup 0xFF uint<= IF
    0x6A ,uint8 ,uint8
  ELSE
    0x68 ,uint8 16bit? IF ,uint16 ELSE ,uint32 THEN
  THEN
;

( PUSH reg/mem16	| FF /6 | Push the contents of a 16-bit register or memory operand onto the stack.
PUSH reg/mem32		| FF /6 |Push the contents of a 32-bit register or memory operand onto the stack. [No prefix for encoding this in 
64-bit mode.]
PUSH reg/mem64		| FF /6 | Push the contents of a 64-bit register or memory operand onto the stack. )
: pushm ( modrm )
  6 modrm-reg!
  modrm-dest-reg emit-prefixes
  0xFF ,uint8
  emit-modrm
;


( Logical operations: )

: emit-rol1
  modrm-reg!
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg8? IF 0xD0 ELSE 0xD1 THEN ,uint8 drop
  emit-modrm
;

: emit-rolcl
  modrm-reg!
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg8? IF 0xD2 ELSE 0xD3 THEN ,uint8 drop
  emit-modrm
;

: emit-rol#
  modrm-reg!
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg8? IF 0xC0 ELSE 0xC1 THEN ,uint8 drop
  emit-modrm
  ,uint8
;

( ROL reg/mem8, 1	| D0 /0 | Rotate an 8-bit register or memory operand left 1 bit.
ROL reg/mem8, CL	| D2 /0 | Rotate an 8-bit register or memory operand left the number of bits specified in the CL register.
ROL reg/mem8, imm8	| C0 /0 ib | Rotate an 8-bit register or memory operand left the number of bits specified by an 8-bit immediate value.
ROL reg/mem16, 1	| D1 /0 | Rotate a 16-bit register or memory operand left 1 bit.
ROL reg/mem16, CL	| D3 /0 | Rotate a 16-bit register or memory operand left the number of bits specified in the CL register.
ROL reg/mem16, imm8	| C1 /0 ib | Rotate a 16-bit register or memory operand left the number of bits specified by an 8-bit immediate value.
ROL reg/mem32, 1	| D1 /0 | Rotate a 32-bit register or memory operand left 1 bit.
ROL reg/mem32, CL	| D3 /0 | Rotate a 32-bit register or memory operand left the number of bits specified in the CL register.
ROL reg/mem32, imm8	| C1 /0 ib | Rotate a 32-bit register or memory operand left the number of bits specified by an 8-bit immediate value.
ROL reg/mem64, 1	| D1 /0 | Rotate a 64-bit register or memory operand left 1 bit.
ROL reg/mem64, CL	| D3 /0 | Rotate a 64-bit register or memory operand left the number of bits specified in the CL register.
ROL reg/mem64, imm8	| C1 /0 ib | Rotate a 64-bit register or memory operand left the number of bits specified by an 8-bit immediate value. )
: rol1 0 emit-rol1 ;
: rolcl 0 emit-rolcl ;
: rol# 0 emit-rol# ;

( ROR reg/mem8, 1	| D0 /1 | Rotate an 8-bit register or memory location right 1 bit.
ROR reg/mem8, CL	| D2 /1 | Rotate an 8-bit register or memory location right the number of bits specified in the CL register.
ROR reg/mem8, imm8	| C0 /1 ib | Rotate an 8-bit register or memory location right the number of bits specified by an 8-bit immediate value.
ROR reg/mem16, 1	| D1 /1 | Rotate a 16-bit register or memory location right 1 bit.
ROR reg/mem16, CL	| D3 /1 | Rotate a 16-bit register or memory location right the number of bits specified in the CL register.
ROR reg/mem16, imm8	| C1 /1 ib | Rotate a 16-bit register or memory location right the number of bits specified by an 8-bit immediate value.
ROR reg/mem32, 1	| D1 /1 | Rotate a 32-bit register or memory location right 1 bit.
ROR reg/mem32, CL	| D3 /1 | Rotate a 32-bit register or memory location right the number of bits specified in the CL register.
ROR reg/mem32, imm8	| C1 /1 ib | Rotate a 32-bit register or memory location right the number of bits specified by an 8-bit immediate value.
ROR reg/mem64, 1	| D1 /1 | Rotate a 64-bit register or memory location right 1 bit.
ROR reg/mem64, CL	| D3 /1 | Rotate a 64-bit register or memory operand right the number of bits specified in the CL register.
ROR reg/mem64, imm8	| C1 /1 ib | Rotate a 64-bit register or memory operand right the number of bits specified by an 8-bit immediate value. )
: ror1 1 emit-rol1 ;
: rorcl 1 emit-rolcl ;
: ror# 1 emit-rol# ;

( SHL reg/mem8, 1	| D0 /4 | Shift an 8-bit register or memory location by 1 bit.
SHL reg/mem8, CL	| D2 /4 | Shift an 8-bit register or memory location left the number of bits specified in the CL register.
SHL reg/mem8, imm8	| C0 /4 ib | Shift an 8-bit register or memory location left the number of bits specified by an 8-bit immediate value.
SHL reg/mem16, 1	| D1 /4 | Shift a 16-bit register or memory location left 1 bit.
SHL reg/mem16,  CL	| D3 /4 | Shift a 16-bit register or memory location left the number of bits specified in the CL register.
SHL reg/mem16, imm8	| C1 /4 ib | Shift a 16-bit register or memory location left the number of bits specified by an 8-bit immediate value.
SHL reg/mem32, 1	| D1 /4 | Shift a 32-bit register or memory location left 1 bit.
SHL reg/mem32, CL	| D3 /4 | Shift a 32-bit register or memory location left the number of bits specified in the CL register.
SHL reg/mem32, imm8	| C1 /4 ib | Shift a 32-bit register or memory location left the number of bits specified by an 8-bit immediate value.
SHL reg/mem64, 1	| D1 /4 | Shift a 64-bit register or memory location left 1 bit.
SHL reg/mem64, CL	| D3 /4 | Shift a 64-bit register or memory location left the number of bits specified in the CL register.
SHL reg/mem64, imm8	| C1 /4 ib | Shift a 64-bit register or memory location left the number of bits specified by an 8-bit immediate value. )
: shl1 4 emit-rol1 ;
: shlcl 4 emit-rolcl ;
: shl# 4 emit-rol# ;

( SAR reg/mem8, 1	| D0 /7 | Shift a signed 8-bit register or memory operand right 1 bit.
SAR reg/mem8, CL	| D2 /7 | Shift a signed 8-bit register or memory operand right the number of bits specified in the CL register.
SAR reg/mem8, imm8	| C0 /7 ib | Shift a signed 8-bit register or memory operand right the number of bits specified by an 8-bit immediate value.
SAR reg/mem16, 1	| D1 /7 | Shift a signed 16-bit register or memory operand right 1 bit.
SAR reg/mem16, CL	| D3 /7 | Shift a signed 16-bit register or memory operand right the number of bits specified in the CL register.
SAR reg/mem16, imm8	| C1 /7 ib | Shift a signed 16-bit register or memory operand right the number of bits specified by an 8-bit immediate value.
SAR reg/mem32, 1	| D1 /7 | Shift a signed 32-bit register or memory location 1 bit.
SAR reg/mem32, CL	| D3 /7 | Shift a signed 32-bit register or memory location ri
SAR reg/mem32, imm8	| C1 /7 ib | Shift a signed 32-bit register or memory location right the number of bits specified by an 8-bit immediate value.
SAR reg/mem64, 1	| D1 /7 | Shift a signed 64-bit register or memory location right 1 bit.
SAR reg/mem64, CL	| D3 /7 | Shift a signed 64-bit register or memory location right the number of bits specified in the CL register.
SAR reg/mem64, imm8	| C1 /7 ib | Shift a signed 64-bit register or memory location right the number of bits specified by an 8-bit immediate value. )
: sar1 7 emit-rol1 ;
: sarcl 7 emit-rolcl ;
: sar# 7 emit-rol# ;

( SHR reg/mem8, 1	| D0 /5 | Shift an 8-bit register or memory operand right 1 bit.
SHR reg/mem8, CL	| D2 /5 | Shift an 8-bit register or memory operand right the number of bits specified in the CL register.
SHR reg/mem8, imm8	| C0 /5 ib | Shift an 8-bit register or memory operand right the number of bits specified by an 8-bit immediate value.
SHR reg/mem16, 1	| D1 /5 | Shift a 16-bit register or memory operand right 1 bit.
SHR reg/mem16, CL	| D3 /5 | Shift a 16-bit register or memory operand right the number of bits specified in the CL register.
SHR reg/mem16, imm8	| C1 /5 ib | Shift a 16-bit register or memory operand right the number of bits specified by an 8-bit immediate value.
SHR reg/mem32, 1	| D1 /5 | Shift a 32-bit register or memory operand right 1 bit.
SHR reg/mem32, CL	| D3 /5 | Shift a 32-bit register or memory operand right the number of bits specified in the CL register.
SHR reg/mem32, imm8	| C1 /5 ib | Shift a 32-bit register or memory operand right the number of bits specified by an 8-bit immediate value.
SHR reg/mem64, 1	| D1 /5 | Shift a 64-bit register or memory operand right 1 bit.
SHR reg/mem64, CL	| D3 /5 | Shift a 64-bit register or memory operand right the number of bits specified in the CL register.
SHR reg/mem64, imm8	| C1 /5 ib | Shift a 64-bit register or memory operand right the number of bits specified by an 8-bit immediate value. )
: shr1 5 emit-rol1 ;
: shrcl 5 emit-rolcl ;
: shr# 5 emit-rol# ;

( NEG reg/mem8	| F6 /3 | Performs a two’s complement negation on an 8-bit register or memory operand.
NEG reg/mem16	| F7 /3 | Performs a two’s complement negation on a 16-bit register or memory operand.
NEG reg/mem32	| F7 /3 | Performs a two’s complement negation on a 32-bit register or memory operand.
NEG reg/mem64	| F7 /3 | Performs a two’s complement negation on a 64-bit register or memory operand. )
: neg ( modrm )
  3 modrm-reg!
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg8? IF 0xF6 ELSE 0xF7 THEN ,uint8 drop
  emit-modrm
;

( NOT reg/mem8	| F6 /2 | Complements the bits in an 8-bit register or memory operand.
NOT reg/mem16	| F7 /2 | Complements the bits in a 16-bit register or memory operand.
NOT reg/mem32	| F7 /2 | Complements the bits in a 32-bit register or memory operand.
NOT reg/mem64	| F7 /2 | Compliments the bits in a 64-bit register or memory operand. )
: x86:not ( modrm )
  2 modrm-reg!
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg8? IF 0xF6 ELSE 0xF7 THEN ,uint8 drop
  emit-modrm
;

( AND AL, imm8		| 24 ib | and the contents of AL with an immediate 8-bit value and store the result in AL.
AND AX, imm16		| 25 iw | and the contents of AX with an immediate 16-bit value and store the result in AX.
AND EAX, imm32		| 25 id | and the contents of EAX with an immediate 32-bit value and store the result in EAX.
AND RAX, imm32		| 25 id | and the contents of RAX with a sign-extended immediate 32-bit value and store the result in RAX. )

( AND reg/mem8, imm8	| 80 /4 ib | and the contents of reg/mem8 with imm8.
AND reg/mem16, imm16	| 81 /4 iw | and the contents of reg/mem16 with imm16.
AND reg/mem32, imm32	| 81 /4 id | and the contents of reg/mem32 with imm32.
AND reg/mem64, imm32	| 81 /4 id | and the contents of reg/mem64 with sign-extended imm32. )
: emit-80
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg8? IF
    drop
    0x80 ,uint8
    emit-modrm
    ,uint8
  ELSE
    drop
    0x81 ,uint8
    emit-modrm
    16bit? IF ,uint16 ELSE ,uint32 THEN
  THEN
;

: and#
  4 modrm-reg!
  emit-80
;

( AND reg/mem16, imm8	| 83 /4 ib | and the contents of reg/mem16 with a sign-extended 8-bit value.
AND reg/mem32, imm8	| 83 /4 ib | and the contents of reg/mem32 with a sign-extended 8-bit value.
AND reg/mem64, imm8	| 83 /4 ib | and the contents of reg/mem64 with a sign-extended 8-bit value. )
: emit-83
  modrm-dest-reg emit-prefixes
  0x83 ,uint8
  emit-modrm
  ,uint8
;

: and#i8
  4 modrm-reg! emit-83
;

( AND reg/mem8, reg8	| 20 /r | and the contents of an 8-bit register or memory location with the contents of an 8-bit register.
AND reg/mem16, reg16	| 21 /r | and the contents of a 16-bit register or memory location with the contents of a 16-bit register.
AND reg/mem32, reg32	| 21 /r | and the contents of a 32-bit register or memory location with the contents of a 32-bit register.
AND reg/mem64, reg64	| 21 /r | and the contents of a 64-bit register or memory location with the contents of a 64-bit register. )
: andm
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x20 ELSE 0x21 THEN ,uint8 drop
  emit-modrm
;

( AND reg8, reg/mem8	| 22 /r | and the contents of an 8-bit register with the contents of an 8-bit memory location or register.
AND reg16, reg/mem16	| 23 /r | and the contents of a 16-bit register with the contents of a 16-bit memory location or register.
AND reg32, reg/mem32	| 23 /r | and the contents of a 32-bit register with the contents of a 32-bit memory location or register.
AND reg64, reg/mem64	| 23 /r | and the contents of a 64-bit register with the contents of a 64-bit memory location or register. )
: andr ( reg )
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x22 ELSE 0x23 THEN ,uint8 drop
  emit-modrm
;

( OR AL, imm8		| 0C ib | or the contents of AL with an immediate 8-bit value.
OR AX, imm16		| 0D iw | or the contents of AX with an immediate 16-bit value.
OR EAX, imm32		| 0D id | or the contents of EAX with an immediate 32-bit value.
OR RAX, imm32		| 0D id | or the contents of RAX with a sign-extended immediate 32-bit value. )

( OR reg/mem8, imm8	| 80 /1 ib | or the contents of an 8-bit register or memory operand and an immediate 8-bit value.
OR reg/mem16, imm16	| 81 /1 iw | or the contents of a 16-bit register or memory operand and an immediate 16-bit value.
OR reg/mem32, imm32	| 81 /1 id | or the contents of a 32-bit register or memory operand and an immediate 32-bit value.
OR reg/mem64, imm32	| 81 /1 id | or the contents of a 64-bit register or memory operand and sign-extended immediate 32-bit value. )
: or#
  1 modrm-reg! emit-80
;

( OR reg/mem16, imm8	| 83 /1 ib | or the contents of a 16-bit register or memory operand and a sign-extended immediate 8-bit value.
OR reg/mem32, imm8	| 83 /1 ib | or the contents of a 32-bit register or memory operand and a sign-extended immediate 8-bit value.
OR reg/mem64, imm8	| 83 /1 ib | or the contents of a 64-bit register or memory operand and a sign-extended immediate 8-bit value. )
: or#i8
  1 modrm-reg! emit-83
;

( OR reg/mem8, reg8	| 08 /r | or the contents of an 8-bit register or memory operand with the contents of an 8-bit register.
OR reg/mem16, reg16	| 09 /r | or the contents of a 16-bit register or memory operand with the contents of a 16-bit register.
OR reg/mem32, reg32	| 09 /r | or the contents of a 32-bit register or memory operand with the contents of a 32-bit register.
OR reg/mem64, reg64	| 09 /r | or the contents of a 64-bit register or memory operand with the contents of a 64-bit register )
: orm
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x08 ELSE 0x09 THEN ,uint8 drop
  emit-modrm
;

( OR reg8, reg/mem8	| 0A /r | or the contents of an 8-bit register with the contents of an 8-bit register or memory operand.
OR reg16, reg/mem16	| 0B /r | or the contents of a 16-bit register with the contents of a 16-bit register or memory operand.
OR reg32, reg/mem32	| 0B /r | or the contents of a 32-bit register with the contents of a 32-bit register or memory operand.
OR reg64, reg/mem64	| 0B /r | or the contents of a 64-bit register with the contents of a 64-bit register or memory operand. )
: orr ( reg )
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x0A ELSE 0x0B THEN ,uint8 drop
  emit-modrm
;

( XOR AL, imm8		| 34 ib | xor the contents of AL with an immediate 8-bit 
operand and store the result in AL.
XOR AX, imm16		| 35 iw | xor the contents of AX with an immediate 16-bit 
operand and store the result in AX.
XOR EAX, imm32		| 35 id | xor the contents of EAX with an immediate 32-bit operand and store the result in EAX.
XOR RAX, imm32		| 35 id | xor the contents of RAX with a sign-extended immediate 32-bit operand and store the result in RAX. )

( XOR reg/mem8, imm8	| 80 /6 ib | xor the contents of an 8-bit destination register or memory operand with an 8-bit immediate value and store the result in the destination.
XOR reg/mem16, imm16	| 81 /6 iw | xor the contents of a 16-bit destination register or memory operand with a 16-bit immediate value and store the result in the destination.
XOR reg/mem32, imm32	| 81 /6 id | xor the contents of a 32-bit destination register or memory operand with a 32-bit immediate value and store the result in the destination.
XOR reg/mem64, imm32	| 81 /6 id | xor the contents of a 64-bit destination register or memory operand with a sign-extended 32-bit immediate value and store the result in the destination. )
: xor#
  6 modrm-reg! emit-80
;

( XOR reg/mem16, imm8	| 83 /6 ib | xor the contents of a 16-bit destination register or memory operand with a sign-extended 8-bit immediate value and store the result in the destination.
XOR reg/mem32, imm8	| 83 /6 ib | xor the contents of a 32-bit destination register or memory operand with a sign-extended 8-bit immediate value and store the result in the destination.
XOR reg/mem64, imm8	| 83 /6 ib | xor the contents of a 64-bit destination register or memory operand with a sign-extended 8-bit immediate value and store the result in the destination. )
: xor#i8
  6 modrm-reg! emit-83
;

( XOR reg/mem8, reg8	| 30 /r | xor the contents of an 8-bit destination register or memory operand with the contents of an 8-bit register and store the result in the destination.
XOR reg/mem16, reg16	| 31 /r | xor the contents of a 16-bit destination register or memory operand with the contents of a 16-bit register and store the result in the destination.
XOR reg/mem32, reg32	| 31 /r | xor the contents of a 32-bit destination register or memory operand with the contents of a 32-bit register and store the result in the destination.
XOR reg/mem64, reg64	| 31 /r | xor the contents of a 64-bit destination register or memory operand with the contents of a 64-bit register and store the result in the destination. )
: xorm
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x30 ELSE 0x31 THEN ,uint8 drop
  emit-modrm
;

( XOR reg8, reg/mem8	| 32 /r | xor the contents of an 8-bit destination register with the contents of an 8-bit register or memory operand and store the results in the destination.
XOR reg16, reg/mem16	| 33 /r | xor the contents of a 16-bit destination register with the contents of a 16-bit register or memory operand and store the results in the destination.
XOR reg32, reg/mem32	| 33 /r | xor the contents of a 32-bit destination register with the contents of a 32-bit register or memory operand and store the results in the destination.
XOR reg64, reg/mem64	| 33 /r | xor the contents of a 64-bit destination register with the contents of a 64-bit register or memory operand and store the results in the destination )
: xorr
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x32 ELSE 0x33 THEN ,uint8 drop
  emit-modrm
;

( Comparisons: )

( CMP AL, imm8		| 3C ib | Compare an 8-bit immediate value with the contents of the AL register.
CMP AX, imm16		| 3D iw | Compare a 16-bit immediate value with the contents of the AX register.
CMP EAX, imm32		| 3D id | Compare a 32-bit immediate value with the contents of the EAX register.
CMP RAX, imm32		| 3D id | Compare a 32-bit immediate value with the contents of the RAX register. )

( CMP reg/mem8, imm8	| 80 /7 ib | Compare an 8-bit immediate value with the contents of an 8-bit register or memory operand.
CMP reg/mem16, imm16	| 81 /7 iw | Compare a 16-bit immediate value with the contents of a 16-bit register or memory operand.
CMP reg/mem32, imm32	| 81 /7 id | Compare a 32-bit immediate value with the contents of a 32-bit register or memory operand.
CMP reg/mem64, imm32	| 81 /7 id | Compare a 32-bit signed immediate value with the contents of a 64-bit register or memory operand. )
: cmp#
  7 modrm-reg! emit-80
;

( CMP reg/mem16, imm8	| 83 /7 ib | Compare an 8-bit signed immediate value with the contents of a 16-bit register or memory operand.
CMP reg/mem32, imm8	| 83 /7 ib | Compare an 8-bit signed immediate value with the contents of a 32-bit register or memory operand.
CMP reg/mem64, imm8	| 83 /7 ib | Compare an 8-bit signed immediate value with the contents of a 64-bit register or memory operand. )
: cmp#i8
  7 modrm-reg! emit-83
;

( CMP reg/mem8, reg8	| 38 /r | Compare the contents of an 8-bit register or memory operand with the contents of an 8-bit register.
CMP reg/mem16, reg16	| 39 /r | Compare the contents of a 16-bit register or memory operand with the contents of a 16-bit register.
CMP reg/mem32, reg32	| 39 /r | Compare the contents of a 32-bit register or memory operand with the contents of a 32-bit register.
CMP reg/mem64, reg64	| 39 /r | Compare the contents of a 64-bit register or memory operand with the contents of a 64-bit register. )
: cmpm
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x38 ELSE 0x39 THEN ,uint8 drop
  emit-modrm
;

( CMP reg8, reg/mem8	| 3A /r | Compare the contents of an 8-bit register with the contents of an 8-bit register or memory operand.
CMP reg16, reg/mem16	| 3B /r | Compare the contents of a 16-bit register with the contents of a 16-bit register or memory operand.
CMP reg32, reg/mem32	| 3B /r | Compare the contents of a 32-bit register with the contents of a 32-bit register or memory operand.
CMP reg64, reg/mem64	| 3B /r | Compare the contents of a 64-bit register with the contents of a 64-bit register or memory operand. )
: cmpr
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x3A ELSE 0x3B THEN ,uint8 drop
  emit-modrm
;

( TEST AL, imm8		| A8 ib | and an immediate 8-bit value with the contents of the AL register and set rFLAGS to reflect the result.
TEST AX, imm16		| A9 iw | and an immediate 16-bit value with the contents of the AX register and set rFLAGS to reflect the result.
TEST EAX, imm32		| A9 id | and an immediate 32-bit value with the contents of the EAX register and set rFLAGS to reflect the result.
TEST RAX, imm32		| A9 id | and a sign-extended immediate 32-bit value with the contents of the RAX register and set rFLAGS to reflect the result. )

( TEST reg/mem8, imm8	| F6 /0 ib | and an immediate 8-bit value with the contents of an 8-bit register or memory operand and set rFLAGS to reflect the result.
TEST reg/mem16, imm16	| F7 /0 iw | and an immediate 16-bit value with the contents of a 16-bit register or memory operand and set rFLAGS to reflect the result.
TEST reg/mem32, imm32	| F7 /0 id | and an immediate 32-bit value with the contents of a 32-bit register or memory operand and set rFLAGS to reflect the result.
TEST reg/mem64, imm32	| F7 /0 id | and a sign-extended immediate32-bit value with the contents of a 64-bit register or memory operand and set rFLAGS to reflect the result. )
: emit-f6
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg8? IF 0xF6 ELSE 0xF7 THEN ,uint8 drop
  emit-modrm
;

: test#
  0 modrm-reg!
  modrm-dest-reg reg8? IF
    drop emit-f6 ,uint8
  ELSE
    drop emit-f6 16bit? IF ,uint16 ELSE ,uint32 THEN
  THEN
;

( TEST reg/mem8, reg8	| 84 /r | and the contents of an 8-bit register with the contents of an 8-bit register or memory operand and set rFLAGS to reflect the result.
TEST reg/mem16, reg16	| 85 /r | and the contents of a 16-bit register with the contents of a 16-bit register or memory operand and set rFLAGS to reflect the result.
TEST reg/mem32, reg32	| 85 /r | and the contents of a 32-bit register with the contents of a 32-bit register or memory operand and set rFLAGS to reflect the result.
TEST reg/mem64, reg64	| 85 /r | and the contents of a 64-bit register with the contents of a 64-bit register or memory operand and set rFLAGS to reflect the result. )
: test
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x84 ELSE 0x85 THEN ,uint8 drop
  emit-modrm
;

( Jumps: )

: jumper ( offset jmp-op -- )
  over 0xFF uint<=
  IF 0x70 + ,uint8 ,uint8
  ELSE
    0x0F ,uint8 0x80 + ,uint8
    16bit? IF ,uint16 ELSE ,uint32 THEN
  THEN
;

( JO rel8off	| 70 cb |
JO rel16off	| 0F 80 cw |
JO rel32off	| 0F 80 cd | Jump if overflow [OF = 1]. )
: j0 0 jumper ;

( JNO rel8off	| 71 cb |
JNO rel16off	| 0F 81 cw |
JNO rel32off	| 0F 81 cd | Jump if not overflow [OF = 0]. )
: jn0 0x1 jumper ;

( JB rel8off	| 72 cb |
JB rel16off	| 0F 82 cw |
JB rel32off	| 0F 82 cd | Jump if below [CF = 1]. )
: jb 0x2 jumper ;

( JC rel8off	| 72 cb |
JC rel16off	| 0F 82 cw |
JC rel32off	| 0F 82 cd | Jump if carry [CF = 1]. )
alias> jc jb

( JNAE rel8off	| 72 cb |
JNAE rel16off	| 0F 82 cw |
JNAE rel32off	| 0F 82 cd | Jump if not above or equal [CF = 1]. )
alias> jnae jb

( JNB rel8off	| 73 cb |
JNB rel16off	| 0F 83 cw |
JNB rel32off	| 0F 83 cd | Jump if not below [CF = 0]. )
: jnb 0x3 jumper ;

( JNC rel8off	| 73 cb |
JNC rel16off	| 0F 83 cw |
JNC rel32off	| 0F 83 cd | Jump if not carry [CF = 0]. )
alias> jnc jnb

( JAE rel8off	| 73 cb |
JAE rel16off	| 0F 83 cw |
JAE rel32off	| 0F 83 cd | Jump if above or equal [CF = 0]. )
alias> jae jnb

( JZ rel8off	| 74 cb |
JZ rel16off	| 0F 84 cw |
JZ rel32off	| 0F 84 cd | Jump if zero [ZF = 1]. )
: jz 0x4 jumper ;

( JE rel8off	| 74 cb |
JE rel16off	| 0F 84 cw |
JE rel32off	| 0F 84 cd | Jump if equal [ZF = 1]. )
alias> je jz

( JNZ rel8off	| 75 cb |
JNZ rel16off	| 0F 85 cw |
JNZ rel32off	| 0F 85 cd | Jump if not zero [ZF = 0]. )
: jnz 0x5 jumper ;

( JNE rel8off	| 75 cb |
JNE rel16off	| 0F 85 cw |
JNE rel32off	| 0F 85 cd | Jump if not equal [ZF = 0]. )
alias> jne jnz

( JBE rel8off	| 76 cb |
JBE rel16off	| 0F 86 cw |
JBE rel32off	| 0F 86 cd | Jump if below or equal [CF = 1 or ZF = 1]. )
: jbe 0x6 jumper ;

( JNA rel8off	| 76 cb |
JNA rel16off	| 0F 86 cw |
JNA rel32off	| 0F 86 cd | Jump if not above [CF = 1 or ZF = 1]. )
alias> jna jbe

( JNBE rel8off	| 77 cb |
JNBE rel16off	| 0F 87 cw |
JNBE rel32off	| 0F 87 cd | Jump if not below or equal [CF = 0 and ZF = 0]. )
: jnbe 0x7 jumper ;

( JA rel8off	| 77 cb |
JA rel16off	| 0F 87 cw |
JA rel32off	| 0F 87 cd | Jump if above [CF = 0 and ZF = 0]. )
alias> ja jnbe

( JS rel8off	| 78 cb |
JS rel16off	| 0F 88 cw |
JS rel32off	| 0F 88 cd | Jump if sign [SF = 1]. )
: js 0x8 jumper ;

( JNS rel8off	| 79 cb |
JNS rel16off	| 0F 89 cw |
JNS rel32off	| 0F 89 cd | Jump if not sign [SF = 0]. )
: jns 0x9 jumper ;

( JP rel8off	| 7A cb |
JP rel16off	| 0F 8A cw |
JP rel32off	| 0F 8A cd | Jump if parity [PF = 1]. )
: jp 0xA jumper ;

( JPE rel8off	| 7A cb |
JPE rel16off	| 0F 8A cw |
JPE rel32off	| 0F 8A cd | Jump if parity even [PF = 1]. )
alias> jpe jp

( JNP rel8off	| 7B cb |
JNP rel16off	| 0F 8B cw |
JNP rel32off	| 0F 8B cd | Jump if not parity [PF = 0]. )
: jnp 0xB jumper ;

( JPO rel8off	| 7B cb |
JPO rel16off	| 0F 8B cw |
JPO rel32off	| 0F 8B cd | Jump if parity odd [PF = 0]. )
alias> jp0 jnp

( JL rel8off	| 7C cb |
JL rel16off	| 0F 8C cw |
JL rel32off	| 0F 8C cd | Jump if less [SF <> OF]. )
: jl 0xC jumper ;

( JNGE rel8off	| 7C cb |
JNGE rel16off	| 0F 8C cw |
JNGE rel32off	| 0F 8C cd | Jump if not greater or equal [SF <> OF]. )
alias> jnge jl

( JNL rel8off	| 7D cb |
JNL rel16off	| 0F 8D cw |
JNL rel32off	| 0F 8D cd | Jump if not less [SF = OF]. )
: jnl 0xD jumper ;

( JGE rel8off	| 7D cb |
JGE rel16off	| 0F 8D cw |
JGE rel32off	| 0F 8D cd | Jump if greater or equal [SF = OF]. )
alias> jge jnl

( JLE rel8off	| 7E cb |
JLE rel16off	| 0F 8E cw |
JLE rel32off	| 0F 8E cd | Jump if less or equal [ZF = 1 or SF <> OF]. )
: jle 0xE jumper ;

( JNG rel8off	| 7E cb |
JNG rel16off	| 0F 8E cw |
JNG rel32off	| 0F 8E cd | Jump if not greater [ZF = 1 or SF <> OF]. )
alias> jng jle

( JNLE rel8off	| 7F cb |
JNLE rel16off	| 0F 8F cw |
JNLE rel32off	| 0F 8F cd | Jump if not less or equal [ZF = 0 and SF = OF]. )
: jnle 0xF jumper ;

( JG rel8off	| 7F cb |
JG rel16off	| 0F 8F cw |
JG rel32off	| 0F 8F cd | Jump if greater [ZF = 0 and SF = OF]. )
alias> jg jnle

( JMP rel8off		| EB cb | Short jump with the target specified by an 8-bit signed displacement.
JMP rel16off		| E9 cw | Near jump with the target specified by a 16-bit signed displacement.
JMP rel32off		| E9 cd | Near jump with the target specified by a 32-bit signed displacement. )
: jmp#
  dup 0xFF uint<= IF
    0xEB ,uint8 ,uint8
  ELSE
    0xE9 ,uint8
    16bit? IF ,uint16 ELSE ,uint32 THEN
  THEN
;

( JMP reg/mem16		| FF /4 | Near jump with the target specified reg/mem16.
JMP reg/mem32		| FF /4 | Near jump with the target specified reg/mem32.
[No prefix for encoding in 64-bit mode.]
JMP reg/mem64		| FF /4 | Near jump with the target specified reg/mem64. )
: jmpr
  4 modrm-reg!
  modrm-dest-reg emit-prefixes
  0xFF ,uint8
  emit-modrm
;

( JMP FAR pntr16:16	| EA cd | Far jump direct, with the target specified by a far pointer contained in the instruction. [Invalid in 64-bit mode.] 
JMP FAR pntr16:32	| EA cp | Far jump direct, with the target specified by a far pointer contained in the instruction. [Invalid in 64-bit mode.] )
: jmp-far
  0xFF ,uint8
  16bit? IF ,uint16 ELSE ,uint32 THEN
;

( JMP FAR mem16:16	| FF /5 | Far jump indirect, with the target specified by a far pointer in memory [16-bit operand size].
JMP FAR mem16:32	| FF /5 | Far jump indirect, with the target specified by a far pointer in memory [32- and 64-bit operand size] )
: jmp-farr
  5 modrm-reg!
  modrm-dest-reg emit-prefixes
  0xFF ,uint8
  emit-modrm
;

( Function calls: )

( Near calls:
CALL rel16off	| E8 iw | Near call with the target specified by a 16-bit relative displacement.
CALL rel32off	| E8 id | Near call with the target specified by a 32-bit relative displacement. )
: call ( addr )
  0xE8 ,uint8
  16bit? IF ,uint16 ELSE ,uint32 THEN
;

( CALL reg/mem16 | FF /2 | Near call with the target specified by reg/mem16.
CALL reg/mem32	 | FF /2 | Near call with the target specified by reg/mem32. There is no prefix for encoding this in 64-bit mode.
CALL reg/mem64	 | FF /2 | Near call with the target specified by reg/mem64.
)
: callm ( modrm )
  2 modrm-reg!
  modrm-dest-reg emit-prefixes 0xFF ,uint8
  emit-modrm
;

( Far calls:
CALL FAR pntr16:16	| 9A cd | Far call direct, with the target specified by a far pointer contained in the instruction. Invalid in 64-bit mode.
CALL FAR pntr16:32	| 9A cp | Far call direct, with the target specified by a far pointer contained in the instruction. Invalid in 64-bit mode. )
: callf ( addr )
  0x9A ,uint8
  16bit? IF ,uint16 ELSE ,uint32 THEN
;

( CALL FAR mem16:16	| FF /3 | Far call indirect, with the target specified by a far pointer in memory.
CALL FAR mem16:32	| FF /3 | Far call indirect, with the target specified by a far pointer in memory.
)
: callfm ( modrm )
  3 modrm-reg!
  modrm-dest-reg emit-prefixes 0xFF ,uint8
  emit-modrm
;

( RET		| C3 | Near return to the calling procedure.
  RET imm16	| C2 iw | Near return to the calling procedure then pop the specified number of bytes from the stack. )
: ret
  0xC3 ,uint8
;

: ret#
  0xC2 ,uint8 ,uint16
;

( RETF		| CB | Far return to the calling procedure.
  RETF imm16	| CA iw | Far return to the calling procedure, then pop the specified number of bytes from the stack.
)
: retf
  0xCB ,uint8
;

: retf# 0xCA ,uint8 ,uint16 ;

( ENTER imm16, 0		| C8 iw 00 | Create a procedure stack frame.
ENTER imm16, 1		| C8 iw 01 | Create a nested stack frame for a procedure.
ENTER imm16, imm8	| C8 iw ib | Create a nested stack frame for a procedure.
)
: enter#
  0xC8 ,uint8 ,uint16 ,uint8
;

: enter0 0 swap enter# ;
: enter1 1 swap enter# ;

( LEAVE | C9 | Set the stack pointer register SP to the value in the BP register and pop BP.
LEAVE	| C9 | Set the stack pointer register ESP to the value in the EBP register and pop EBP. No prefix for encoding this in 64-bit mode.
LEAVE	| C9 | Set the stack pointer register RSP to the value in the RBP register and pop RBP.
)
: leave
  0xC9 ,uint8
;

( INT imm8 | CD ib | Call interrupt service routine specified by interrupt vector imm8. )
: int
  0xCD ,uint8 ,uint8
;

( INTO | CE | Call overflow exception if the overflow flag is set. 
[Invalid in 64-bit mode.] )
: int0
  0xCE ,uint8
;

( Arithmetic: )

( CLC | F8 | Clear the carry flag [CF] to zero. )
: clc
  0xF8 ,uint8
;

( STC | F9 | Set the carry flag [CF] to one. )
: stc
  0xF9 ,uint8
;

( CMC | F5 | Complement the carry flag [CF]. )
: cmc
  0xF5 ,uint8
;

( ADC AL, imm8		| 14 ib		| Add imm8 to AL + CF.
ADC AX, imm16		| 15 iw		| Add imm16 to AX + CF.
ADC EAX, imm32		| 15 id		| Add imm32 to EAX + CF.
ADC RAX, imm32		| 15 id		| Add sign-extended imm32 to RAX + CF. )

( ADC reg/mem8, imm8	| 80 /2 ib	| Add imm8 to reg/mem8 + CF.
ADC reg/mem16, imm16	| 81 /2 iw	| Add imm16 to reg/mem16 + CF.
ADC reg/mem32, imm32	| 81 /2 id	| Add imm32 to reg/mem32 + CF.
ADC reg/mem64, imm32	| 81 /2 id	| Add sign-extended imm32 to reg/mem64 + CF. )
: adc#
  2 modrm-reg! emit-80
;

( ADC reg/mem16, imm8	| 83 /2 ib	| Add sign-extended imm8 to reg/mem16 + CF.
ADC reg/mem32, imm8	| 83 /2 ib	| Add sign-extended imm8 to reg/mem32 + CF.
ADC reg/mem64, imm8	| 83 /2 ib	| Add sign-extended imm8 to reg/mem64 + CF. )
: adc#i8
  2 modrm-reg! emit-83
;

( ADC reg/mem8, reg8	| 10 /r		| Add reg8 to reg/mem8 + CF
ADC reg/mem16, reg16	| 11 /r		| Add reg16 to reg/mem16 + CF.
ADC reg/mem32, reg32	| 11 /r		| Add reg32 to reg/mem32 + CF.
ADC reg/mem64, reg64	| 11 /r		| Add reg64 to reg/mem64 + CF. )
: adcm
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x10 ELSE 0x11 THEN ,uint8 drop
  emit-modrm
;

( ADC reg8, reg/mem8	| 12 /r		| Add reg/mem8 to reg8 + CF.
ADC reg16, reg/mem16	| 13 /r		| Add reg/mem16 to reg16 + CF.
ADC reg32, reg/mem32	| 13 /r		| Add reg/mem32 to reg32 + CF.
ADC reg64, reg/mem64	| 13 /r		| Add reg/mem64 to reg64 + CF. )
: adcr
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x12 ELSE 0x13 THEN ,uint8 drop
  emit-modrm
;

( ADCX reg32, reg/mem32   | 66 0F 38 F6 /r | Unsigned add with carryflag
ADCX reg64, reg/mem64   | 66 0F 38 F6 /r | Unsigned add with carry flag.
)
: adcx
  dup modrm-reg emit-prefixes
  0xF6380F66 ,uint32
  emit-modrm
;

(
ADD AL, imm8		| 04 ib		| Add imm8 to AL.
ADD AX, imm16		| 05 iw		| Add imm16 to AX.
ADD EAX, imm32		| 05 id		| Add imm32 to EAX.
ADD RAX, imm32		| 05 id		| Add sign-extended imm32 to RAX.
)

( ADD reg/mem8, imm8	| 80 /0 ib	| Add imm8 to reg/mem8.
ADD reg/mem16, imm16	| 81 /0 iw	| Add imm16 to reg/mem16
ADD reg/mem32, imm32	| 81 /0 id	| Add imm32 to reg/mem32.
ADD reg/mem64, imm32	| 81 /0 id	| Add sign-extended imm32 to reg/mem64. )
: add# ( number rd )
  0 modrm-reg! emit-80
;

( ADD reg/mem16, imm8	| 83 /0 ib	| Add sign-extended imm8 to reg/mem16
ADD reg/mem32, imm8	| 83 /0 ib	| Add sign-extended imm8 to reg/mem32.
ADD reg/mem64, imm8	| 83 /0 ib	| Add sign-extended imm8 to reg/mem64. )
: add#i8 ( number rd )
  0 modrm-reg! emit-83
;

( ADD reg8, reg/mem8	| 02 /r		| Add reg/mem8 to reg8.
ADD reg16, reg/mem16	| 03 /r		| Add reg/mem16 to reg16.
ADD reg32, reg/mem32	| 03 /r		| Add reg/mem32 to reg32.
ADD reg64, reg/mem64	| 03 /r		| Add reg/mem64 to reg64. )
: addr ( modrm )
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x02 ELSE 0x03 THEN ,uint8 drop
  emit-modrm
;

( ADD reg/mem8, reg8	| 00 /r		| Add reg8 to reg/mem8.
ADD reg/mem16, reg16	| 01 /r		| Add reg16 to reg/mem16.
ADD reg/mem32, reg32	| 01 /r		| Add reg32 to reg/mem32.
ADD reg/mem64, reg64	| 01 /r		| Add reg64 to reg/mem64. )
: addm ( modrm )
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x0 ELSE 0x1 THEN ,uint8 drop
  emit-modrm
;

( INC reg/mem8	| FE /0 | Increment the contents of an 8-bit register or memory location by 1.
INC reg/mem16	| FF /0 | Increment the contents of a 16-bit register or memory location by 1.
INC reg/mem32	| FF /0 | Increment the contents of a 32-bit register or memory location by 1.
INC reg/mem64	| FF /0 | Increment the contents of a 64-bit register or memory location by 1. )
: inc
  0 modrm-reg!
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg8? IF 0xFE ELSE 0xFF THEN ,uint8 drop
  emit-modrm
;

( INC reg16	| 40 +rw | Increment the contents of a 16-bit register by 1.
[These opcodes are used as REX prefixes in 64-bit 
mode. See “REX Prefix” on page 14.]
INC reg32	| 40 +rd | Increment the contents of a 32-bit register by 1.
[These opcodes are used as REX prefixes in 64-bit 
mode. See “REX Prefix” on page 14.] )
: incr
  0x7 logand 0x40 + ,uint8
;

( SUB AL, imm8		| 2C ib | Subtract an immediate 8-bit value from the AL register and store the result in AL.
SUB AX, imm16		| 2D iw | Subtract an immediate 16-bit value from the AX register and store the result in AX.
SUB EAX, imm32		| 2D id | Subtract an immediate 32-bit value from the EAX 
register and store the result in EAX.
SUB RAX, imm32		| 2D id | Subtract a sign-extended immediate 32-bit value from the RAX register and store the result in RAX. )

( SUB reg/mem8, imm8	| 80 /5 ib | Subtract an immediate 8-bit value from an 8-bit destination register or memory location.
SUB reg/mem16, imm16	| 81 /5 iw | Subtract an immediate 16-bit value from a 16-bit destination register or memory location.
SUB reg/mem32, imm32	| 81 /5 id | Subtract an immediate 32-bit value from a 32-bit destination register or memory location.
SUB reg/mem64, imm32	| 81 /5 id | Subtract a sign-extended immediate 32-bit value from a 64-bit destination register or memory location. )
: sub#
  5 modrm-reg! emit-80
;

( SUB reg/mem16, imm8	| 83 /5 ib | Subtract a sign-extended immediate 8-bit value from a 16-bit register or memory location.
SUB reg/mem32, imm8	| 83 /5 ib | Subtract a sign-extended immediate 8-bit value from a 32-bit register or memory location.
SUB reg/mem64, imm8	| 83 /5 ib | Subtract a sign-extended immediate 8-bit value from a 64-bit register or memory location. )
: sub#i8
  5 modrm-reg! emit-83
;

( SUB reg/mem8, reg8	| 28 /r | Subtract the contents of an 8-bit register from an 8-bit destination register or memory location.
SUB reg/mem16, reg16	| 29 /r | Subtract the contents of a 16-bit register from a 16-bit destination register or memory location.
SUB reg/mem32, reg32	| 29 /r | Subtract the contents of a 32-bit register from a 32-bit destination register or memory location.
SUB reg/mem64, reg64	| 29 /r | Subtract the contents of a 64-bit register from a 64-bit destination register or memory location. )
: subm
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x28 ELSE 0x29 THEN ,uint8 drop
  emit-modrm
;

( SUB reg8, reg/mem8	| 2A /r | Subtract the contents of an 8-bit register or memory operand from an 8-bit destination register.
SUB reg16, reg/mem16	| 2B /r | Subtract the contents of a 16-bit register or memory operand from a 16-bit destination register.
SUB reg32, reg/mem32	| 2B /r | Subtract the contents of a 32-bit register or memory operand from a 32-bit destination register.
SUB reg64, reg/mem64	| 2B /r | Subtract the contents of a 64-bit register or memory operand from a 64-bit destination register. )
: subr ( modrm )
  dup modrm-reg emit-prefixes
  dup modrm-reg reg8? IF 0x2A ELSE 0x2B THEN ,uint8 drop
  emit-modrm
;

( DEC reg/mem8	| FE /1 | Decrement the contents of an 8-bit register or memory location by 1.
DEC reg/mem16	| FF /1 | Decrement the contents of a 16-bit register or memory location by 1.
DEC reg/mem32	| FF /1 | Decrement the contents of a 32-bit register or memory location by 1.
DEC reg/mem64	| FF /1 | Decrement the contents of a 64-bit register or memory location by 1. )
: dec
  1 modrm-reg!
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg8? IF 0xFE ELSE 0xFF THEN ,uint8 drop
  emit-modrm
;

( DEC reg16	| 48 +rw | Decrement the contents of a 16-bit register by 1.
[See “REX Prefix” on page 14.]
DEC reg32	| 48 +rd | Decrement the contents of a 32-bit register by 1.
[See “REX Prefix” on page 14.] )
: decr
  0x7 logand 0x48 + ,uint8
;

( DIV reg/mem8	| F6 /6 | Perform unsigned division of AX by the contents of an 8- bit register or memory location and store the quotient in AL and the remainder in AH.
DIV reg/mem16	| F7 /6 | Perform unsigned division of DX:AX by the contents of a 16-bit register or memory operand store the quotient in AX and the remainder in DX.
DIV reg/mem32	| F7 /6 | Perform unsigned division of EDX:EAX by the contents of a 32-bit register or memory location and store the quotient in EAX and the remainder in EDX.
DIV reg/mem64	| F7 /6 | Perform unsigned division of RDX:RAX by the contents of a 64-bit register or memory location and store the quotient in RAX and the remainder in RDX. )
: div ( modrm )
  6 modrm-reg! emit-f6
;

( IDIV reg/mem8 | F6 /7 | Perform signed division of AX by the contents of an 8-bit register or memory location and store the quotient in AL and the remainder in AH.
IDIV reg/mem16	| F7 /7 | Perform signed division of DX:AX by the contents of a 16-bit register or memory location and store the quotient in AX and the remainder in DX.
IDIV reg/mem32	| F7 /7 | Perform signed division of EDX:EAX by the contents of a 32-bit register or memory location and store the quotient in EAX and the remainder in EDX.
IDIV reg/mem64	| F7 /7 | Perform signed division of RDX:RAX by the contents of a 64-bit register or memory location and store the quotient in RAX and the remainder in RDX. )
: idiv
  7 modrm-reg! emit-f6
;

( MUL reg/mem8	| F6 /4 | Multiplies an 8-bit register or memory operand by the contents of the AL register and stores the result in the AX register.
MUL reg/mem16	| F7 /4 | Multiplies a 16-bit register or memory oper
and by the contents of the AX register and stores the result in the DX:AX register.
MUL reg/mem32	| F7 /4 | Multiplies a 32-bit register or memory operand by the contents of the EAX register and stores the result in the EDX:EAX register.
MUL reg/mem64	| F7 /4b | Multiplies a 64-bit register or memory operand by the contents of the RAX register and stores the result in the RDX:RAX register. )
: mul ( modrm )
  4 modrm-reg! emit-f6
;

( MULX reg32, reg32, reg/mem32 C4 RXB.02 0.dest2.0.11	| F6 /r |
MULX reg64, reg64, reg/mem64 C4 RXB.02 1.dest2.0.11	| F6 /r | )
: mulx
  dup modrm-reg emit-prefixes
  0xF6 ,uint8
  emit-modrm
;

( IMUL reg/mem8			| F6 /5 | Multiply the contents of AL by the contents of an 8-bit memory or register operand and put the signed result in AX.
IMUL reg/mem16			| F7 /5 | Multiply the contents of AX by the contents of a 16-bit memory or register operand and put the signed result in DX:AX.
IMUL reg/mem32			| F7 /5 | Multiply the contents of EAX by the contents of a 32-bit memory or register operand and put the signed result in EDX:EAX.
IMUL reg/mem64			| F7 /5 | Multiply the contents of RAX by the contents of a 64-bit memory or register operand and put the signed result in RDX:RAX. )
: imul ( modrm )
  5 modrm-reg! emit-f6
;

( IMUL reg16, reg/mem16		| 0F AF /r | Multiply the contents of a 16-bit destination register by the contents of a 16-bit register or memory operand and put the signed result in the 16-bit destination register.
IMUL reg32, reg/mem32		| 0F AF /r | Multiply the contents of a 32-bit destination register by the contents of a 32-bit register or memory operand and put the signed result in the 32-bit destination register.
IMUL reg64, reg/mem64		| 0F AF /r | Multiply the contents of a 64-bit destination register by the contents of a 64-bit register or memory operand and put the signed result in the 64-bit destination register. )
: imulr ( modrm )
  dup modrm-reg emit-prefixes
  0x0F ,uint8 0xAF ,uint8
  emit-modrm
;

( IMUL reg16, reg/mem16, imm8	| 6B /r ib | Multiply the contents of a 16-bit register or memory operand by a sign-extended immediate byte and put the signed result in the 16-bit destination register.
IMUL reg32, reg/mem32, imm8	| 6B /r ib | Multiply the contents of a 32-bit register or memory operand by a sign-extended immediate byte and put the signed result in the 32-bit destination register.
IMUL reg64, reg/mem64, imm8	| 6B /r ib | Multiply the contents of a 64-bit register or memory operand by a sign-extended immediate byte and put the signed result in the 64-bit destination register. )
: imul#i8
  dup modrm-reg emit-prefixes
  0x6B ,uint8
  emit-modrm
  ,uint8
;

( IMUL reg16, reg/mem16, imm16	| 69 /r iw | Multiply the contents of a 16-bit register or memory operand by a sign-extended immediate word and put the signed result in the 16-bit destination register.
IMUL reg32, reg/mem32, imm32	| 69 /r id | Multiply the contents of a 32-bit register or memory operand by a sign-extended immediate double and put the signed result in the 32-bit destination register.
IMUL reg64, reg/mem64, imm32	| 69 /r id | Multiply the contents of a 64-bit register or memory operand by a sign-extended immediate double and put the signed result in the 64-bit destination register. )
: imul#
  dup modrm-reg emit-prefixes
  0x69 ,uint8
  dup modrm-reg reg16? IF
    drop emit-modrm ,uint16
  ELSE
    drop emit-modrm ,uint32
  THEN
;

( Floating point:
  See 26569.pdf: AMD64 Architecture Programmer’s Manual Volume 5
)

( FINIT | 9B DB E3 | Perform a WAIT [9B] to check for pending floating-point exceptions and then initialize the x87 unit.
FNINIT	| DB E3 | Initialize the x87 unit without checking for unmasked floating-point exceptions. )
: finit
  0x98 ,uint8 0xDB ,uint8 0xE3 ,uint8
;

: fninit
  0xDB ,uint8 0xE3 ,uint8
;

( FSAVE mem94/108env	| 9B DD /6 | Copy the x87 state to mem94/108env after checking for pending floating-point exceptions, then reinitialize the x87 state.
FNSAVE mem94/108env	| DD /6 | Copy the x87 state to mem94/108env without checking for pending floating-point exceptions, then reinitialize the x87 state. )
: fsave
  6 modrm-reg!
  modrm-dest-reg emit-prefixes
  0x98 ,uint8 0xDD ,uint8
  emit-modrm
;

: fnsave
  6 modrm-reg!
  modrm-dest-reg emit-prefixes
  0xDD ,uint8
  emit-modrm
;

( FRSTOR mem94/108env | DD /4 | Load the x87 state from mem94/108env. )
: frstor
  4 modrm-reg!
  modrm-dest-reg emit-prefixes
  0xDD ,uint8
  emit-modrm
;

( FABS | D9 E1 | Replace ST[0] with its absolute value. )
: fabs
  0xD9 ,uint8 0xE1 ,uint8
;

( FCOM			| D8 D1 | Compare the contents of ST[0] to the contents of ST[1] and set condition flags to reflect the results of the comparison.
FCOM ST[i]		| D8 D0+i | Compare the contents of ST[0] to the contents of ST[i] and set condition flags to reflect the results of the comparison.
FCOM mem32real		| D8 /2 | Compare the contents of ST[0] to the contents of mem32real and set condition flags to reflect the results of the comparison.
FCOM mem64real		| DC /2 | Compare the contents of ST[0] to the contents of mem64real and set condition flags to reflect the results of the comparison.
FCOMP			| D8 D9 | Compare the contents of ST[0] to the contents of ST[1], set condition flags to reflect the results of the comparison, and pop the x87 register stack.
FCOMP ST[i]		| D8 D8+i | Compare the contents of ST[0] to the contents of ST[i], set condition flags to reflect the results of the comparison, and pop the x87 register stack.
FCOMP mem32real		| D8 /3 | Compare the contents of ST[0] to the contents of mem32real, set condition flags to reflect the results of the comparison, and pop the x87 register stack.
FCOMP mem64real		| DC /3 | Compare the contents of ST[0] to the contents of mem64real, set condition flags to reflect the results of the comparison, and pop the x87 register stack.
FCOMPP			| DE D9 | Compare the contents of ST[0] to the contents of ST[1], set condition flags to reflect the results of the comparison, and pop the x87 register stack twice. )

( FCOMI ST[0],ST[i]	| DB F0+i | Compare the contents of ST[0] with the contents of ST[i] and set status flags to reflect the results of the comparison.
FCOMIP ST[0],ST[i]	| DF F0+i | Compare the contents of ST[0] with the contents of ST[i], set status flags to reflect the results of the comparison, and pop the x87 register stack. )
: fcomi
;

( FILD mem16int | DF /0 | Push the contents of mem16int onto the x87 register stack.
FILD mem32int	| DB /0 | Push the contents of mem32int onto the x87 register stack.
FILD mem64int	| DF /5 | Push the contents of mem64int onto the x87 register stack. )
: fild ( modrm )
  modrm-dest-reg reg64? IF 5 ELSE 0 THEN modrm-reg!
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg32? IF 0xDB ELSE 0xDF THEN ,uint8 drop
  emit-modrm
;

( FIST mem16int | DF /2 | Convert the contents of ST[0] to integer and store the result in mem16int.
FIST mem32int	| DB /2 | Convert the contents of ST[0] to integer and store the result in mem32int. )
: fist ( sp-offset )
  2 modrm-reg!
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg16? IF 0xDF ELSE 0xDB THEN ,uint8 drop
  emit-modrm
;

( FISTP mem16int	| DF /3 | Convert the contents of ST[0] to integer, store the result in mem16int, and pop the x87 register stack.
FISTP mem32int	| DB /3 | Convert the contents of ST[0] to integer, store the result in mem32int, and pop the x87 register stack.
FISTP mem64int	| DF /7 | Convert the contents of ST[0] to integer, store the result in mem64int, and pop the x87 register stack. )
: fistp
;

( FISTTP mem16int	| DF /1 | Store the truncated floating-point value in ST[0] in memory location mem16int and pop the floating-point register stack.
FISTTP mem32int		| DB /1 | Store the truncated floating-point value in ST[0] in memory location mem32int and pop the floating-point register stack.
FISTTP mem64int		| DD /1 | Store the truncated floating-point value in ST[0] in memory location mem64int and pop the floating-point register stack. )
: fisttp
  1 modrm-reg!
  modrm-dest-reg emit-prefixes
  modrm-dest-reg reg16? IF
    0xDF
  ELSE reg32? IF 0xDB ELSE 0xDD THEN
  THEN ,uint8 drop
  emit-modrm
;

( FLD ST[i]	| D9 C0+i | Push the contents of ST[i] onto the x87 register stack.
FLD mem32real	| D9 /0 | Push the contents of mem32real onto the x87 register stack.
FLD mem64real	| DD /0 | Push the contents of mem64real onto the x87 register stack.
FLD mem80real	| DB /5 | Push the contents of mem80real onto the x87 register stack. )
: fld ( sp-offset )
;

( FST ST[i]	| DD D0+i | Copy the contents of ST[0] to ST[i].
FST mem32real	| D9 /2 | Copy the contents of ST[0] to mem32real.
FST mem64real	| DD /2 | Copy the contents of ST[0] to mem64real.
FSTP ST[i]	| DD D8+i | Copy the contents of ST[0] to ST[i] and pop the x87 register stack.
FSTP mem32real	| D9 /3 | Copy the contents of ST[0] to mem32real and pop the x87 register stack
FSTP mem64real	| DD /3 | Copy the contents of ST[0] to mem64real and pop the x87 register stack.
FSTP mem80real	| DB /7 | Copy the contents of ST[0] to mem80real and pop the x87 register stack. )
: fst ( sp-offset )
;

: fstp ( fpu-reg )
;

( FXCH		| D9 C9 | Exchange the contents of ST[0] and ST[1].
FXCH ST[i]	| D9 C8+i | Exchange the contents of ST[0] and ST[i]. )
: fxch
  0xD9 ,uint8
  0xF logand 0xC8 + ,uint8
;

( FXTRACT | D9 F4 | Extract the exponent and significand of ST[0], store the exponent in ST[0], and push the significand onto the x87 register stack. )
: fxtract
  0xD9 ,uint8 0xF4 ,uint8
;

( FADD ST[0],ST[i]	| D8 C0+i | Replace ST[0] with ST[0] + ST[i].
FADD ST[i],ST[0]	| DC C0+i | Replace ST[i] with ST[0] + ST[i].
FADD mem32real		| D8 /0 | Replace ST[0] with ST[0] + mem32real.
FADD mem64real		| DC /0 | Replace ST[0] with ST[0] + mem64real.
FADDP			| DE C1 | Replace ST[1] with ST[0] + ST[1], and pop the x87 register stack.
FADDP ST[i],ST[0]	| DE C0+i | Replace ST[i] with ST[0] + ST[i], and pop the x87 register stack.
FIADD mem16int		| DE /0 | Replace ST[0] with ST[0] + mem16int.
FIADD mem32int		| DA /0 | Replace ST[0] with ST[0] + mem32int. )
: fadd
;

( FCHS | D9 E0 | Reverse the sign bit of ST[0]. )
: fchs
  0xD9 ,uint8 0xE0 ,uint8
;

( FCLEX | 9B DB E2 | Perform a WAIT [9B] to check for pending floating-point exceptions, and then clear the floating-point exception flags. )
: fclex
  0x9B ,uint8 0xDB ,uint8 0xE2 ,uint8
;

( FNCLEX | DB E2 | Clear the floating-point flags without checking for pending unmasked floating-point exception )
: fnclex
  0xDB ,uint8 0xE2 ,uint8
;

( FNOP | D9 D0 | Perform no operation. )
: fnop
  0xD9 ,uint8 0xD0 ,uint8
;

( FWAIT | 9B | Check for any pending floating-point exceptions. )
: fwait
  0x9B ,uint8
;

( FTST | D9 E4 | Compare ST[0] to 0.0. )
: ftst
  0xD9 ,uint8 0xE4 ,uint8
;

( FXAM | D9 E5 | Characterize the number in the ST[0] register. )
: fxam
  0xD9 ,uint8 0xE5 ,uint8
;

( FDIV ST[0],ST[i]	| D8 F0+i | Replace ST[0] with ST[0]/ST[i].
FDIV ST[i],ST[0]	| DC F8+i | Replace ST[i] with ST[i]/ST[0].
FDIV mem32real		| D8 /6 | Replace ST[0] with ST[0]/mem32real.
FDIV mem64real		| DC /6 | Replace ST[0] with ST[0]/mem64real.
FDIVP			| DE F9 | Replace ST[1] with ST[1]/ST[0], and pop the x87 register stack.
FDIVP ST[i],ST[0]	| DE F8+i | Replace ST[i] with ST[i]/ST[0], and pop the x87 register stack.
FIDIV mem16int		| DE /6 | Replace ST[0] with ST[0]/mem16int.
FIDIV mem32int		| DA /6 | Replace ST[0] with ST[0]/mem32int. )
: fdiv
;

( FMUL ST[0],ST[i]	| D8 C8+i | Replace ST[0] with ST[0] ∗ ST[i].
FMUL ST[i],ST[0]	| DC C8+i | Replace ST[i] with ST[0] ∗ ST[i].
FMUL mem32real		| D8 /1 | Replace ST[0] with mem32real ∗ ST[0].
FMUL mem64real		| DC /1 | Replace ST[0] with mem64real ∗ ST[0].
FMULP			| DE C9 | Replace ST[1] with ST[0] ∗ ST[1], and pop the x87 register stack.
FMULP ST[i],ST[0]	| DE C8+i | Replace ST[i] with ST[0] ∗ ST[i], and pop the x87 register stack.
FIMUL mem16int		| DE /1 | Replace ST[0] with mem16int ∗ ST[0].
FIMUL mem32int		| DA /1 | Replace ST[0] with mem32int ∗ ST[0]. )
: fmul
;

( FSUB ST[0],ST[i]	| D8 E0+i | Replace ST[0] with ST[0] – ST[i].
FSUB ST[i],ST[0]	| DC E8+i | Replace ST[i] with ST[i] – ST[0].
FSUB mem32real		| D8 /4 | Replace ST[0] with ST[0] – mem32real.
FSUB mem64real		| DC /4 | Replace ST[0] with ST[0] – mem64real.
FSUBP			| DE E9 | Replace ST[1] with ST[1] – ST[0] and pop the x87 register stack.
FSUBP ST[i],ST[0]	| DE E8+i | Replace ST[i] with ST[i] – ST[0], and pop the x87 register stack.
FISUB mem16int		| DE /4 | Replace ST[0] with ST[0] – mem16int.
FISUB mem32int		| DA /4 | Replace ST[0] with ST[0] – mem32int. )
: fsub
;

( FYL2X | D9 F1 | Replace ST[1] with ST[1] ∗ log2[ST[0]], then pop the x87 register stack. )
: fyl2x
  0xD9 ,uint8 0xF1 ,uint8
;

( FRNDINT | D9 FC | Round the contents of ST[0] to an integer. )
: frndint
  0xD9 ,uint8 0xFC ,uint8
;

( FSCALE | D9 FD | Replace ST[0] with ST[0] ∗ 2^rndint[ST[1]] )
: fscale
  0xD9 ,uint8 0xFD ,uint8
;

( FCOS | D9 FF | Replace ST[0] with the cosine of ST[0]. )
: fcos
  0xD9 ,uint8 0xFF ,uint8
;

( FSIN | D9 FE | Replace ST[0] with the sine of ST[0]. )
: fsin
  0xD9 ,uint8 0xFE ,uint8
;

( FSINCOS | D9 FB | Replace ST[0] with the sine of ST[0], then push the cosine of ST[0] onto the x87 register stack. )
: fsincos
  0xD9 ,uint8 0xFB ,uint8
;

( FSQRT | D9 FA | Replace ST[0] with the square root of ST[0]. )
: fsqrt
  0xD9 ,uint8 0xFA ,uint8
;

( System instructions: )

( CPUID | 0F A2 | Returns information about the processor and its capabilities. EAX specifies the function number, and the data is returned in EAX, EBX, ECX, EDX. )
: cpuid
  0x0F ,uint8 0xA2 ,uint8
;

: wait
  0x9B
;

( CLI | FA | Clear the interrupt flag [IF] to zero. )
: cli
  0xFA ,uint8
;

( HLT | F4 | Halt instruction execution. )
: halt
  0xF4 ,uint8
;

( INT 3 | CC | Trap to debugger at Interrupt 3. )
: int3
  0xCC ,uint8
;

( INVD | 0F 08 | Invalidate internal caches and trigger external cache invalidations. )
: invd
  0x0F ,uint8 0x08 ,uint8
;

( IRET | CF | Return from interrupt [16-bit operand size].
IRETD | CF | Return from interrupt [32-bit operand size].
IRETQ | CF | Return from interrupt [64-bit operand size]. )
: iret
  0xCF ,uint8
;

( LGDT mem16:32 | 0F 01 /2 | Loads mem16:32 into the global descriptor table register.
LGDT mem16:64	| 0F 01 /2 | Loads mem16:64 into the global descriptor table register. )
: lgtd
  2 modrm-reg!
  modrm-dest-reg emit-prefixes
  0x0F ,uint8 0x01 ,uint8
  emit-modrm
;

( LIDT mem16:32 | 0F 01 /3 | Loads mem16:32 into the interrupt descriptor table register.
LIDT mem16:64	| 0F 01 /3 | Loads mem16:64 into the interrupt descriptor table register. )
: lidt
  3 modrm-reg!
  modrm-dest-reg emit-prefixes
  0x0F ,uint8 0x01 ,uint8
  emit-modrm
;

( LLDT reg/mem16 | 0F 00 /2 | Load the 16-bit segment selector into the local descriptor table register and load the LDT descriptor from the GDT. )
: lldt
  2 modrm-reg!
  modrm-dest-reg emit-prefixes
  0x0F ,uint8 0x00 ,uint8
  emit-modrm
;

( MOV CRn, reg32	| 0F 22 /r | Move the contents of a 32-bit register to CRn
MOV CRn, reg64		| 0F 22 /r | Move the contents of a 64-bit register to CRn
MOV reg32, CRn		| 0F 20 /r | Move the contents of CRn to a 32-bit register.
MOV reg64, CRn		| 0F 20 /r | Move the contents of CRn to a 64-bit register.
MOV CR8, reg32		| F0 0F 22 /r | Move the contents of a 32-bit register to CR8.
MOV CR8, reg64		| F0 0F 22 /r | Move the contents of a 64-bit register to CR8.
MOV reg32, CR8		| F0 0F 20 /r | Move the contents of CR8 into a 32-bit register. )

: movcr
;

( MOV reg32, DRn	| 0F 21 /r | Move the contents of DRn to a 32-bit register.
MOV reg64, DRn		| 0F 21 /r | Move the contents of DRn to a 64-bit register.
MOV DRn, reg32		| 0F 23 /r | Move the contents of a 32-bit register to DRn.
MOV DRn, reg64		| 0F 23 /r | Move the contents of a 64-bit register to DRn. )
: movdr
;

( SGDT mem16:32 | 0F 01 /0 | Store global descriptor table register to memory.
SGDT mem16:64	| 0F 01 /0 | Store global descriptor table register to memory. )
: sgdt
  0 modrm-reg!
  modrm-dest-reg emit-prefixes
  0x0F ,uint8 0x01 ,uint8
  emit-modrm
;

( SIDT mem16:32 | 0F 01 /1 | Store interrupt descriptor table register to memory.
SIDT mem16:64	| 0F 01 /1 | Store interrupt descriptor table register to memory. )
: sidt
  1 modrm-reg!
  modrm-dest-reg emit-prefixes
  0x0F ,uint8 0x01 ,uint8
  emit-modrm
;

( SLDT reg16	| 0F 00 /0 | Store the segment selector from the local descriptor table register to a 16-bit register.
SLDT reg32	| 0F 00 /0 | Store the segment selector from the local descriptor table register to a 32-bit register.
SLDT reg64	| 0F 00 /0 | Store the segment selector from the local descriptor table register to a 64-bit register.
SLDT mem16	| 0F 00 /0 | Store the segment selector from the local descriptor table register to a 16-bit memory location. )
: sldt
  0 modrm-reg!
  modrm-dest-reg emit-prefixes
  0x0F ,uint8 0x00 ,uint8
  emit-modrm
;

( SMSW reg16	| 0F 01 /4 | Store the low 16 bits of CR0 to a 16-bit register.
SMSW reg32	| 0F 01 /4 | Store the low 32 bits of CR0 to a 32-bit register.
SMSW reg64	| 0F 01 /4 | Store the entire 64-bit CR0 to a 64-bit register.
SMSW mem16	| 0F 01 /4 | Store the low 16 bits of CR0 to memory. )
: smsw
  4 modrm-reg!
  modrm-dest-reg emit-prefixes
  0x0F ,uint8 0x01 ,uint8
  emit-modrm
;

( STI | FB | Set interrupt flag [IF] to 1. )
: sti
  0xFB ,uint8
;

( STGI | 0F 01 DC | Sets the global interrupt flag [GIF]. )
: stgi
  0x0F ,uint8 0x01 ,uint8 0xDC ,uint8
;

( SYSCALL | 0F 05 | Call operating system. )
: syscall
  0x0F ,uint8 0x05 ,uint8
;

( SYSENTER | 0F 34 | Call operating system. )
: sysenter
  0x0F ,uint8 0x34 ,uint8  
;

( SYSEXIT | 0F 35 | Return from operating system to application. )
: sysexit
  0x0F ,uint8 0x35 ,uint8
;

( SYSRET | 0F 07 | Return from operating system. )
: sysret
  0x0F ,uint8 0x07 ,uint8
;
