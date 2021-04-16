s[ src/lib/math.4th src/lib/assert.4th ] load-list

( Test cases: )

def map-float32-range ( init max step fn )
  arg3 arg0 exec-abs
  arg3 arg1 float32-add set-arg3
  arg3 arg2 float32< IF repeat-frame ELSE exit-frame THEN
end

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

def test-float32-exp
  -1 float32-exp float32->int32 0 assert-equals
  0 float32-exp float32->int32 1 assert-equals
  1 float32-exp float32->int32 2 assert-equals
  2 float32-exp float32->int32 7 assert-equals
  3 float32-exp float32->int32 20 assert-equals
  9 float32-exp float32->int32 8193 assert-equals
  10 float32-exp float32->int32 59874 assert-equals
end

def test-pow-output-printer
  arg0 write-float32 space
  2f arg0 float32-pow-rep
  e arg0 float32-pow-rep
  2f arg0 float32-pow
  e arg0 float32-pow
  arg0 float32-exp
  write-float32 space write-float32 space
  write-float32 space write-float32 space
  write-float32 nl
  1 return0-n
end

def test-pow-output/3
  s" n        exp      pow      exp-pow" write-line/2
  arg2 arg1 arg0 ' test-pow-output-printer map-float32-range
end

def test-pow-output
  0f 2pi 1f 10 int32->float32 float32-div test-pow-output/3
end

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

def test-square-printer
  arg0 write-float32 space
  arg0 float32-sqrt write-float32 nl
  1 return0-n
end

def test-sqrt-output
  s" n        sqrt" write-line/2
  0f 2pi 1f 10 int32->float32 float32-div ' test-square-printer map-float32-range
end
