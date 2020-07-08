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
0x5400486 ,uint32
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
swap dup 0x80000 + ,uint32
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

: write-elf32-abi-tag-section-header
( ' name uint32 field )
23 ,uint32
( ' type uint32 field )
7 ,uint32
( ' flags uint32 field )
0 ,uint32
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
4 ,uint32
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
  literal " " ,byte-string
  literal " .text" ,byte-string
  literal " .data" ,byte-string
  literal " .shstrtab" ,byte-string
  literal " .note.ABI-tag" ,byte-string
;

: write-elf32-code
  1 r7 mov# ,uint16
  13 r0 mov# ,uint16
  0 swi ,uint16
  0 swi ,uint16
;

: write-elf32-abi-tag
  4 ,uint32 ( name )
  16 ,uint32 ( desc )
  1 ,uint32 ( type )
  "GNU" ,byte-string
  0 ,uint32 ( OS )
  4 ,uint32 ( major )
  20 ,uint32 ( minor)
  0 ,uint32 ( revision )
;
  
: rewrite-elf32-header ( entry section-headers program-headers )
  32 uint32!
  28 uint32!
  24 uint32!
;

: write-elf32-ending ( code-start entry )
  dhere write-elf32-string-section

  0x10 pad-data
  dhere
  0 over write-elf32-program-code-header
  
  dhere
  write-elf32-zero-section-header
  5 overn 3 overn over - write-elf32-code-section-header
  3 overn 3 overn over - write-elf32-string-section-header

  ( needs entry + 1, section header, and program header offsets )
  4 overn 0x80000 +
  rot swap rewrite-elf32-header
;

