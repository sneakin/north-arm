s[ src/lib/assert.4th
   src/lib/assertions/float.4th
] load-list

def test-parse-float32
  s" 3" parse-float32 assert 3 int32->float32 assert-float32-equals
  s" 3.3" parse-float32 assert 33 int32->float32 10 int32->float32 float32-div assert-float32-equals
  s" +345" parse-float32 assert 345 int32->float32 assert-float32-equals
  s" +345.345" parse-float32 assert 345345 int32->float32 1000 int32->float32 float32-div assert-float32-equals
  s" -3" parse-float32 assert -3 int32->float32 assert-float32-equals
  s" -3.3" parse-float32 assert -33 int32->float32 10 int32->float32 float32-div assert-float32-equals

  input-base @
  16 input-base !
  s" A0" parse-float32 assert 0xA0 int32->float32 assert-float32-equals
  s" A.A" parse-float32 assert 0xAA int32->float32 16 int32->float32 float32-div assert-float32-equals
  2 input-base !
  s" 101.01" parse-float32 assert 525 int32->float32 100 int32->float32 float32-div assert-float32-equals
  input-base !

  s" .f" parse-float32 assert-not 0 int32->float32 assert-float32-equals
  s" " parse-float32 assert-not 0 int32->float32 assert-float32-equals
  s" xyz" parse-float32 assert-not 0 int32->float32 assert-float32-equals
  s" 34.56.78" parse-float32 assert-not 0 int32->float32 assert-float32-equals
  s" 34...56" parse-float32 assert-not 0 int32->float32 assert-float32-equals
end
