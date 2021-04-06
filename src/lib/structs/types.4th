( Atomic types: )

( Atomic values: )
type cell-size type: value

( Atomic pointers: )
value cell-size type: pointer<any>

( Abstract integer bases: )
value 0 type: integer
integer 0 type: uint
uint 1 type: uint<8> ( Unsigned integers of 8 bits, 1 byte. )
uint 2 type: uint<16> ( Unsigned integers of 16 bit, 2 bytes, machine order. )
uint 4 type: uint<32> ( Unsigned integers of 32 bit, 4 bytes, machine order. )

integer 0 type: int
int 1 type: int<8> ( Signed integers of 8 bits, 1 byte. )
int 2 type: int<16> ( Signed integers of 16 bit, 2 bytes, machine order. )
int 4 type: int<32> ( Signed integers of 32 bit, 4 bytes, machine order. )

( Floating point: )
value 0 type: float ( Base floating point number. )
float 4 type: float<32> ( 32 bit floating point number. )
float 8 type: float<64> ( 64 bit floating point number. )
