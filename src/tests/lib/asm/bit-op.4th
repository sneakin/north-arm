tmp" src/lib/asm/bit-op.4th" drop load

bit-op[ t:add 0 0 0 1 1 Imm Op Rn:3 Rs:3 Rd:3 ] ( Add/subtract )

bit-op[ t:alu# 0 0 1 Op:2 Rd:3 Offset:8 ] ( Move/compare/add/subtract immediate )
bit-op[ t:mov# 0 0 1 0 0 Rd:3 Offset:8 ] ( Move/compare/add/subtract immediate )
bit-op[ t:cmp# 0 0 1 0 1 Rd:3 Offset:8 ]
bit-op[ t:str-sp 1 0 0 1 0 Rd:3 Word:8 ] ( SP-relative store )
bit-op[ t:ldr-sp 1 0 0 1 1 Rd:3 Word:8 ] ( SP-relative load )
bit-op[ t:inc-sp 1 0 1 1 0 0 0 0 0 SWord:7 ] ( Add offset to stack pointer )
bit-op[ t:dec-sp 1 0 1 1 0 0 0 0 1 SWord:7 ] ( Subtract offset from stack pointer )

( todo with shift )
( bit-op[ t:bl 1 1 1 1 0 offset:11:12 1 1 1 1 1 offset:11:1 ] )