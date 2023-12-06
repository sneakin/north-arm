
( could be stub32 but uses features not available with Bash: variables that use peek and poke. )

: write-elf32-dynamic-header
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
3 ,uint16
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
elf32-header-size ,uint16
( ' phentsize uint16 field )
32 ,uint16
( ' phentnum uint16 field )
6 ,uint16
( ' shentsize uint16 field )
40 ,uint16
( ' shentnum uint16 field )
7 ,uint16
( ' shstrindx uint16 field )
3 ,uint16
;

: write-elf32-dynamic-string-section
  " " ,byte-string
  " .text" ,byte-string
  " .data" ,byte-string
  " .shstrtab" ,byte-string
  " .note.ABI-tag" ,byte-string
  " .rodata" ,byte-string
  " .data" ,byte-string
  " .bss" ,byte-string
  " .dynamic" ,byte-string
  " .dynstr" ,byte-string
  " .dyn.rel" ,byte-string
;

: write-elf32-phdr-program-header
( ' type uint32 field )
6 ,uint32
( ' offset uint32 field )
swap to-out-addr dup ,uint32
( ' vaddr uint32 field )
+ dup ,uint32
( ' paddr uint32 field )
,uint32
( ' filesz uint32 field )
dup ,uint32
( ' memsz uint32 field )
,uint32
( ' flags uint32 field )
4 ,uint32
( ' align uint32 field )
0 ,uint32
;

: write-elf32-interp-program-header
( ' type uint32 field )
3 ,uint32
( ' offset uint32 field )
to-out-addr dup ,uint32
( ' vaddr uint32 field )
elf32-code-segment + ,uint32
( ' paddr uint32 field )
0 ,uint32
( ' filesz uint32 field )
dup ,uint32
( ' memsz uint32 field )
,uint32
( ' flags uint32 field )
4 ,uint32
( ' align uint32 field )
0 ,uint32
;

" /system/bin/linker" string-const> elf32-interp-android
" /lib/ld-linux-armhf.so.3" string-const> elf32-interp-linux
( " /lib/ld-linux-aarch64.so.1" string-const> elf32-interp-linux )
elf32-interp-android var> *elf32-interp*

: write-elf32-interp
  *elf32-interp* peek ,byte-string
;

: write-elf32-dynamic-section-header
( ' name uint32 field )
56 ,uint32
( ' type uint32 field )
6 ,uint32
( ' flags uint32 field )
0x20 ,uint32
( ' addr uint32 field )
0 ,uint32
( ' offset uint32 field )
swap to-out-addr ,uint32
( ' size uint32 field )
8 pad-addr ,uint32
( ' link uint32 field )
5 ,uint32
( ' info uint32 field )
0 ,uint32
( ' addralign uint32 field )
4096 ,uint32
( ' entsize uint32 field )
8 ,uint32
;

: write-elf32-dynamic-string-section-header
( ' name uint32 field )
65 ,uint32
( ' type uint32 field )
3 ,uint32
( ' flags uint32 field )
0x20 ,uint32
( ' addr uint32 field )
0 ,uint32
( ' offset uint32 field )
swap to-out-addr ,uint32
( ' size uint32 field )
8 pad-addr ,uint32
( ' link uint32 field )
0 ,uint32
( ' info uint32 field )
0 ,uint32
( ' addralign uint32 field )
4096 ,uint32
( ' entsize uint32 field )
8 ,uint32
;

: write-elf32-dynamic-program-header
( ' type uint32 field )
2 ,uint32
( ' offset uint32 field )
to-out-addr dup ,uint32
( ' vaddr uint32 field )
elf32-code-segment + ,uint32
( ' paddr uint32 field )
0 ,uint32
( ' filesz uint32 field )
,uint32
( ' memsz uint32 field )
0 ,uint32
( ' flags uint32 field )
5 ,uint32
( ' align uint32 field )
0 ,uint32
;

: elf32-symbol-name ( nop ) ;
: elf32-symbol-value cell-size + ;
: elf32-symbol-size cell-size 2 * + ;
: elf32-symbol-info cell-size 3 * + ;
: elf32-symbol-other cell-size 4 * + ;
: elf32-symbol-shndx cell-size 5 * + ;
: elf32-symbol-name-idx cell-size 6 * + ;

: write-elf32-symbol ( pointer-symbol -- )
  dup elf32-symbol-name-idx peek ,uint32 ( name )
  dup elf32-symbol-value peek ,uint32 ( value )
  dup elf32-symbol-size peek ,uint32 ( size )
  dup elf32-symbol-info peek ,uint8 ( info )
  dup elf32-symbol-other peek ,uint8 ( other )
  elf32-symbol-shndx peek ,uint16 ( shndx )
;

0 var> elf32-offset-dynamic
0 var> elf32-offset-dynamic-hash
0 var> elf32-offset-dynamic-relocations
0 var> elf32-offset-dynamic-symtab
0 var> elf32-offset-got
0 var> elf32-offset-dynamic-strings
0 var> elf32-offset-dynstr

0 var> *out-libs*
0 var> *out-dynamic-symbols*
0 var> *out-dynamic-num-symbols*
0 var> *out-dynamic-relocs*

20 const> R_ARM_COPY ( android no support )
21 const> R_ARM_GLOB_DAT
22 const> R_ARM_JUMP_SLOT
23 const> R_ARM_RELATIVE
24 const> R_ARM_GOTOFF
25 const> R_ARM_GOTPC
26 const> R_ARM_GOT32
27 const> R_ARM_PLT32
28 const> R_ARM_CALL
29 const> R_ARM_JUMP24
30 const> R_ARM_THM_JUMP32
31 const> R_ARM_BASE_ABS


0 const> ELF32-SHN-UNDEF
0xff00 const> ELF32-SHN-LORESERVE
0xff00 const> ELF32-SHN-LOPROC
0xff1f const> ELF32-SHN-HIPROC
0xfff1 const> ELF32-SHN-ABS
0xfff2 const> ELF32-SHN-COMMON
0xffff const> ELF32-SHN-HIRESERVE

0x00 const> ELF32-STB-LOCAL
0x10 const> ELF32-STB-GLOBAL
0x20 const> ELF32-STB-WEAK
0xD0 const> ELF32-STB-LOPROC
0xF0 const> ELF32-STB-HIPROC

0x0 const> ELF32-STT-NOTYPE
0x1 const> ELF32-STT-OBJECT
0x2 const> ELF32-STT-FUNC
0x3 const> ELF32-STT-SECTION
0x4 const> ELF32-STT-FILE
0xD const> ELF32-STT-LOPROC
0xF const> ELF32-STT-HIPROC

( Android likes: )
ELF32-STT-FUNC var> *elf32-import-flags*
ELF32-STB-GLOBAL ELF32-STT-FUNC logior var> *elf32-export-flags*
( ld-linux needs GLOBAL, see elf32-target-linux! )
( ELF32-STT-FUNC ELF32-STB-GLOBAL logior var> *elf32-import-flags* )

def elf32-add-dynamic-symbol/2 ( name length ++ symbol )
  0
  arg1 arg0 allot-byte-string/2 drop
  0 0 0 0 0 0 0 0 8 swapn here set-local0
  local0 *out-dynamic-symbols* push-onto
  *out-dynamic-num-symbols* inc!
  local0 exit-frame
end

def elf32-add-dynamic-import-func/2 ( name length ++ index )
  *out-dynamic-num-symbols* peek
  arg1 arg0 elf32-add-dynamic-symbol/2
  ELF32-STB-GLOBAL ELF32-STT-FUNC logior over elf32-symbol-info poke
  local0 exit-frame
end

def elf32-add-dynamic-import-object/2 ( name length ++ index )
  *out-dynamic-num-symbols* peek
  arg1 arg0 elf32-add-dynamic-symbol/2
  ELF32-STB-LOCAL ELF32-STT-OBJECT logior swap elf32-symbol-info poke
  local0 exit-frame
end

def elf32-add-dynamic-export/3 ( value name length ++ symbol )
  *out-dynamic-num-symbols* peek
  arg1 arg0 elf32-add-dynamic-symbol/2
  arg2 over elf32-symbol-value poke
  exit-frame
end

def elf32-add-dynamic-export-value/3 ( value name length ++ symbol )
  arg2 arg1 arg0 elf32-add-dynamic-export/3
  ELF32-STB-GLOBAL ELF32-STT-NOTYPE logior over elf32-symbol-info poke
  ELF32-SHN-ABS over elf32-symbol-shndx poke  
  exit-frame
end

def elf32-add-dynamic-export-code-object/3 ( value name length ++ symbol )
  arg2 elf32-code-segment + arg1 arg0 elf32-add-dynamic-export/3
  ELF32-STB-GLOBAL ELF32-STT-OBJECT logior over elf32-symbol-info poke
  1 over elf32-symbol-shndx poke  
  exit-frame
end

def elf32-add-dynamic-export-data/3 ( value name length ++ symbol )
  arg2 elf32-data-segment + arg1 arg0 elf32-add-dynamic-export/3
  ELF32-STB-GLOBAL ELF32-STT-OBJECT logior over elf32-symbol-info poke
  6 over elf32-symbol-shndx poke  
  exit-frame
end

def elf32-add-dynamic-export-func/3 ( fn name length ++ symbol )
  arg2 elf32-code-segment + arg1 arg0 elf32-add-dynamic-export/3
  ELF32-STB-GLOBAL ELF32-STT-FUNC logior over elf32-symbol-info poke
  1 over elf32-symbol-shndx poke  
  exit-frame
end

def write-elf32-dynamic-symbol-table
  0 0 0 0 0 0 0 0 here write-elf32-symbol 8 dropn
  ( imports )
  *out-dynamic-symbols* peek ' write-elf32-symbol map-car
end

: write-elf32-symbol-name
  dhere elf32-offset-dynstr peek - over elf32-symbol-name-idx poke
  elf32-symbol-name peek ,byte-string
;

def print-dynamic-symbol
  arg0 elf32-symbol-name peek error-string espace
  arg0 elf32-symbol-name-idx peek error-hex-uint espace
  arg0 elf32-symbol-value peek error-hex-uint espace
  arg0 elf32-symbol-info peek error-hex-uint enl
end

def write-elf32-dynamic-strings
  dhere
  dup elf32-offset-dynstr poke
  0 ,uint8
  *out-libs* peek ' ,byte-string map-car
  *out-dynamic-symbols* peek ' write-elf32-symbol-name map-car
  ( print the list )
  *out-libs* peek ' error-line map-car
  *out-dynamic-symbols* peek ' print-dynamic-symbol map-car
  local0 return1
end

: write-elf32-got ( plt-addr dynamic-addr -- )
  ( .dynamic )
  to-out-addr elf32-code-segment + ,uint32
  ( size of? )
  0 ,uint32
  ( dl_runtime_resolve )
  dhere to-out-addr elf32-code-segment + ,uint32
  ( plt pointers )
  dup cell-size 4 * + ,uint32
  dhere to-out-addr elf32-code-segment + ,uint32
  0 ,uint32
  0 ,uint32
  0 ,uint32
  drop
;

def elf32-add-dynamic-reloc ( addr symbol-idx kind ++ )
  args *out-dynamic-relocs* push-onto
  exit-frame
end

def elf32-add-dynamic-jump-slot ( address symbol-idx ++ )
  arg1 arg0 R_ARM_JUMP_SLOT elf32-add-dynamic-reloc
  exit-frame
end

: write-elf32-reloc ( addr symbol-idx kind )
  rot ,uint32
  8 bsl logior ,uint32
;

def write-elf32-import-relocations ( reloc-list -- )
  arg0 UNLESS return0 THEN
  arg0 car
  dup cell-size 2 * + peek to-out-addr elf32-code-segment +
  over cell-size + peek *out-dynamic-num-symbols* peek swap -
  3 overn peek
  write-elf32-reloc
  arg0 cdr set-arg0 drop-locals repeat-frame
end

: write-elf32-dynamic-relocations
  dhere
  *out-dynamic-relocs* peek write-elf32-import-relocations drop
;

0 const> DT_NULL
1 const> DT_NEEDED
2 const> DT_PLTRELSZ
3 const> DT_PLTGOT
4 const> DT_HASH
5 const> DT_STRTAB
6 const> DT_SYMTAB
7 const> DT_RELA
8 const> DT_RELASZ
9 const> DT_RELAENT
10 const> DT_STRSZ
11 const> DT_SYMENT
12 const> DT_INIT
13 const> DT_FINI
14 const> DT_SONAME
15 const> DT_RPATH
16 const> DT_SYMBOLIC
17 const> DT_REL
18 const> DT_RELSZ
19 const> DT_RELENT
20 const> DT_PLTREL
21 const> DT_DEBUG
22 const> DT_TEXTREL
23 const> DT_JMPREL
0x70000000 const> DT_LOPROC
0x7fffffff const> DT_HIPROC

def write-elf32-dt-needed
  DT_NEEDED ,uint32 arg0 ,uint32
end

def write-elf32-dynamic-libs-loop ( string-section-idx lib-list ++ )
  arg0 UNLESS return0 THEN
  arg1 write-elf32-dt-needed
  arg0 car string-length 1 + arg1 + set-arg1
  arg0 cdr set-arg0 repeat-frame
end

def write-elf32-dynamic-libs
  ( todo use a reduce function )
  1 *out-libs* peek write-elf32-dynamic-libs-loop
end

( Symbol hash table, see: the ELF Spec and https://flapenguin.me/elf-dt-hash )

def elf32-hash-loop ( string-ptr h g ++ hash )
  arg2 UNLESS arg1 return1 THEN
  arg2 peek-byte dup UNLESS arg1 return1 THEN
  arg1 4 bsl + set-arg1
  arg1 0xF0000000 logand dup set-arg0
  IF
    arg0 24 bsr arg1 logxor
    arg1 arg0 lognot logand set-arg1
  THEN
  arg2 1 + set-arg2
  repeat-frame
end

def elf32-hash ( string -- hash )
  arg0 0 0 elf32-hash-loop set-arg0
end

def elf32-hash-chain-last-index ( chains idx -- idx )
  arg0 0 equals?
  IF 0 2 return1-n
  ELSE arg1 arg0 seq-peek
       dup 0 equals?
       IF arg0 2 return1-n
       ELSE set-arg0 repeat-frame
       THEN
  THEN
end

def elf32-build-hash/6 ( buckets num-buckets chains num-syms syms n -- )
  arg0 arg2 int< UNLESS 6 return0-n THEN
  arg1 UNLESS 6 return0-n THEN
  arg0 1 + set-arg0
  arg1 car elf32-symbol-name peek elf32-hash
  dup 4 argn int-mod ( bucket # )
  5 argn over seq-peek ( bucket[#] )
  dup 0 equals? IF
    ( empty bucket )
    arg0 5 argn 4 overn seq-poke
  ELSE
    ( append to chain )
    3 argn over elf32-hash-chain-last-index
    arg0 arg3 3 overn seq-poke
  THEN
  arg1 cdr set-arg1
  drop-locals repeat-frame
end

def elf32-build-hash/3 ( syms num-syms num-buckets ++ hash )
  0
  arg0 arg1 1 + + cell-size * stack-allot-zero set-local0
  local0 arg0 local0 arg0 cell-size * + arg1 arg2 0 elf32-build-hash/6
  local0 exit-frame
end

def write-elf32-symbol-hash
  *out-dynamic-symbols* peek
  *out-dynamic-num-symbols* peek
  dup 8 int-div 1 max
  0
  local0 local1 local2 elf32-build-hash/3 set-local3
  ( local3 local1 cell-size * 2 * cmemdump )
  ( write the table )
  local2 ,uint32 ( # buckets )
  local1 1 + ,uint32 ( chain length == blank + num symbols )
  local3 local1 1 + local2 + ,seq
  0 ,uint32
end

( PLT holds code that jumps via the GOT. )
( the GOT is an array of addresses. )
( Relocations tie symbols to memory addresses. )

: write-elf32-dynamic ( -- dyn-offset )
  4 pad-data
  dhere
  dup elf32-offset-dynamic poke
  dup to-out-addr elf32-code-segment +
  ( start writing )
  dhere 4 + elf32-offset-dynamic-hash poke
  DT_HASH ,uint32 0 ,uint32
  ( string table )
  dhere 4 + elf32-offset-dynamic-strings poke
  DT_STRTAB ,uint32 0 ,uint32
  DT_STRSZ ,uint32 0 ,uint32
  ( libraries w/ names from the string table )
  write-elf32-dynamic-libs
  ( symbol table )
  dhere 4 + elf32-offset-dynamic-symtab poke
  DT_SYMTAB ,uint32 0 ,uint32
  DT_SYMENT ,uint32 16 ,uint32
  ( procedure linkage )
  ( DT_PLTREL ,uint32 DT_REL ,uint32 )
  dhere 4 + elf32-offset-got poke
  DT_PLTGOT ,uint32 dup ,uint32
  ( relocations )
  dhere 4 + elf32-offset-dynamic-relocations poke
  DT_REL ,uint32 dup ,uint32
  DT_RELSZ ,uint32 0 ,uint32
  DT_RELENT ,uint32 8 ,uint32
  DT_NULL ,uint32 0 ,uint32
  drop

  ( the GOT ...not really needed )
  4 pad-data
  dhere to-out-addr elf32-code-segment + elf32-offset-got peek uint32!
  0 elf32-offset-dynamic peek write-elf32-got

  ( Relocations )
  4 pad-data
  write-elf32-dynamic-relocations
  dup to-out-addr elf32-code-segment + elf32-offset-dynamic-relocations peek uint32!
  dhere swap - elf32-offset-dynamic-relocations peek cell-size 2 * + uint32!
  ( Dynamic strings )
  dhere dup to-out-addr elf32-code-segment + elf32-offset-dynamic-strings peek uint32!
  write-elf32-dynamic-strings
  dhere swap - elf32-offset-dynamic-strings peek 8 + uint32!
  ( Symbol hash )
  dhere to-out-addr elf32-code-segment + elf32-offset-dynamic-hash peek uint32!
  write-elf32-symbol-hash
  ( Symbol table )
  dhere to-out-addr elf32-code-segment + elf32-offset-dynamic-symtab peek uint32!
  write-elf32-dynamic-symbol-table
;

: write-elf32-dynamic-ending ( data-start code-start entry ++  )
  dhere write-elf32-dynamic-string-section
  dhere write-elf32-interp
  write-elf32-dynamic ( .dynamic .dynstr )
  dhere
  0x10 pad-data

  ( Program headers: )
  ( todo bss segment for data )
  dhere
  32 6 * over elf32-code-segment write-elf32-phdr-program-header
  5 overn 5 overn swap - 6 overn write-elf32-interp-program-header
  4 overn 3 overn swap - 5 overn write-elf32-dynamic-program-header
  0 7 overn 10 overn - elf32-header-size + write-elf32-code-program-header
  9 overn 7 overn over - elf32-data-segment elf32-data-segment-size write-elf32-data-program-header/4
  dup 32 6 * elf32-code-segment 3 overn to-out-addr + write-elf32-data-program-header

  ( Section headers: )
  dhere
  write-elf32-zero-section-header
  9 overn 11 overn over - write-elf32-code-section-header
  10 overn 8 overn over - elf32-data-segment write-elf32-data-section-header
  7 overn 7 overn over - write-elf32-string-section-header
  5 overn 3 overn over - write-elf32-dynamic-section-header
  4 overn 3 overn over - .s write-elf32-dynamic-string-section-header
  2 overn 2 overn over - elf32-code-segment 3 overn to-out-addr + write-elf32-data-section-header
  ( todo exported symbols from dictionary )

  ( needs entry + 1, section header, and program header offsets )
  8 overn elf32-code-segment +
  shift rewrite-elf32-header
;

def elf32-target-android!
  elf32-interp-android *elf32-interp* poke
  ELF32-STT-FUNC *elf32-import-flags* poke
end

def elf32-target-linux!
  elf32-interp-linux *elf32-interp* poke
  ELF32-STT-FUNC ELF32-STB-GLOBAL logior *elf32-import-flags* poke
end
