DEFINED? fixed16-add UNLESS s" src/lib/math/32/fixed16.4th" load/2 THEN
DEFINED? process-spawn-cmd UNLESS s" src/lib/process.4th" load/2 THEN
DEFINED? assert UNLESS s" src/lib/assert.4th" load/2 THEN
DEFINED? assert-float32-equals UNLESS s" src/lib/assertions/float.4th" load/2 THEN
DEFINED? assert-fixed16-equals UNLESS s" src/lib/assertions/fixed16.4th" load/2 THEN

1000 var> data-script-timeout-msecs
0.001 var> data-script-float32-margin
1310 ( 0.02 ) var> data-script-fixed16-margin

def data-script-query-float32 ( n process -- result read-n true | false)
  0 128 stack-allot-zero set-local0
  local0 128 arg1 9 float32->string/4 arg0 process-write-line
  local0 128 arg0 data-script-timeout-msecs @ process-read-line/4
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

def data-script-query-fixed16 ( n process -- result read-n true | false)
  0 128 stack-allot-zero set-local0
  local0 128 arg1 9 fixed16->string/4 arg0 process-write-line
  local0 128 arg0 data-script-timeout-msecs @ process-read-line/4
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

def data-script-query-ufixed16 ( n process -- result read-n true | false)
  0 128 stack-allot-zero set-local0
  local0 128 arg1 9 ufixed16->string/4 arg0 process-write-line
  local0 128 arg0 data-script-timeout-msecs @ process-read-line/4
  dup 0 int<= UNLESS
    local0 over ' is-space? string-split/3
    over 1 uint> IF
      dup 1 seqn-peek over 0 seqn-peek parse-ufixed16 drop
      over 3 seqn-peek 3 overn 2 seqn-peek parse-fixed16 drop
      set-arg1 set-arg0 true return1
    ELSE s" Error processing script output." error-line/2
    THEN
  ELSE s" Error reading from script." error-line/2
  THEN false 2 return1-n
end

def data-script-query-fixed16-pair ( a b process -- result read-a read-b true | false)
  0 128 stack-allot-zero set-local0
  local0 128 arg2 9 fixed16->string/4 arg0 process-write
  s"  " arg0 process-write
  local0 128 arg1 9 fixed16->string/4 arg0 process-write-line
  local0 128 arg0 data-script-timeout-msecs @ process-read-line/4
  dup 0 int<= UNLESS
    local0 over ' is-space? string-split/3
    over 1 uint> IF
      dup 1 seqn-peek over 0 seqn-peek parse-fixed16 drop
      over 3 seqn-peek 3 overn 2 seqn-peek parse-fixed16 drop
      3 overn 5 seqn-peek 4 overn 4 seqn-peek parse-fixed16 drop
      set-arg2 set-arg1 set-arg0 true return1
    ELSE s" Error processing script output." error-line/2
    THEN
  ELSE s" Error reading from script." error-line/2
  THEN false 3 return1-n
end

def data-script-query-float32-pair ( a b process -- result read-a read-b true | false)
  0 128 stack-allot-zero set-local0
  local0 128 arg2 9 float32->string/4 arg0 process-write
  s"  " arg0 process-write
  local0 128 arg1 9 float32->string/4 arg0 process-write-line
  local0 128 arg0 data-script-timeout-msecs @ process-read-line/4
  dup 0 int<= UNLESS
    local0 over ' is-space? string-split/3
    over 1 uint> IF
      dup 1 seqn-peek over 0 seqn-peek parse-float32 drop
      over 3 seqn-peek 3 overn 2 seqn-peek parse-float32 drop
      3 overn 5 seqn-peek 4 overn 4 seqn-peek parse-float32 drop
      set-arg2 set-arg1 set-arg0 true return1
    ELSE s" Error processing script output." error-line/2
    THEN
  ELSE s" Error reading from script." error-line/2
  THEN false 3 return1-n
end

def data-script-assert-float32 ( n fn process -- )
  arg2 arg0 data-script-query-float32 IF
    arg2 assert-float32-equals
    arg2 debug? IF dup write-float32 space THEN arg1 exec-abs
    data-script-float32-margin @ assert-float32-within
  ELSE s" Failed to generate data." error-line/2
  THEN 3 return0-n
end

def data-script-assert-fixed16 ( n fn process -- )
  arg2 arg0 data-script-query-fixed16 IF
    arg2 assert-fixed16-equals
    arg2 debug? IF dup write-fixed16 space THEN
    arg1 exec-abs data-script-fixed16-margin @ assert-fixed16-within
  ELSE s" Failed to generate data." error-line/2
  THEN 3 return0-n
end

def data-script-assert-ufixed16 ( n fn process -- )
  arg2 arg0 data-script-query-ufixed16 IF
    arg2 assert-fixed16-equals
    arg2 debug? IF dup write-ufixed16 space THEN
    arg1 exec-abs data-script-fixed16-margin @ assert-ufixed16-within
  ELSE s" Failed to generate data." error-line/2
  THEN 3 return0-n
end

def data-script-assert-fixed16-pair ( a b fn process -- )
  arg2 arg3 arg0 data-script-query-fixed16-pair IF
    arg2 assert-fixed16-equals
    arg3 assert-fixed16-equals
    arg2 arg3 arg1 exec-abs
    data-script-fixed16-margin @ assert-fixed16-within
  ELSE s" Failed to generate data." error-line/2
  THEN 4 return0-n
end

def data-script-assert-float32-pair ( a b fn process -- )
  arg2 arg3 arg0 data-script-query-float32-pair IF
    arg2 assert-float32-equals
    arg3 assert-float32-equals
    arg2 arg3 arg1 exec-abs
    data-script-float32-margin @ assert-float32-within
  ELSE s" Failed to generate data." error-line/2
  THEN 4 return0-n
end

def data-script-kill ( process -- )
  arg0 process-kill arg0 process-wait
  1 return0-n
end

" awk -f ./scripts/math-fn-data-gen.awk" var> data-script-path

def data-script-spawn ( mode mode-len ++ process true || false )
  s" Starting data script in mode " error-string/2
  arg1 arg0 error-line/2
  data-script-path @ process-spawn-cmd
  dup UNLESS false 2 return1-n THEN
  s" mode " 3 overn process-write
  0 int<= IF data-script-kill false 2 return1-n THEN
  arg1 arg0 3 overn process-write-line
  0 int<= IF data-script-kill false 2 return1-n THEN
  true exit-frame
end
