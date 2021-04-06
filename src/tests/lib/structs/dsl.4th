tmp" src/lib/assert.4th" load/2
tmp" src/lib/structs.4th" load/2
tmp" src/tests/lib/structs/assert.4th" load/2

( Define a few structs exercising features: )

( value fields )
struct: vec4
field: x float<32>
field: y float<32>
field: z float<32>
field: w float<32>

def test-struct-vec4
  vec4 struct kind-of? assert
  vec4 s" vec4" null cell-size 4 * 4 assert-struct
  vec4 s" x" float<32> 0 cell-size assert-struct-field
  vec4 s" y" float<32> cell-size cell-size assert-struct-field
  vec4 s" z" float<32> cell-size 2 * cell-size assert-struct-field
  vec4 s" w" float<32> cell-size 3 * cell-size assert-struct-field
end

( todo test generated accessors )

def test-struct-vec4-instance
  0
  vec4 make-instance set-local0
  local0 type-of vec4 assert-equals
  ( arrow accessors )
  local0 vec4 -> x local0 value-of assert-equals
  local0 vec4 -> y local0 value-of cell-size + assert-equals
  local0 vec4 -> z local0 value-of cell-size 2 * + assert-equals
  local0 vec4 -> w local0 value-of cell-size 3 * + assert-equals
  ( function accessors )
  local0 value-of vec4-x local0 value-of assert-equals
  local0 value-of vec4-y local0 value-of cell-size + assert-equals
  local0 value-of vec4-z local0 value-of cell-size 2 * + assert-equals
  local0 value-of vec4-w local0 value-of cell-size 3 * + assert-equals
end

( complex fields )
struct: time-integrated
field: current vec4
field: velocity vec4
field: accel vec4

def test-struct-time-integrated
  time-integrated struct kind-of? assert
  time-integrated s" time-integrated" null vec4 struct -> byte-size peek 3 * 3 assert-struct
  time-integrated s" current" vec4 0 vec4 type -> byte-size peek assert-struct-field
  time-integrated s" velocity" vec4 vec4 type -> byte-size peek dup assert-struct-field
  time-integrated s" accel" vec4 vec4 type -> byte-size peek dup 2 * swap assert-struct-field
end

def test-struct-time-integrated-instance
  0
  time-integrated make-instance set-local0
  local0 type-of time-integrated assert-equals
  local0 time-integrated -> current local0 value-of assert-equals
  local0 time-integrated -> velocity local0 value-of vec4 struct -> byte-size peek + assert-equals
  local0 time-integrated -> accel local0 value-of vec4 struct -> byte-size peek 2 * + assert-equals
end

( reference fields )
struct: thing
field: parent pointer<any>
field: position time-integrated
field: rotation time-integrated

def test-struct-thing
  thing struct kind-of? assert
  thing s" thing" null time-integrated struct -> byte-size peek 2 * cell-size + 3 assert-struct
  thing s" parent" pointer<any> 0 cell-size assert-struct-field
  thing s" position" time-integrated cell-size time-integrated type -> byte-size peek assert-struct-field
  thing s" rotation" time-integrated
  cell-size time-integrated type -> byte-size peek +
  time-integrated type -> byte-size peek
  assert-struct-field
end

( tiny atomic fields )
struct: date
field: year uint<32>
field: month uint<8>
field: day uint<8>

def test-struct-date
  date struct kind-of? assert
  date s" date" null 6 3 assert-struct
  date s" year" uint<32> 0 cell-size assert-struct-field
  date s" month" uint<8> 4 1 assert-struct-field
  date s" day" uint<8> 5 1 assert-struct-field
end

( array fields )
struct: record
field: id value
seq-field: first-name uint<8> 64
seq-field: last-name value 16
field: dob date

def test-struct-record
  record struct kind-of? assert
  record s" record" null 74 16 4 * + 4 assert-struct
  record s" id" value 0 cell-size assert-struct-field
  record s" first-name" array-type cell-size 64 assert-struct-field
  record s" last-name" array-type cell-size 64 + 64 assert-struct-field
  record s" dob" date cell-size 128 + 6 assert-struct-field
end

( inheritance )
struct: pet-record
inherits: record
field: species uint<32>

def test-struct-pet-record
  pet-record struct kind-of? assert
  pet-record pet-record type-super-of? assert
  pet-record record type-super-of? assert
  pet-record s" pet-record" record 74 16 4 * + 4 + 2 assert-struct
  pet-record s" record" record 0 record type -> byte-size peek assert-struct-field
  pet-record s" id" value 0 cell-size assert-struct-field
  pet-record s" first-name" array-type cell-size 64 assert-struct-field
  pet-record s" last-name" array-type cell-size 64 + 64 assert-struct-field
  pet-record s" dob" date cell-size 128 + 6 assert-struct-field
  pet-record s" species" uint<32> cell-size 128 + 6 + 4 assert-struct-field
end

def test-struct-dsl
  test-struct-vec4
  test-struct-vec4-instance
  test-struct-time-integrated
  test-struct-time-integrated-instance
  test-struct-thing
  test-struct-date
  test-struct-record
  test-struct-pet-record
end

