load-core
" src/lib/assert.4th" load
" src/lib/asm/x86.4th" load

: break-padding 0xCCCCCCCC ,uint32 ;

: test-x86-mov#-16
  16 x86-bits !
  break-padding
  ( 8 bit )
  dhere 0x10 al mov# break-padding
  peek ,h 0xCCCC10B0 assert-equals
  ( 16 bit )
  dhere 0x1020 ax mov# break-padding
  peek ,h 0xCC1020B8 assert-equals
  ( 32 bit )
  dhere 0x10203040 eax mov# break-padding
  dup peek ,h 0x3040B866 assert-equals
  cell-size + peek ,h 0xCCCC1020 assert-equals
;

: test-x86-mov#-32
  32 x86-bits !
  break-padding
  ( 16 bit )
  dhere 0x1020 ax mov# break-padding
  peek ,h 0x1020B866 assert-equals
  ( 32 bit )
  dhere 0x10203040 eax mov# break-padding
  dup peek ,h 0x203040B8 assert-equals
  cell-size + peek ,h 0xCCCCCC10 assert-equals
  ( 64 bit )
  dhere 0x10203040 0x50607080 rax mov# break-padding
  dup peek ,h 0x3040B848 assert-equals
  cell-size + dup peek ,h 0x70801020 assert-equals
  cell-size + peek ,h 0xCCCC5060 assert-equals
;

: test-x86-mov#-64
  64 x86-bits !
  break-padding
  ( 16 bit )
  dhere 0x1020 ax mov# break-padding
  peek ,h 0x1020B866 assert-equals
  ( 32 bit )
  dhere 0x10203040 eax mov# break-padding
  dup peek ,h 0x203040B8 assert-equals
  cell-size + peek ,h 0xCCCCCC10 assert-equals
  ( 64 bit: low reg )
  dhere 0x50607080 0x10203040 rax mov# break-padding
  dup peek ,h 0x7080B848 assert-equals
  cell-size + dup peek ,h 0x30405060 assert-equals
  cell-size + peek ,h 0xCCCC1020 assert-equals
  ( 64 bit: extended reg )
  dhere 0x50607080 0x10203040 r8 mov# break-padding
  dup peek ,h 0x7080B849 ,h assert-equals
  cell-size + dup peek ,h 0x30405060 assert-equals
  cell-size + peek ,h 0xCCCC1020 assert-equals
  ( 64 bit: extended reg )
  dhere 0x50607080 0x10203040 r15 mov# break-padding
  dup peek ,h 0x7080BF49 ,h assert-equals
  cell-size + dup peek ,h 0x30405060 assert-equals
  cell-size + peek ,h 0xCCCC1020 assert-equals
;

: test-x86-mov#
  test-x86-mov#-16
  test-x86-mov#-32
  test-x86-mov#-64
;

: test-x86-movr
  32 x86-bits !
  4 align-data
  break-padding
  ( 8 to 8 )
  dhere bl cl modrr movr break-padding
  dup peek ,h 0xCCCCCB8A assert-equals
  drop
  ( 8 to 8 offset )
  dhere 0x1234 bl cl modoff movr break-padding
  dup peek ,h 0x12348B8A assert-equals
  drop
  ( 16 to 16 )
  dhere 0x1235 bx cx modoff movr break-padding
  dup peek ,h 0x358B8B66 assert-equals
  cell-size + dup peek ,h 0xCC000012 assert-equals
  drop
  ( 16 to 32 )
  dhere 0x1236 ebx cx modoff movr break-padding
  dup peek ,h 0x368B8B66 assert-equals
  cell-size + dup peek ,h 0xCC000012 assert-equals
  drop
  ( 32 to 32 )
  dhere 0x1237 rbx eax modoff movr break-padding
  dup peek ,h 0x37838B48 assert-equals
  cell-size + dup peek ,h 0xCC000012 assert-equals
  drop
  ( 64 to 32 )
  dhere -0x1238 edx rcx modoff movr break-padding
  dup peek ,h 0xC88A8B48 assert-equals
  cell-size + dup peek ,h 0xCCFFFFED assert-equals
  drop
  ( 32 to 64 )
  dhere 0x1239 rax eax modoff movr break-padding
  dup peek ,h 0x39808B48 assert-equals
  cell-size + dup peek ,h 0xCC000012 assert-equals
  drop
  ( 64 to 64: extended dest, no offset )
  dhere rax r8 modrr movr break-padding
  dup peek ,h 0xCCC08B4C assert-equals
  drop
  ( 64 to 64: extended dest, no offset )
  dhere rax r15 modrr movr break-padding
  dup peek ,h 0xCCF88B4C assert-equals
  drop
  ( 64 to 64 )
  dhere 0x123A r15 rax modoff movr break-padding ( fixme going to r8 and not rax )
  dup peek ,h 0x3A878B49 assert-equals
  cell-size + dup peek ,h 0xCC000012 assert-equals
  drop
  ( sp to 64 )
  dhere rsp rax modrr movr break-padding
  dup peek ,h 0xCCC48B48 assert-equals
  drop
  ( sib offset to 64 )
  dhere 0x123B rcx rdx x2 sib rsp rax modoff movr break-padding ( fixme )
  dup peek ,h 0x51848B48 assert-equals
  cell-size + dup peek ,h 0x123B assert-equals
  drop
  ( 64 to 64 sib )
  dhere r9 rcx x1 sib rax modsib movr break-padding
  dup peek ,h 0x09048B49 assert-equals
  drop
;

: test-x86-movm
  64 x86-bits !
  8 align-data
  break-padding
  ( 8 to 8 )
  dhere bl cl modrr movm break-padding 
  dup peek ,h 0xCCCCCB88 assert-equals
  drop
  ( 8 to 8 offset )
  dhere 0x1234 bl cl modoff movm break-padding
  dup peek ,h 0x12348B88 assert-equals
  drop
  ( 16 to 16 )
  dhere 0x1235 bx cx modoff movm break-padding
  dup peek ,h 0x358B8966 assert-equals
  cell-size + dup peek ,h 0xCC000012 assert-equals
  drop
  ( 16 to 32 )
  dhere 0x1236 ebx cx modoff movm break-padding
  dup peek ,h 0x368B8966 assert-equals
  cell-size + dup peek ,h 0xCC000012 assert-equals
  drop
  ( 32 to 32 )
  dhere 0x1237 ebx eax modoff movm break-padding
  dup peek ,h 0x12378389 assert-equals
  drop
  ( 32 to 32 offset )
  dhere 0x1020 ebx eax modoff movm break-padding
  dup peek ,h 0x10208389 assert-equals
  drop
  ( 32 to 32 ind )
  dhere ebx eax modind movm break-padding
  dup peek ,h 0xCCCC0389 assert-equals
  drop
  ( sib offset to 32 )
  dhere 0x10 ecx edx x4 sib esp eax modoff movm break-padding ( fixme )
  dup peek ,h 0x10914489 assert-equals
  drop
  ( 64 to 32 )
  dhere -0x1238 edx rcx modoff movm break-padding
  dup peek ,h 0xC88A8948 assert-equals
  cell-size + dup peek ,h 0xCCFFFFED assert-equals
  drop
  ( 32 to 64 )
  dhere 0x1239 rax eax modoff movm break-padding
  dup peek ,h 0x39808948 assert-equals
  cell-size + dup peek ,h 0xCC000012 assert-equals
  drop
  ( 64 to 64: extended dest, no offset )
  dhere rax r8 modrr movm break-padding
  dup peek ,h 0xCCC0894C assert-equals
  drop
  ( 64 to 64: extended dest, no offset )
  dhere rax r15 modrr movm break-padding
  dup peek ,h 0xCCF8894C assert-equals
  drop
  ( 64 to 64 )
  dhere 0x123A r15 rax modoff movm break-padding
  dup peek ,h 0x3A878949 assert-equals
  cell-size + dup peek ,h 0xCC000012 assert-equals
  drop
  ( 64 to 64 )
  dhere rsp rax modrr movm break-padding
  dup peek ,h 0xCCC48948 assert-equals
  drop
  ( 64 to 64 sib )
  dhere rdx rcx x8 sib rax modsib movm break-padding
  dup peek ,h 0xCA048848 assert-equals
  drop
;

: test-x86-lea
  64 x86-bits !
  8 align-data
  break-padding
  ( 16 )
  dhere 10 cx bx modoff lea break-padding
  dup peek ,h 0xA598D66 assert-equals
  drop
  ( 32 )
  dhere 20 ebx ecx modoff lea break-padding
  dup peek ,h 0xCC144B8D assert-equals
  drop
  ( 64 )
  dhere 0 r10 rax modoff lea break-padding
  dup peek ,h 0x00428D49 assert-equals
  drop
  ( 64 ind )
  dhere r10 rax modind lea break-padding
  dup peek ,h 0xCC028D49 assert-equals
  drop
  ( 64 ind )
  dhere rbx rax modind lea break-padding
  dup peek ,h 0xCC038D48 assert-equals
  drop
  ( 64 "rsp" sib )
  dhere rcx r9 x2 sib rsp rbx modind lea break-padding
  dup peek ,h 0x491C8D4A assert-equals
  drop
  ( 64 rsp )
  dhere rbx rsp modind lea break-padding
  dup peek ,h 0xCC238D48 assert-equals
  drop
  ( 64 sib )
  dhere ebx ecx x2 sib rax modsib lea break-padding
  dup peek ,h 0x4B048D48 assert-equals
  drop
;

: test-x86-pop
  64 x86-bits !
  8 align-data
  break-padding
  ( to register )
  dhere rdx pop break-padding
  dup peek ,h 0xCCCCCC5A assert-equals
  drop
;

: test-x86-popm
  64 x86-bits !
  8 align-data
  break-padding
  ( to 32 register )
  dhere ecx 0 modrr popm break-padding
  dup peek ,h 0xCCCCC18F assert-equals
  drop
  ( to 64 register )
  dhere rdx 0 modrr popm break-padding
  dup peek ,h 0xCCC28F48 assert-equals
  drop
  ( to memory )
  dhere rdx 0 modind popm break-padding
  dup peek ,h 0xCC028F48 assert-equals
  drop
  ( to offset )
  dhere 0x40 rdx 0 modoff popm break-padding
  dup peek ,h 0x40428F48 assert-equals
  drop
;

: test-x86-push
  64 x86-bits !
  8 align-data
  break-padding
  ( to register )
  dhere rdx push break-padding
  dup peek ,h 0xCCCCCC52 assert-equals
  drop
;

: test-x86-pushm
  64 x86-bits !
  8 align-data
  break-padding
  ( to 32 register )
  dhere ecx 6 modrr pushm break-padding
  dup peek ,h 0xCCCCF1FF assert-equals
  drop
  ( to 64 register )
  dhere rdx 6 modrr pushm break-padding
  dup peek ,h 0xCCF2FF48 assert-equals
  drop
  ( to memory )
  dhere rdx 6 modind pushm break-padding
  dup peek ,h 0xCC32FF48 assert-equals
  drop
  ( to offset )
  dhere 0x40 rdx 6 modoff pushm break-padding
  dup peek ,h 0x4072FF48 assert-equals
  drop
;

: test-x86-push#
  64 x86-bits !
  8 align-data
  break-padding
  ( byte )
  dhere 0x80 push# break-padding
  dup peek ,h 0xCCCC806A assert-equals
  drop
  ( word )
  dhere 0x800 push# break-padding
  dup peek ,h 0x00080068 assert-equals
  drop
;

: test-x86-not
  64 x86-bits !
  8 align-data
  break-padding
  ( to 8 register )
  dhere cl 6 modrr x86:not break-padding
  dup peek ,h 0xCCCCD1F6 assert-equals
  drop
  ( to 8 [register] )
  dhere cl 6 modind x86:not break-padding
  dup peek ,h 0xCCCC11F6 assert-equals
  drop
  ( to 32 register )
  dhere ecx 6 modind x86:not break-padding
  dup peek ,h 0xCCCC11F7 assert-equals
  drop
  ( to 32 register )
  dhere ecx 6 modrr x86:not break-padding
  dup peek ,h 0xCCCCD1F7 assert-equals
  drop
  ( to 64 register )
  dhere rdx 6 modrr x86:not break-padding
  dup peek ,h 0xCCCCD2F748 assert-equals
  drop
  ( to 64 ext register )
  dhere r11 6 modrr x86:not break-padding
  dup peek ,h 0xCCD3F749 assert-equals
  drop
  ( to 64 ext register )
  dhere r12 6 modrr x86:not break-padding
  dup peek ,h 0xCCD4F749 assert-equals
  drop
  ( to memory )
  dhere rdx 6 modind x86:not break-padding
  dup peek ,h 0xCC12F748 assert-equals
  drop
  ( to offset )
  dhere 0x40 rdx 6 modoff x86:not break-padding
  dup peek ,h 0x4052F748 assert-equals
  drop
;

: test-x86
  dhere .s
  test-x86-mov#
  test-x86-movr
  test-x86-movm
  test-x86-lea
  test-x86-pop
  test-x86-popm
  test-x86-push
  test-x86-pushm
  test-x86-push#
  test-x86-not
  .s ddump-binary-bytes
;
