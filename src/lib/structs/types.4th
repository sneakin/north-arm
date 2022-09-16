( Atomic types: )

( Atomic values: )
type cell-size type: value

( Atomic pointers: )
value cell-size type: pointer<any>

( Abstract integer bases: )
value 0 type: unsigned-integer
unsigned-integer 1 type: uint<8> ( Unsigned integers of 8 bits, 1 byte. )
unsigned-integer 2 type: uint<16> ( Unsigned integers of 16 bit, 2 bytes, machine order. )
unsigned-integer 4 type: uint<32> ( Unsigned integers of 32 bit, 4 bytes, machine order. )
unsigned-integer 8 type: uint<64> ( Unsigned integers of 64 bit, 8 bytes, machine order. )
alias> uint uint<32>

value 0 type: integer
integer 1 type: int<8> ( Signed integers of 8 bits, 1 byte. )
integer 2 type: int<16> ( Signed integers of 16 bit, 2 bytes, machine order. )
integer 4 type: int<32> ( Signed integers of 32 bit, 4 bytes, machine order. )
integer 8 type: int<64> ( Signed integers of 64 bit, 8 bytes, machine order. )
alias> int int<32>

( Floating point: )
value cell-size type: abstract-float ( Base floating point number. )
abstract-float 4 type: float<32> ( 32 bit floating point number. )
abstract-float 8 type: float<64> ( 64 bit floating point number. )
alias> float float<32>
