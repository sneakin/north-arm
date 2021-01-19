( could be stub32 but uses features not available with Bash: variables that use peek and poke. )

0x80000 const> elf32-code-segment

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
52 ,uint16
( ' phentsize uint16 field )
32 ,uint16
( ' phentnum uint16 field )
4 ,uint16
( ' shentsize uint16 field )
40 ,uint16
( ' shentnum uint16 field )
4 ,uint16
( ' shstrindx uint16 field )
2 ,uint16
;

: write-elf32-program-code-header
( ' type uint32 field )
1 ,uint32
( ' offset uint32 field )
swap ,uint32
( ' vaddr uint32 field )
elf32-code-segment ,uint32
( ' paddr uint32 field )
elf32-code-segment ,uint32
( ' filesz uint32 field )
dup to-out-addr ,uint32
( ' memsz uint32 field )
to-out-addr ,uint32
( ' flags uint32 field )
7 ,uint32
( ' align uint32 field )
0x1000 ,uint32
;

: write-elf32-code-section-header
( ' name uint32 field )
1 ,uint32
( ' type uint32 field )
1 ,uint32
( ' flags uint32 field )
0x10000007 ,uint32
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
  " GNU" ,byte-string
  0 ,uint32 ( OS )
  4 ,uint32 ( major )
  20 ,uint32 ( minor)
  0 ,uint32 ( revision )
;

: write-elf32-phdr-program-header
( ' type uint32 field )
6 ,uint32
( ' offset uint32 field )
to-out-addr dup ,uint32
( ' vaddr uint32 field )
elf32-code-segment + dup ,uint32
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

: write-elf32-symbol
  ,uint32 ( name )
  ,uint32 ( value )
  ,uint32 ( size )
  ,uint8 ( info )
  0 ,uint8 ( other )
  ,uint16 ( shndx )
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

22 const> R_ARM_JUMP_SLOT

def elf32-add-dynamic-symbol/2
  arg1 arg0 allot-byte-string/2 drop
  0 swap cons
  *out-dynamic-symbols* push-onto
  *out-dynamic-num-symbols* dup peek dup 1 + swap rot poke
  exit-frame
end

def write-elf32-import-symbols ( dynstr-offset imports -- )
  arg0 UNLESS return0 THEN
  2 2 0 0
  arg0 car cdr arg1 -
  write-elf32-symbol
  arg0 cdr set-arg0 drop-locals repeat-frame
end

: write-elf32-dynamic-symbol-table
  0 0 0 0 0 write-elf32-symbol
  ( 2 2 0 0 68 write-elf32-symbol ) ( puts )
  ( imports )
  elf32-offset-dynstr peek *out-dynamic-symbols* peek write-elf32-import-symbols
  2 dropn
;

: write-elf32-symbol-name
  dhere over set-cdr!
  car ,byte-string
;

def print-dynamic-symbol
  arg0 car error-string espace
  arg0 cdr error-hex-uint enl
end

def write-elf32-dynamic-strings
  dhere
  dup elf32-offset-dynstr poke
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
  1 *out-dynamic-relocs* peek write-elf32-import-relocations 2 dropn
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

def write-elf32-dynamic-libs-loop
  arg0 UNLESS return0 THEN
  arg1 write-elf32-dt-needed
  arg0 car string-length 1 + arg1 + set-arg1
  arg0 cdr set-arg0 repeat-frame
end

def write-elf32-dynamic-libs
  ( todo use a reduce function )
  0 *out-libs* peek write-elf32-dynamic-libs-loop
end

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

def write-elf32-symbol-hash-loop ( imports num-syms num-buckets counter )
  arg3 IF
    ( write index )
    arg0 ,uint32
    ( loop )
    arg0 1 + set-arg0
    arg3 cdr set-arg3
    repeat-frame
  THEN
end

def write-elf32-symbol-hash
  *out-dynamic-symbols* peek
  *out-dynamic-num-symbols* peek
  ( write the table )
  1 ,uint32 ( one bucket )
  dup ,uint32 ( chain length == num symbols )
  1 ,uint32 ( the 1 bucket )
  1 1 write-elf32-symbol-hash-loop
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
  dhere to-out-addr elf32-code-segment + elf32-offset-dynamic-strings peek uint32!
  write-elf32-dynamic-strings
  dhere swap - elf32-offset-dynamic-strings peek 8 + uint32!
  ( Symbol hash )
  dhere to-out-addr elf32-code-segment + elf32-offset-dynamic-hash peek uint32!
  write-elf32-symbol-hash
  ( Symbol table )
  dhere to-out-addr elf32-code-segment + elf32-offset-dynamic-symtab peek uint32!
  write-elf32-dynamic-symbol-table
;

: rewrite-elf32-header ( entry section-headers program-headers )
  ( todo use offset vars )
  to-out-addr 32 from-out-addr uint32!
  to-out-addr 28 from-out-addr uint32!
  24 from-out-addr uint32!
;

: write-elf32-ending ( code-start entry ++  )
  dhere write-elf32-string-section
  dhere write-elf32-interp
  write-elf32-dynamic
  dhere
  0x10 pad-data

  ( Program headers: )
  dhere
  32 4 * over write-elf32-phdr-program-header
  4 overn 4 overn swap - 5 overn write-elf32-interp-program-header
  0 dhere 32 2 * + write-elf32-program-code-header
  3 overn 3 overn swap - 4 overn write-elf32-dynamic-program-header

  ( Section headers: )
  dhere
  write-elf32-zero-section-header
  8 overn over over - write-elf32-code-section-header
  6 overn 6 overn over - write-elf32-string-section-header
  4 overn 4 overn over - write-elf32-dynamic-section-header
  ( todo symbols from dictionary )
  
  ( needs entry + 1, section header, and program header offsets )
  7 overn elf32-code-segment +
  rot swap rewrite-elf32-header
;
