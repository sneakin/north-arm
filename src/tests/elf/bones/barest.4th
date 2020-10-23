src/bash/compiler.4th load
src/lib/stack.4th load
src/lib/byte-data.4th load
src/lib/asm/arm.4th load

: page-align
  4096 + 4096 / 4096 mult
;

: write-elf32-header
( ' id uint8 16 array-field )
( EI_MAG0 0 File identification )
0x7f ,uint8
( EI_MAG1 1 File identification )
0x45 ,uint8
( EI_MAG2 2 File identification )
0x4c ,uint8
( EI_MAG3 3 File identification )
0x46 ,uint8
( EI_CLASS 4 File class )
1 ,uint8
( EI_DATA 5 Data encoding )
1 ,uint8
( EI_VERSION 6 File version )
1 ,uint8
( EI_PAD 7 Start of padding bytes )
0 ,uint8
0 ,uint8
0 ,uint8
0 ,uint8
0 ,uint8
0 ,uint8
0 ,uint8
0 ,uint8
0 ,uint8
( ' type uint16 field )
2 ,uint16
( ' machine uint16 field )
40 ,uint16
( ' version uint32 field )
1 ,uint32
( ' entry uint32 field )
0 ,uint32
( ' phoff uint32 field )
0 ,uint32
( ' shoff uint32 field )
0 ,uint32
( ' flags uint32 field )
0x5400482 ,uint32
( ' ehsize uint16 field )
52 ,uint16
( ' phentsize uint16 field )
32 ,uint16
( ' phentnum uint16 field )
1 ,uint16
( ' shentsize uint16 field )
40 ,uint16
( ' shentnum uint16 field )
3 ,uint16
( ' shstrindx uint16 field )
2 ,uint16
;

: write-elf32-program-code-header
( ' type uint32 field )
1 ,uint32
( ' offset uint32 field )
swap ,uint32
( ' vaddr uint32 field )
0x80000 ,uint32
( ' paddr uint32 field )
0x80000 ,uint32
( ' filesz uint32 field )
dup ,uint32
( ' memsz uint32 field )
,uint32
( ' flags uint32 field )
5 ,uint32
( ' align uint32 field )
0x10000 ,uint32
;

: write-elf32-code-section-header
( ' name uint32 field )
1 ,uint32
( ' type uint32 field )
1 ,uint32
( ' flags uint32 field )
6 ,uint32
( ' addr uint32 field )
swap dup ,uint32
( ' offset uint32 field )
,uint32
( ' size uint32 field )
,uint32
( ' link uint32 field )
0 ,uint32
( ' info uint32 field )
0 ,uint32
( ' addralign uint32 field )
4096 ,uint32
( ' entsize uint32 field )
0 ,uint32
;

: write-elf32-string-section-header
( ' name uint32 field )
13 ,uint32
( ' type uint32 field )
3 ,uint32
( ' flags uint32 field )
0x20 ,uint32
( ' addr uint32 field )
0 ,uint32
( ' offset uint32 field )
swap ,uint32
( ' size uint32 field )
,uint32
( ' link uint32 field )
0 ,uint32
( ' info uint32 field )
0 ,uint32
( ' addralign uint32 field )
4096 ,uint32
( ' entsize uint32 field )
0 ,uint32
;

: write-elf32-zero-section-header
( ' name uint32 field )
0 ,uint32
( ' type uint32 field )
0 ,uint32
( ' flags uint32 field )
0 ,uint32
( ' addr uint32 field )
0 ,uint32
( ' offset uint32 field )
0 ,uint32
( ' size uint32 field )
0 ,uint32
( ' link uint32 field )
0 ,uint32
( ' info uint32 field )
0 ,uint32
( ' addralign uint32 field )
4096 ,uint32
( ' entsize uint32 field )
0 ,uint32
;

: write-elf32-string-section
  " " ,byte-string
  " .text" ,byte-string
  " .data" ,byte-string
  " .shstrtab" ,byte-string
;

: write-elf32-code
  ( 0x900001 )
  ( 0x90 16 a.shifti r7 mov ,uint32
  1 a# r7 r7 add ,uint32 )
  1 a# r7 mov ,uint32
  13 a# r0 mov ,uint32
  svc ,uint32
  svc ,uint32
;

: rewrite-elf32-header ( entry section-headers program-headers )
  32 uint32!
  28 uint32!
  24 uint32!
;

: write-elf32
  write-elf32-header

  0x10 pad-data
  dhere .s write-elf32-code
  dhere .s write-elf32-string-section

  0x10 pad-data
  dhere .s
  0 over write-elf32-program-code-header

  dhere
  write-elf32-zero-section-header
  4 overn 4 overn over - write-elf32-code-section-header
  3 overn 3 overn over - write-elf32-string-section-header

  ( needs entry point, section header, and program headers offsets )
  4 overn 0x80000 +
  rot swap rewrite-elf32-header

  dhere .s drop
;

write-elf32
0 ddump-binary-bytes
