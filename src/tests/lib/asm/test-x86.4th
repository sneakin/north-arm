load-core
" src/lib/assert.4th" load
" src/lib/asm/x86.4th" load

: break-padding 0xCCCCCCCC ,uint32 ;

: test-x86-mov#-16
  16 x86-bits!
  break-padding
  ( 8 bit )
  ( [ { 0x10 al } [ 0xCCRR10B0 ] ] ' mov# assert-op )
  dhere 0x10 al mov# break-padding
  0xCCCC10B0 1 assert-data
  ( 16 bit )
  dhere 0x1020 ax mov# break-padding
  0xCC1020B8 1 assert-data
  ( 32 bit )
  dhere 0x10203040 eax mov# break-padding
  0x3040B866 0xCCCC1020 2 assert-data
;

: test-x86-mov#-32
  32 x86-bits!
  break-padding
  ( 16 bit )
  dhere 0x1020 ax mov# break-padding
  0x1020B866 1 assert-data
  ( 32 bit )
  dhere 0x10203040 eax mov# break-padding
  0x203040B8 0xCCCCCC10 2 assert-data
  ( 64 bit )
  dhere 0x10203040 0x50607080 rax mov# break-padding
  0x3040B848 0x70801020 0xCCCC5060 3 assert-data
;

: test-x86-mov#-64
  64 x86-bits!
  break-padding
  ( 16 bit )
  dhere 0x1020 ax mov# break-padding
  0x1020B866 1 assert-data
  ( 32 bit )
  dhere 0x10203040 eax mov# break-padding
  0x203040B8 0xCCCCCC10 2 assert-data
  ( 64 bit: low reg )
  dhere 0x50607080 0x10203040 rax mov# break-padding
  0x7080B848 0x30405060 0xCCCC1020 3 assert-data
  ( 64 bit: extended reg )
  dhere 0x50607080 0x10203040 r8 mov# break-padding
  0x7080B849 0x30405060 0xCCCC1020 3 assert-data
  ( 64 bit: extended reg )
  dhere 0x50607080 0x10203040 r15 mov# break-padding
  0x7080BF49 0x30405060 0xCCCC1020 3 assert-data
;

: test-x86-mov#
  test-x86-mov#-16
  test-x86-mov#-32
  test-x86-mov#-64
;

: test-x86-movr
  32 x86-bits!
  4 align-data
  break-padding
  ( 8 to 8 )
  dhere bl cl modrr movr break-padding
  0xCCCCCB8A 1 assert-data
  ( 8 to 8 offset )
  dhere 0x1234 bl cl modrm+ movr break-padding
  0x12348B8A 1 assert-data
  ( 16 to 16 )
  dhere 0x1235 bx cx modrm+ movr break-padding
  0x358B8B66 0xCC000012 2 assert-data
  ( 16 to 32 )
  dhere 0x1236 ebx cx modrm+ movr break-padding
  0x368B8B66 0xCC000012 2 assert-data
  ( 32 to 32 )
  dhere 0x1237 rbx eax modrm+ movr break-padding
  0x37838B48 0xCC000012 2 assert-data
  ( 64 to 32 )
  dhere -0x1238 edx rcx modrm+ movr break-padding
  0xC88A8B48 0xCCFFFFED 2 assert-data
  ( 32 to 64 )
  dhere 0x1239 rax eax modrm+ movr break-padding
  0x39808B48 0xCC000012 2 assert-data
  ( 64 to 64: extended dest, no offset )
  dhere rax r8 modrr movr break-padding
  0xCCC08B4C 1 assert-data
  ( 64 to 64: extended dest, no offset )
  dhere rax r15 modrr movr break-padding
  0xCCF88B4C 1 assert-data
  ( 64 to 64 )
  dhere 0x123A r15 rax modrm+ movr break-padding ( fixme going to r8 and not rax )
  0x3A878B49 0xCC000012 2 assert-data
  ( sp to 64 )
  dhere rsp rax modrr movr break-padding
  0xCCC48B48 1 assert-data
  ( sib offset to 64 )
  dhere 0x123B rcx rdx x2 sib rax modrm+x movr break-padding ( fixme )
  0x51848B48 0x123B 2 assert-data
  ( 64 to 64 sib )
  dhere r9 rcx x1 sib rax modrmx movr break-padding
  0x09048B49 1 assert-data
;

: test-x86-movm
  64 x86-bits!
  8 align-data
  break-padding
  ( 8 to 8 )
  dhere bl cl modrr movm break-padding 
  0xCCCCCB88 1 assert-data
  ( 8 to 8 offset )
  dhere 0x1234 bl cl modrm+ movm break-padding
  0x12348B88 1 assert-data
  ( 16 to 16 )
  dhere 0x1235 bx cx modrm+ movm break-padding
  0x358B8966 0xCC000012 2 assert-data
  ( 16 to 32 )
  dhere 0x1236 ebx cx modrm+ movm break-padding
  0x368B8966 0xCC000012 2 assert-data
  ( 32 to 32 )
  dhere 0x1237 ebx eax modrm+ movm break-padding
  0x12378389 1 assert-data
  ( 32 to 32 offset )
  dhere 0x1020 ebx eax modrm+ movm break-padding
  0x10208389 1 assert-data
  ( 32 to 32 ind )
  dhere ebx eax modrm movm break-padding
  0xCCCC0389 1 assert-data
  ( sib offset to 32 )
  dhere 0x10 ecx edx x4 sib esp eax modrm+ movm break-padding ( fixme )
  0x10914489 1 assert-data
  ( 64 to 32 )
  dhere -0x1238 edx rcx modrm+ movm break-padding
  0xC88A8948 0xCCFFFFED 2 assert-data
  ( 32 to 64 )
  dhere 0x1239 rax eax modrm+ movm break-padding
  0x39808948 0xCC000012 2 assert-data
  ( 64 to 64: extended dest, no offset )
  dhere rax r8 modrr movm break-padding
  0xCCC0894C 1 assert-data
  ( 64 to 64: extended dest, no offset )
  dhere rax r15 modrr movm break-padding
  0xCCF8894C 1 assert-data
  ( 64 to 64 )
  dhere 0x123A r15 rax modrm+ movm break-padding
  0x3A878949 0xCC000012 2 assert-data
  ( 64 to 64 )
  dhere rsp rax modrr movm break-padding
  0xCCC48948 1 assert-data
  ( 64 to 64 sib )
  dhere rdx rcx x8 sib rax modrmx movm break-padding
  0xCA048948 1 assert-data
;

: test-x86-lea
  64 x86-bits!
  8 align-data
  break-padding
  ( 16 )
  dhere 10 cx bx modrm+ lea break-padding
  0xA598D66 1 assert-data
  ( 32 )
  dhere 20 ebx ecx modrm+ lea break-padding
  0xCC144B8D 1 assert-data
  ( 64 )
  dhere 0 r10 rax modrm+ lea break-padding
  0x00428D49 1 assert-data
  ( 64 ind )
  dhere r10 rax modrm lea break-padding
  0xCC028D49 1 assert-data
  ( 64 ind )
  dhere rbx rax modrm lea break-padding
  0xCC038D48 1 assert-data
  ( 64 "rsp" sib )
  dhere rcx r9 x2 sib rsp rbx modrm lea break-padding
  0x491C8D4A 1 assert-data
  ( 64 rsp )
  dhere rbx rsp modrm lea break-padding
  0xCC238D48 1 assert-data
  ( 64 sib )
  dhere ebx ecx x2 sib rax modrmx lea break-padding
  0x4B048D48 1 assert-data
;

: test-x86-pop
  64 x86-bits!
  8 align-data
  break-padding
  ( to register )
  dhere rdx pop break-padding
  0xCCCCCC5A 1 assert-data
;

: test-x86-popm
  64 x86-bits!
  8 align-data
  break-padding
  ( to 32 register )
  dhere ecx 0 modrr popm break-padding
  0xCCCCC18F 1 assert-data
  ( to 64 register )
  dhere rdx 0 modrr popm break-padding
  0xCCC28F48 1 assert-data
  ( to memory )
  dhere rdx 0 modrm popm break-padding
  0xCC028F48 1 assert-data
  ( to offset )
  dhere 0x40 rdx 0 modrm+ popm break-padding
  0x40428F48 1 assert-data
;

: test-x86-push
  64 x86-bits!
  8 align-data
  break-padding
  ( to register )
  dhere rdx push break-padding
  0xCCCCCC52 1 assert-data
;

: test-x86-pushm
  64 x86-bits!
  8 align-data
  break-padding
  ( to 32 register )
  dhere ecx 6 modrr pushm break-padding
  0xCCCCF1FF 1 assert-data
  ( to 64 register )
  dhere rdx 6 modrr pushm break-padding
  0xCCF2FF48 1 assert-data
  ( to memory )
  dhere rdx 6 modrm pushm break-padding
  0xCC32FF48 1 assert-data
  ( to offset )
  dhere 0x40 rdx 6 modrm+ pushm break-padding
  0x4072FF48 1 assert-data
;

: test-x86-push#
  64 x86-bits!
  8 align-data
  break-padding
  ( byte )
  dhere 0x7F push# break-padding
  0xCCCC7F6A 1 assert-data
  ( minus byte )
  dhere -1 push# break-padding
  0xCCCCFF6A 1 assert-data
  ( "byte" )
  dhere 0x80 push# break-padding
  0x00008068 0xCCCCCC00 2 assert-data
  ( word )
  dhere 0x800 push# break-padding
  0x00080068 0xCCCCCC00 2 assert-data
;

: test-x86-not
  64 x86-bits!
  8 align-data
  break-padding
  ( to 8 register )
  dhere cl 6 modrr x86:not break-padding
  0xCCCCD1F6 1 assert-data
  ( to 8 [register] )
  dhere cl 6 modrm x86:not break-padding
  0xCCCC11F6 1 assert-data
  ( to 32 register )
  dhere ecx 6 modrm x86:not break-padding
  0xCCCC11F7 1 assert-data
  ( to 32 register )
  dhere ecx 6 modrr x86:not break-padding
  0xCCCCD1F7 1 assert-data
  ( to 64 register )
  dhere rdx 6 modrr x86:not break-padding
  0xCCCCD2F748 1 assert-data
  ( to 64 ext register )
  dhere r11 6 modrr x86:not break-padding
  0xCCD3F749 1 assert-data
  ( to 64 ext register )
  dhere r12 6 modrr x86:not break-padding
  0xCCD4F749 1 assert-data
  ( to memory )
  dhere rdx 6 modrm x86:not break-padding
  0xCC12F748 1 assert-data
  ( to offset )
  dhere 0x40 rdx 6 modrm+ x86:not break-padding
  0x4052F748 1 assert-data
  ( 8 to sib offset )
  dhere 0x40 dl rcx x2 sib 6 modrm+x x86:not break-padding
  0x4A54F640 0xCCCCCC40 2 assert-data
  ( 16 to sib offset )
  dhere 0x40 dx rcx x2 sib 6 modrm+x x86:not break-padding
  0x54F74066 0xCCCC404A 2 assert-data
  ( 32 to sib offset )
  dhere 0x40 edx rcx x2 sib 6 modrm+x x86:not break-padding
  0x4A54F740 0xCCCCCC40 2 assert-data
  ( 64 to sib offset )
  dhere 0x34 rdx rcx x2 sib 6 modrm+x x86:not break-padding
  0x4A54F748 0xCCCCCC34 2 assert-data
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
