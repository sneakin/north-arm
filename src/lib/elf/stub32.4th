( ~readelf~ can't be believed. Real mapping will have data located at: data - elf_cs + real_cs. The values in the file get offset randomly.

Auxvec #3 gives the program headers and #9 gives the entry point.
)

0x80000 const> elf32-code-segment
0x100000 const> elf32-data-segment
0x2000 const> elf32-data-segment-size
52 const> elf32-header-size

: elf32-data-segment-offset elf32-data-segment elf32-code-segment - ;

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
target-aarch32? target-thumb? or IF 40 ELSE target-x86? IF 3 ELSE 0 THEN THEN ,uint16
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
elf32-header-size ,uint16
( ' phentsize uint16 field )
32 ,uint16
( ' phentnum uint16 field )
2 ,uint16
( ' shentsize uint16 field )
40 ,uint16
( ' shentnum uint16 field )
4 ,uint16
( ' shstrindx uint16 field )
3 ,uint16
;

: write-elf32-code-program-header
( ' type uint32 field )
1 ,uint32
( ' offset uint32 field )
swap ,uint32
( ' vaddr uint32 field )
elf32-code-segment ,uint32
( ' paddr uint32 field )
elf32-code-segment ,uint32
( ' filesz uint32 field )
dup ,uint32
( ' memsz uint32 field )
,uint32
( ' flags uint32 field )
7 ,uint32
( ' align uint32 field )
4096 ,uint32
;

: write-elf32-data-program-header/4
( ' type uint32 field )
1 ,uint32
( ' offset uint32 field )
4 overn to-out-addr ,uint32
( ' vaddr uint32 field )
2 overn ,uint32
( ' paddr uint32 field )
2 overn ,uint32
( ' filesz uint32 field )
3 overn ,uint32
( ' memsz uint32 field )
dup ,uint32
( ' flags uint32 field )
6 ,uint32
( ' align uint32 field )
4096 ,uint32
4 dropn
;

: write-elf32-data-program-header
  2 overn write-elf32-data-program-header/4
;

: write-elf32-code-section-header
( ' name uint32 field )
1 ,uint32
( ' type uint32 field )
1 ,uint32
( ' flags uint32 field )
7 ,uint32
( ' addr uint32 field )
swap to-out-addr dup elf32-code-segment + ,uint32
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
swap to-out-addr ,uint32
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

: write-elf32-data-section-header
( ' name uint32 field )
7 ,uint32
( ' type uint32 field )
1 ,uint32
( ' flags uint32 field )
3 ,uint32
( ' addr uint32 field )
,uint32
( ' offset uint32 field )
swap to-out-addr ,uint32
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
swap to-out-addr ,uint32
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
  " .note.ABI-tag" ,byte-string
;

: write-elf32-abi-tag
  4 ,uint32 ( name )
  16 ,uint32 ( desc )
  1 ,uint32 ( type )
  " GNU" ,byte-string
  0 ,uint32 ( OS )
  4 ,uint32 ( major )
  20 ,uint32 ( minor)
  0 ,uint32 ( revision )
;
  
: rewrite-elf32-header ( entry section-headers program-headers )
  to-out-addr 32 from-out-addr uint32!
  to-out-addr 28 from-out-addr uint32!
  24 from-out-addr uint32!
;

: write-elf32-ending ( data-start code-start entry ++  )
  dhere write-elf32-string-section

  0x10 pad-data
  dhere
  ( commented code cuts .text at the start of .data )
  0 ( 3 overn 6 overn - elf32-header-size + ) over to-out-addr write-elf32-code-program-header
  5 overn 3 overn over - elf32-data-segment elf32-data-segment-size write-elf32-data-program-header/4 ( todo .tdata? )
  
  dhere
  write-elf32-zero-section-header
  5 overn 7 overn over - write-elf32-code-section-header
  6 overn 4 overn over - elf32-data-segment write-elf32-data-section-header
  3 overn 3 overn over - write-elf32-string-section-header

  ( needs entry + 1, section header, and program header offsets )
  4 overn elf32-code-segment +
  shift rewrite-elf32-header
;
