s[ src/lib/math/32/fixed16.4th
   src/lib/assert.4th
   src/lib/assertions/float.4th
   src/lib/linux/clock.4th
   src/lib/process.4th
] load-list

: write-fixed16-binop-message
  swap write-fixed16 write-string write-fixed16
;

: assert-fixed16-equals
  2dup equals dup assert IF
    2 dropn
  ELSE
    space "  != " write-fixed16-binop-message nl
  THEN
;

: assert-fixed16-not-equals
  2dup equals not dup assert IF
    2 dropn
  ELSE
    space "  == " write-fixed16-binop-message nl
  THEN
;

: assert-fixed16-within ( a b epsilon -- )
  3 overn 3 overn fixed16-sub fixed16-abs fixed16>=
  dup assert IF
    2 dropn
  ELSE
    space "  ≇ " write-fixed16-binop-message nl
  THEN
;

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

def test-fixed16-add
end

def test-fixed16-sub
end

def test-fixed16-mul
end

def test-fixed16-div
end

def test-fixed16-divmod
end

def test-fixed16-mod
end

def test-fixed16-reciprocal
end

def test-fixed16-to-string
end

def data-script-write-float ( n process -- result read-n true | false)
  0 128 stack-allot-zero set-local0
  local0 128 arg1 float32->string arg0 process-write-line
  2 sleep
  local0 128 arg0 process-read-line
  dup 0 int<= UNLESS
    local0 over ' is-space? string-split/3
    over 1 uint> IF
      dup 1 seqn-peek over 0 seqn-peek parse-float32 drop
      over 3 seqn-peek 3 overn 2 seqn-peek parse-float32 drop
      set-arg1 set-arg0 true return1
    ELSE s" Error processing script output." error-line/2
    THEN
  ELSE s" Error reading from script." error-line/2
  THEN false 2 return1-n
end

def data-script-write-fixed16 ( n process -- result read-n true | false)
  0 128 stack-allot-zero set-local0
  local0 128 arg1 fixed16->string arg0 process-write-line
  1 sleep ( fixme blocking process reads? )
  local0 128 arg0 process-read-line
  dup 0 int<= UNLESS
    local0 over ' is-space? string-split/3
    over 1 uint> IF
      dup 1 seqn-peek over 0 seqn-peek parse-fixed16 drop
      over 3 seqn-peek 3 overn 2 seqn-peek parse-fixed16 drop
      set-arg1 set-arg0 true return1
    ELSE s" Error processing script output." error-line/2
    THEN
  ELSE s" Error reading from script." error-line/2
  THEN false 2 return1-n
end

def data-script-assert-fixed ( n fn process -- )
  arg2 arg0 data-script-write-fixed16 IF
    arg2 assert-fixed16-equals
    arg2 arg1 exec-abs 655 ( 0.01 ) assert-fixed16-within
  ELSE s" Failed to generate data." error-line/2
  THEN 3 return0-n
end

def test-fixed16-exp-fn ( n process -- )
  arg1 arg0 data-script-write-fixed16 IF
    arg1 assert-fixed16-equals
    arg1 exp-fixed16 655 ( 0.01 ) assert-fixed16-within
    true
  ELSE s" Failed to generate data." error-line/2 false
  THEN 2 return1-n
end

def test-fixed16-exp
  0 0
  " awk -vfn=exp -f ./scripts/math-fn-data-gen.awk" process-spawn-cmd set-local0
  local0 UNLESS s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed local0 partial-first ' exp-fixed16 partial-first set-local1
  local1 -1 int32->fixed16 1 int32->fixed16 0.1 float32->fixed16 fixed16-stepper
  local1 -8 int32->fixed16 12 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  local0 process-kill local0 process-wait
end

def test-fixed16-ln-fn ( n process -- )
  arg1 arg0 data-script-write-fixed16 IF
    arg1 assert-fixed16-equals
    arg1 ln-fixed16 655 ( 0.01 ) assert-fixed16-within
    true
  ELSE s" Failed to generate data." error-line/2 false
  THEN 2 return1-n
end

def test-fixed16-ln
  0
  " awk -vfn=log -f ./scripts/math-fn-data-gen.awk" process-spawn-cmd set-local0
  local0 UNLESS s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed local0 partial-first ' ln-fixed16 partial-first
  0 int32->fixed16 12 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  local0 process-kill local0 process-wait
end

def test-fixed16-pow
end

def test-fixed16-pow2
  0
  " awk -vfn=pow2 -f ./scripts/math-fn-data-gen.awk" process-spawn-cmd set-local0
  local0 UNLESS s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed local0 partial-first ' pow2-fixed16 partial-first
  0 int32->fixed16 16 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  local0 process-kill local0 process-wait
end

def test-fixed16-log2
  0
  " awk -vfn=log2 -f ./scripts/math-fn-data-gen.awk" process-spawn-cmd set-local0
  local0 UNLESS s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed local0 partial-first ' log2-fixed16 partial-first
  0 int32->fixed16 12 int32->fixed16 0.5 float32->fixed16 fixed16-stepper
  local0 process-kill local0 process-wait
end

def test-fixed16-sqrt-fn ( n process -- )
  arg1 arg0 data-script-write-fixed16 IF
    arg1 assert-fixed16-equals
    arg1 sqrt-fixed16 655 ( 0.01 ) assert-fixed16-within
    true
  ELSE s" Failed to generate data." error-line/2 false
  THEN 2 return1-n
end

def test-fixed16-sqrt
  0 0
  " awk -vfn=sqrt -f ./scripts/math-fn-data-gen.awk" process-spawn-cmd set-local0
  local0 UNLESS s" Failed to start script." error-line/2 return0 THEN
  ' data-script-assert-fixed local0 partial-first ' sqrt-fixed16 partial-first set-local1
  local1 0 int32->fixed16 16 int32->fixed16 0.25 float32->fixed16 fixed16-stepper
  local1 16 int32->fixed16 0xFFFF int32->fixed16 64.0 float32->fixed16 fixed16-stepper
  local0 process-kill local0 process-wait
end

