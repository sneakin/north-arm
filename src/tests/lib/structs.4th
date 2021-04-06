tmp" src/lib/assert.4th" load/2
tmp" src/lib/structs.4th" load/2

( Defining words: )

( value fields )
struct: vec4
field: x float<32>
field: y float<32>
field: z float<32>
field: w float<32>

( complex fields )
struct: time-integrated
field: current vec4
field: velocity vec4
field: accel vec4

( reference fields )
struct: thing
field: parent pointer<any>
field: position time-integrated
field: rotation time-integrated

struct: date
field: year uint<32>
field: month uint<8>
field: day uint<8>

( array fields )
struct: record
field: id value
seq-field: first-name uint<8> 64
seq-field: last-name value 16
field: dob date

struct: pet-record
inherits: record
field: species uint<32>

def test-struct-manually
  nl s" Meta types" write-line/2
  value value-of struct-byte-size peek ,h nl
  ( null struct-byte-size peek ,h nl )
  pointer<any> print-pointer<struct>
  type print-pointer<struct>
  struct print-pointer<struct>
  struct value-of print-struct
  struct-field value-of ,h print-struct

  nl s" Array types" write-line/2
  array-type print-pointer<struct>
  uint<16> 16 make-array-type print-pointer<struct>

  nl s" User types" write-line/2
  vec4 ,h print-pointer<struct>
  thing print-pointer<struct>
  record ,h print-pointer<struct>

  nl s" Instances" write-line/2
  thing make-instance
  dup print-pointer<any>

  record make-instance
  dup print-pointer<any>
  s" First name: " write-string/2
  dup value-of record-first-name write-uint nl
  dup value-of 0 record-first-name-aref write-uint nl
  dup value-of 5 record-first-name-aref write-uint nl
  s" Last name: " write-string/2
  dup value-of record-last-name write-uint nl
  dup value-of 5 record-last-name-aref write-uint nl
  s" All fields:" write-line/2
  0x1234 over value-of record-id uint32!
  2021 over value-of record-dob date-year uint16!
  3 over value-of record-dob date-month uint8!
  31 over value-of record-dob date-day uint8!
  " Nolan" over value-of record-first-name 5 copy-byte-string/3 3 dropn
  " Eakins" over value-of record-last-name 6 copy-byte-string/3 3 dropn

  dup print-instance nl

  dup value-of record . first-name write-line
  dup value-of record . last-name write-line
  dup record -> first-name write-line
  dup record -> last-name write-line

  s" Record kind of:" write-line/2
  dup record kind-of? write-uint nl
  dup type kind-of? write-uint nl

  s" Struct kind of:" write-line/2
  type type kind-of? write-uint nl
  struct type kind-of? write-uint nl

  s" Record struct kind of:" write-line/2
  record struct kind-of? write-uint nl
  record type kind-of? write-uint nl
  record null kind-of? write-uint nl
  record record kind-of? write-uint nl

  s" Pet Record:" write-line/2
  pet-record print-instance
  pet-record print-pointer<struct>
  pet-record make-instance
  dup print-instance

hello
end
