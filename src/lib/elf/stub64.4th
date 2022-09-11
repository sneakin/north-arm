0x80000 const> elf64-code-segment
0xA0000 const> elf64-data-segment
0x2000 const> elf64-data-segment-size
64 const> elf64-header-size

: elf64-data-segment-offset elf64-data-segment elf64-code-segment - ;

: write-elf64-header
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
2 ,uint8
( EI_DATA 5 Data encoding )
1 ,uint8
( EI_VERSION 6 File version )
1 ,uint8
( EI_PAD 7 Start of padding bytes )
3 ,uint8 ( os abi )
1 ,uint8 ( abi version )
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
183 ,uint16
( ' version uint32 field )
1 ,uint32
( ' entry uint64 field )
0 ,uint64
( ' phoff uint64 field )
0 ,uint64
( ' shoff uint64 field )
0 ,uint64
( ' flags uint32 field )
0x5400486 ,uint32
( ' ehsize uint16 field )
elf64-header-size ,uint16
( ' phentsize uint16 field )
56 ,uint16
( ' phentnum uint16 field )
2 ,uint16
( ' shentsize uint16 field )
64 ,uint16
( ' shentnum uint16 field )
4 ,uint16
( ' shstrindx uint16 field )
2 ,uint16
;

: write-elf64-code-program-header
( ' type uint32 field )
1 ,uint32
( ' flags uint32 field )
7 ,uint32
( ' offset uint64 field )
swap ,uint64
( ' vaddr uint64 field )
elf64-code-segment ,uint64
( ' paddr uint64 field )
elf64-code-segment ,uint64
( ' filesz uint64 field )
dup ,uint64
( ' memsz uint64 field )
,uint64
( ' align uint64 field )
0x1000 ,uint64
;

: write-elf64-data-program-header/4
( ' type uint32 field )
1 ,uint32
( ' flags uint32 field )
6 ,uint32
( ' offset uint64 field )
4 overn to-out-addr ,uint64
( ' vaddr uint64 field )
2 overn ,uint64
( ' paddr uint64 field )
2 overn ,uint64
( ' filesz uint64 field )
3 overn ,uint64
( ' memsz uint64 field )
dup ,uint64
( ' align uint64 field )
0x1000 ,uint64
4 dropn
;

: write-elf64-data-program-header
  2 overn write-elf64-data-program-header/4
;

: write-elf64-code-section-header
( ' name uint32 field )
1 ,uint32
( ' type uint32 field )
1 ,uint32
( ' flags uint64 field )
7 ,uint64
( ' addr uint64 field )
swap to-out-addr dup elf64-code-segment + ,uint64
( ' offset uint64 field )
,uint64
( ' size uint64 field )
,uint64
( ' link uint32 field )
0 ,uint32
( ' info uint32 field )
0 ,uint32
( ' addralign uint64 field )
4096 ,uint64
( ' entsize uint64 field )
0 ,uint64
;

: write-elf64-data-section-header
( ' name uint32 field )
7 ,uint32
( ' type uint32 field )
1 ,uint32
( ' flags uint64 field )
3 ,uint64
( ' addr uint64 field )
,uint64
( ' offset uint64 field )
to-out-addr ,uint64
( ' size uint64 field )
,uint64
( ' link uint32 field )
0 ,uint32
( ' info uint32 field )
0 ,uint32
( ' addralign uint64 field )
4096 ,uint64
( ' entsize uint64 field )
0 ,uint64
;

: write-elf64-string-section-header
( ' name uint32 field )
13 ,uint32
( ' type uint32 field )
3 ,uint32
( ' flags uint64 field )
0x20 ,uint64
( ' addr uint64 field )
0 ,uint64
( ' offset uint64 field )
swap to-out-addr ,uint64
( ' size uint64 field )
,uint64
( ' link uint32 field )
0 ,uint32
( ' info uint32 field )
0 ,uint32
( ' addralign uint64 field )
4096 ,uint64
( ' entsize uint64 field )
0 ,uint64
;

: write-elf64-abi-tag-section-header
( ' name uint32 field )
23 ,uint32
( ' type uint32 field )
7 ,uint32
( ' flags uint64 field )
0 ,uint64
( ' addr uint64 field )
0 ,uint64
( ' offset uint64 field )
swap to-out-addr ,uint64
( ' size uint64 field )
,uint64
( ' link uint32 field )
0 ,uint32
( ' info uint32 field )
0 ,uint32
( ' addralign uint64 field )
4 ,uint64
( ' entsize uint64 field )
0 ,uint64
;

: write-elf64-zero-section-header
( ' name uint32 field )
0 ,uint32
( ' type uint32 field )
0 ,uint32
( ' flags uint64 field )
0 ,uint64
( ' addr uint64 field )
0 ,uint64
( ' offset uint64 field )
0 ,uint64
( ' size uint64 field )
0 ,uint64
( ' link uint32 field )
0 ,uint32
( ' info uint32 field )
0 ,uint32
( ' addralign uint64 field )
4096 ,uint64
( ' entsize uint64 field )
0 ,uint64
;

: write-elf64-string-section
  " " ,byte-string
  " .text" ,byte-string
  " .data" ,byte-string
  " .shstrtab" ,byte-string
  " .note.ABI-tag" ,byte-string
;

: write-elf64-abi-tag
  4 ,uint32 ( name )
  16 ,uint32 ( desc )
  1 ,uint32 ( type )
  " GNU" ,byte-string
  0 ,uint32 ( OS )
  4 ,uint32 ( major )
  20 ,uint32 ( minor)
  0 ,uint32 ( revision )
;
  
: rewrite-elf64-header ( entry section-headers program-headers )
  to-out-addr 40 from-out-addr uint64!
  to-out-addr 32 from-out-addr uint64!
  24 from-out-addr uint64!
;

: write-elf64-ending ( data-start code-start entry ++  )
  dhere write-elf64-string-section

  0x10 pad-data
  dhere
  0 over to-out-addr write-elf64-code-program-header
  5 overn 3 overn over - elf64-data-segment elf64-data-segment-size write-elf64-data-program-header/4 ( todo .tdata? )
  
  dhere
  write-elf64-zero-section-header
  5 overn 7 overn over - write-elf64-code-section-header
  6 overn 4 overn over - elf64-data-segment write-elf64-data-section-header
  3 overn 3 overn over - write-elf64-string-section-header

  ( needs entry + 1, section header, and program header offsets )
  4 overn elf64-code-segment +
  rot swap rewrite-elf64-header
;
