s[ src/lib/math.4th
   src/lib/assert.4th
   src/lib/assertions/float.4th
   src/lib/testing/data-script.4th
] load-list

( Test cases: )

128.0 var> test-float32-big-step-size

( Log: )

def test-log-printer
  arg0 write-float32 space
  ( arg0 float32-ln-1 )
  arg0 float32-ln-1
  arg0 10 int32->float32 float32-logn
  arg0 float32-log2
  arg0 float32-ln
  arg0 float32-exp
  write-float32 space write-float32 space write-float32 space write-float32 space write-float32 nl
  1 return0-n
end

def test-log-output
  s" n        exp      ln         log      log10     ln-1" write-line/2
  0f 2pi 1f 10 int32->float32 float32-div ' test-log-printer map-float32-range
end

def test-float32-ln
  0 0
  s" log" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-ln partial-first set-local1
  ( domain limited to <12 )
  ( local1 0.0 16.0 0.1 float32-stepper )
  0.0 16.0 0.1 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  0.0 0xFFFF int32->float32 test-float32-big-step-size @ local1 map-float32-range
  local0 data-script-kill
end

( todo logn )

def test-float32-log2
  0 0
  s" log2" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-log2 partial-first set-local1
  ( domain limited to <12 )
  ( local1 0.0 16.0 0.1 float32-stepper )
  0.0 16.0 0.1 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  0.0 0xFFFF int32->float32 test-float32-big-step-size @ local1 map-float32-range
  local0 data-script-kill
end

( Exp: )

def test-float32-exp-key-points
  -1 int32->float32 float32-exp float32->int32 0 assert-equals
  0 int32->float32 float32-exp float32->int32 1 assert-equals
  1 int32->float32 float32-exp float32->int32 2 assert-equals
  2 int32->float32 float32-exp float32->int32 7 assert-equals
  3 int32->float32 float32-exp float32->int32 20 assert-equals
  9 int32->float32 float32-exp float32->int32 8103 assert-equals
  10 int32->float32 float32-exp float32->int32 22026 assert-equals
  ( 16 int32->float32 float32-exp float32->int32 8886110 assert-equals
  20 int32->float32 float32-exp float32->int32 485165195 assert-equals )
end

def test-float32-exp
  0 0
  s" exp" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-exp partial-first set-local1
  ( domain limited to <12 )
  ( local1 0.0 16.0 0.1 float32-stepper )
  -20.0 20.0 0.1 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  ( 0.0 0xFFFF int32->float32 1.0 local1 map-float32-range )
  local0 data-script-kill
end

( todo Pow )

( Pow2: )

def test-float32-pow
  0 0
  s" pow" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32-pair local0 partial-first ' float32-pow partial-first 2.0 partial-first set-local1
  -15.0 16.0 0.5 local1 map-float32-range
  ' data-script-assert-float32-pair local0 partial-first ' float32-pow partial-first 2.0 float32-invert partial-first set-local1
  -15.0 16.0 0.5 local1 map-float32-range
  ' data-script-assert-float32-pair local0 partial-first ' float32-pow partial-first 5.5 partial-first set-local1
  -15.0 16.0 0.5 local1 map-float32-range
  ' data-script-assert-float32-pair local0 partial-first ' float32-pow partial-first e partial-first set-local1
  -15.0 16.0 0.5 local1 map-float32-range
  ' data-script-assert-float32-pair local0 partial-first ' float32-pow partial-first -3.
  -15.0 16.0 0.5 local1 map-float32-range
  local0 data-script-kill
end

def test-float32-pow2
  0 0
  s" pow" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32-pair local0 partial-first ' float32-pow partial-first 2.0 partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  -20.0 20.0 0.1 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  ( 0.0 0xFFFF int32->float32 1.0 local1 map-float32-range )
  local0 data-script-kill
end


( Sqrt )

def test-float32-sqrt
  0 0
  s" sqrt" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-sqrt partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  0.0 16.0 0.1 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  0.0 0xFFFF int32->float32 test-float32-big-step-size @ local1 map-float32-range
  local0 data-script-kill
end

( Trigonometry: )

def test-trig-output-printer
  arg0 write-float32 space
  arg0 float32-tan
  arg0 float32-cos-prod
  arg0 float32-cos
  arg0 float32-sin-prod
  arg0 float32-sin
  write-float32 space write-float32 space
  write-float32 space write-float32 space
  write-float32 nl
  1 return0-n
end

def test-trig-output/3
  s" n        sin      sin-prod cos      cos-prod tan" write-line/2
  arg2 arg1 arg0 ' test-trig-output-printer map-float32-range
end

def test-trig-output
  0f 2pi 1f 10 int32->float32 float32-div test-trig-output/3
end

( Sin: )

def test-float32-sin
  0 0
  s" sin" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-sin partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  pi 2.0 float32-mul dup negate swap 0.00138 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  0.0 0xFFFF int32->float32 test-float32-big-step-size @ local1 map-float32-range
  local0 data-script-kill
end

( Cosine: )

def test-float32-cos
  0 0
  s" cos" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-cos partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  pi 2.0 float32-mul dup negate swap 0.00138 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  0.0 0xFFFF int32->float32 test-float32-big-step-size @ local1 map-float32-range
  local0 data-script-kill
end

( Tan: )

def test-float32-tan
  0 0
  s" tan" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-tan partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  pi 2.0 float32-mul dup negate swap 0.00138 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  0.0 0xFFFF int32->float32 test-float32-big-step-size @ local1 map-float32-range
  local0 data-script-kill
end

def test-float32-atan
  0 0
  s" atan" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-atan partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  -1.0 1.0 0.00138 local1 map-float32-range
  local0 data-script-kill
end

( Product series: )

def test-float32-sin-prod
  0 0
  s" sin" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-sin-prod partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  pi 2.0 float32-mul dup negate swap 0.00138 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  0.0 0xFFFF int32->float32 test-float32-big-step-size @ local1 map-float32-range
  local0 data-script-kill
end

( Hyperbolics: )

def test-hyper-output-printer
  arg0 write-float32 space
  arg0 float32-tanh
  arg0 float32-cosh
  arg0 float32-sinh
  write-float32 space write-float32 space
  write-float32 nl
  1 return0-n
end

def test-hyper-output/3
  s" n        sinh     cosh     tanh" write-line/2
  arg2 arg1 arg0 ' test-hyper-output-printer map-float32-range
end

def test-hyper-output
  0f 2pi 1f 10 int32->float32 float32-div test-hyper-output/3
end

( Sinh: )

def test-float32-sinh
  0 0
  s" sinh" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-sinh partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  pi 2.0 float32-mul dup negate swap 0.00138 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  -25.0 25.0 1.0 local1 map-float32-range
  local0 data-script-kill
end

( Cosh: )

def test-float32-cosh
  0 0
  s" cosh" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-cosh partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  pi 2.0 float32-mul dup negate swap 0.00138 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  -25.0 25.0 1.0 local1 map-float32-range
  local0 data-script-kill
end

( Tanh: )

def test-float32-tanh
  0 0
  s" tanh" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-tanh partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  pi 2.0 float32-mul dup negate swap 0.00138 local1 map-float32-range
  ( local1 0.0 0xFFFF int32->float32 1.0 float32-stepper )
  ( awk errors after 709 )
  709 int32->float32 dup float32-negate swap 1.0 local1 map-float32-range
  local0 data-script-kill
end

def test-float32-atanh
  0 0
  s" atanh" data-script-spawn
  IF set-local0 ELSE s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-float32 local0 partial-first ' float32-atanh partial-first set-local1
  ( local1 0.0 16.0 0.1 float32-stepper )
  -1.0 1.0 0.00138 local1 map-float32-range
  local0 data-script-kill
end

def test-float32
  test-float32-ln
  test-float32-log2
  test-float32-exp-key-points
  test-float32-exp
  test-float32-pow
  test-float32-pow2
  test-float32-sqrt
  test-float32-sin
  test-float32-cos
  test-float32-tan
  test-float32-atan
  ( test-float32-sin-prod )
  test-float32-sinh
  test-float32-cosh
  test-float32-tanh
  ( test-float32-atanh )
end

def test-float32-manually
  test-log-output
  test-trig-output
  test-hyper-output
end
