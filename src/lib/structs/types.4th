( TODO Types:
  atom
  value
  null: value, atom
  type
  struct
  struct-field
  array-type
  number
  integer: number
  int<bits <= cell-size>: integer, value, atom
  uint<bits <= cell-size>: integer, value, atom
  int<bits > cell-size>: integer, value
  uint<bits > cell-size>: integer, value
  float: number
  float<bits>: float, value, atom
  float<bits > cell-size>: float, value
)

( Atomic types: )

( Atomic values: )
" value"
type swap
cell-size swap
here type cons const> value

( Atomic pointers: )
" pointer"
value swap
cell-size swap
here type cons const> pointer<any>

( Abstract integer base: )
" integer"
value swap
0 swap
here type cons const> integer

( Unsigned integers of 8 bits, 1 byte: )
" uint<8>"
integer swap
1 swap
here type cons const> uint<8>

( Unsigned integers of 16 bit, 2 bytes, machine order: )
" uint<16>"
integer swap
2 swap
here type cons const> uint<16>

( Unsigned integers of 32 bit, 4 bytes, machine order: )
" uint<32>"
integer swap
cell-size swap
here type cons const> uint<32>

( Base floating point number: )
" float"
value swap
0 swap
here type cons const> float

( 32 bit floating point number: )
" float<32>"
float swap
cell-size swap
here type cons const> float<32>

( 64 bit floating point number: )
" float<64>"
float swap
cell-size 2 * swap
here type cons const> float<64>
