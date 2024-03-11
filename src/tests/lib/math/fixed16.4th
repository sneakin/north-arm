s[ src/lib/math/32/fixed16.4th
   src/lib/linux/clock.4th
   src/lib/process.4th
   src/lib/assert.4th
   src/lib/assertions/float.4th
   src/lib/assertions/fixed16.4th
   src/lib/testing/data-script.4th
] load-list

def test-fixed16-conversions
  ( int32->fixed16 )
  s" i32" write-line/2
  0 int32->fixed16 0 assert-fixed16-equals
  1 int32->fixed16 fixed16-one assert-fixed16-equals
  -1 int32->fixed16 fixed16-one negate assert-fixed16-equals
  0x7FFF int32->fixed16 0x7FFF0000 assert-fixed16-equals
  0x7FFF negate int32->fixed16 0x80010000 assert-fixed16-equals
  ( out of range errors? )
  0x8000 int32->fixed16 0x7FFFFFFF assert-fixed16-equals
  0x8000 negate int32->fixed16 0x80000000 assert-fixed16-equals

  ( big uint32->fixed16 )
  s" u32" write-line/2
  0 uint32->fixed16 0 assert-fixed16-equals
  1 uint32->fixed16 fixed16-one assert-fixed16-equals
  0x7FFF uint32->fixed16 0x7FFF0000 assert-fixed16-equals
  0x8000 uint32->fixed16 0x80000000 assert-fixed16-equals
  0xFFFF uint32->fixed16 0xFFFF0000 assert-fixed16-equals
  ( out of range errors? )
  -1 uint32->fixed16 0xFFFF0000 assert-fixed16-equals
  0x7FFF negate uint32->fixed16 0x80010000 assert-fixed16-equals
  0x8000 negate uint32->fixed16 0x80000000 assert-fixed16-equals

  ( +/- float32->fixed16 )
  s" f32" write-line/2
  0f float32->fixed16 0 assert-fixed16-equals
  1f float32->fixed16 0x10000 assert-fixed16-equals
  -1f float32->fixed16 0x10000 fixed16-negate assert-fixed16-equals
  2f float32->fixed16 0x20000 assert-fixed16-equals
  0.5f float32->fixed16 0x8000 assert-fixed16-equals
  float32-infinity float32->fixed16 0x7FFFFFFFF assert-fixed16-equals
  float32-infinity float32-negate float32->fixed16 0x80000000 assert-fixed16-equals
  pi float32->fixed16 0x3243f assert-fixed16-equals
  float32-nan float32->fixed16 0 assert-fixed16-equals
  
  ( +/- fixed16->float32 )
  s" ->f32" write-line/2
  0 fixed16->float32 0f assert-float32-equals
  fixed16-one fixed16->float32 1f assert-float32-equals
  fixed16-one negate fixed16->float32 -1f assert-float32-equals
  fixed16-pi fixed16->float32 pi 2 fixed16->float32 assert-float32-within
  0x7FFFFFFF fixed16->float32 0x7FFFFFFF int32->float32 0x10000 int32->float32 float32-div assert-float32-equals
  0x80000001 fixed16->float32 0x7FFFFFFF negate int32->float32 0x10000 int32->float32 float32-div assert-float32-equals
  
  ( +/- ufixed16->float32 )
  s" u32->f32" write-line/2
  0x7FFFFFFF ufixed16->float32 0x7FFFFFFF uint32->float32 0x10000 int32->float32 float32-div assert-float32-equals
  0x80000001 ufixed16->float32 0x80000001 uint32->float32 0x10000 int32->float32 float32-div assert-float32-equals
  0xFFFFFFFF ufixed16->float32 0xFFFFFFFF uint32->float32 0x10000 int32->float32 float32-div assert-float32-equals

  ( +/- float32->ufixed16 )
  s" f32->UF" write-line/2
  float32-infinity float32->ufixed16 0xFFFFFFFFF assert-fixed16-equals
  float32-infinity float32-negate float32->ufixed16 0 assert-fixed16-equals
  float32-nan float32->ufixed16 0 assert-fixed16-equals
end

(
def test-fixed16-comparisons
  fixed16<
  fixed16<=
  fixed16>
  fixed16>=
end

def test-ufixed16-comparisons
  ufixed16<
  ufixed16<=
  ufixed16>
  ufixed16>=
end

def test-fixed16-parts
  +/- fixed16-truncate
  +/- fixed16-fraction
end

def test-fixed16-rounding
  +/- floor
  +/- ceil
  +/- round
end
)

def assert-int-binary-op-by-table ( table num-rows fn -- )
  arg1 0 uint> UNLESS 3 return0-n THEN
  arg1 1 - set-arg1
  arg2 arg1 3 * cell-size * +
  dup @
  swap dup cell-size 2 * + @
  swap cell-size + @
  arg0 exec-abs assert-equals
  repeat-frame
end

def test-fixed16-add
  0 0 0
  0 0x100000 0x100000
  0x100000 0 0x100000
  0 -0x100000 -0x100000
  -0x100000 0 -0x100000
  0x10000 0x10000 0x20000
  -0x50000 0x8000 -0x48000
  0x7fff0000 0x20000 0x80010000
  0x7ffff 1 0x80000
  -0x7fff0000 0x20000 -0x7ffd0000
  -0x7ffff 1 -0x7fffe
  0x7fffffff 0x7fffffff 0xFFFFFFFE
  here 12 ' fixed16-add assert-int-binary-op-by-table
end

def test-fixed16-sub
  0 0 0
  0 0x100000 -0x100000
  0x100000 0 0x100000
  0 -0x100000 0x100000
  -0x100000 0 -0x100000
  0x10000 0x10000 0x0
  -0x50000 0x8000 -0x58000
  0x7fff0000 0x20000 0x7ffd0000
  0x7ffff 1 0x7fffe
  -0x7fff0000 0x20000 -0x80010000
  -0x7ffff 1 -0x80000
  0x7fffffff 0x7fffffff 0
  here 12 ' fixed16-sub assert-int-binary-op-by-table
end

def test-fixed16-mul
  0 0 0
  0 0x100000 0
  0x100000 0 0
  0 -0x100000 0
  -0x100000 0 0
  0x10000 0x100000 0x100000
  0x100000 0x10000 0x100000
  0x10000 -0x100000 -0x7FEF0000
  -0x100000 0x10000 -0x7FEF0000
  -0x100000 -0x10000 0x7FEF0000
  0x10000 0x10000 0x10000
  -0x50000 0x8000 -0x28000
  0x7fff0000 0x20000 0xfffe0000
  0x7ffff 1 0x7
  -0x7fff0000 0x20000 -0xfffe0000
  -0x7ffff 1 -0x8
  0x7fffffff 0x7fffffff 0xFFFF0000
  here 17 ' fixed16-mul assert-int-binary-op-by-table
end

def test-fixed16-div
  0 0 0
  0 0x100000 0
  0x100000 0 0 ( todo error )
  0 -0x100000 0
  -0x100000 0 0 ( err here too )
  0x10000 0x100000 0x1000
  0x100000 0x10000 0x100000
  0x10000 -0x100000 -0x1000
  -0x100000 0x10000 -0x100000
  -0x100000 -0x10000 0x100000
  0x10000 0x10000 0x10000
  -0x50000 0x8000 -0xA0000
  0x7fff0000 0x20000 0x3fff8000
  0x7ffff 1 0x7ffff0000
  -0x7fff0000 0x20000 -0x3fff0000
  -0x7ffff 1 -0x7ffff0000
  0x7fffffff 0x7fffffff 0x10000
  here 17 ' fixed16-div assert-int-binary-op-by-table
end

def test-fixed16-divmod
end

def test-fixed16-mod
end

def test-fixed16-reciprocal
end

def test-ufixed16-sub
end

def test-ufixed16-mul
end

def test-ufixed16-div
end

def test-ufixed16-divmod
end

def test-ufixed16-mod
end

def test-ufixed16-reciprocal
end

def test-fixed16-to-string
end

def test-fixed16-exp
  0 0
  s" exp" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed16 local0 partial-first ' exp-fixed16 partial-first set-local1
  local1 -1 int32->fixed16 1 int32->fixed16 0.1 float32->fixed16 fixed16-stepper
  local1 -12 int32->fixed16 12 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  local0 data-script-kill
end

def test-fixed16-ln
  0
  s" log" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed16 local0 partial-first ' ln-fixed16 partial-first
  0 int32->fixed16 12 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  local0 data-script-kill
end

def test-fixed16-pow
  0 0
  s" pow" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed16-pair local0 partial-first ' pow-fixed16 partial-first 2 int32->fixed16 partial-first set-local1
  local1 -15 int32->fixed16 16 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  ' data-script-assert-fixed16-pair local0 partial-first ' pow-fixed16 partial-first 2 int32->fixed16 fixed16-reciprocal partial-first set-local1
  local1 -15 int32->fixed16 16 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  ' data-script-assert-fixed16-pair local0 partial-first ' pow-fixed16 partial-first 55 int32->fixed16 10 int32->fixed16 fixed16-div partial-first set-local1
  local1 -15 int32->fixed16 16 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  ' data-script-assert-fixed16-pair local0 partial-first ' pow-fixed16 partial-first fixed16-e partial-first set-local1
  local1 -15 int32->fixed16 16 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  ' data-script-assert-fixed16-pair local0 partial-first ' pow-fixed16 partial-first -3 int32->fixed16 partial-first set-local1
  local1 -15 int32->fixed16 16 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  local0 data-script-kill
end

def test-fixed16-pow2
  0 0
  s" pow2" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed16 local0 partial-first ' pow2-fixed16 partial-first set-local1
  local1 -16 int32->fixed16 16 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  local0 data-script-kill
end

def test-fixed16-log2
  0
  s" log2" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed16 local0 partial-first ' log2-fixed16 partial-first
  0 int32->fixed16 12 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  local0 data-script-kill
end

def test-fixed16-sqrt
  0 0
  s" sqrt" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed16 local0 partial-first ' sqrt-fixed16 partial-first set-local1
  local1 0 int32->fixed16 16 int32->fixed16 0.25 float32->fixed16 fixed16-stepper
  local1 16 int32->fixed16 0xFFFF int32->fixed16 64.0 float32->fixed16 fixed16-stepper
  local0 data-script-kill
end

def test-fixed16
  test-fixed16-conversions
  test-fixed16-add
  test-fixed16-sub
  test-fixed16-mul
  test-fixed16-div
  test-fixed16-exp
  test-fixed16-ln
  test-fixed16-pow
  test-fixed16-pow2
  test-fixed16-log2
  test-fixed16-sqrt
end
