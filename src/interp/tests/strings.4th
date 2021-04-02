" src/lib/assert.4th" load

def test-copy-byte-string
  0
  32 stack-allot set-local0
  s" hello" local0 swap 1 + copy-byte-string/3
  local0 write-line
  local0 5 assert-string-null-terminated 2 dropn
  local0 s" hello" assert-byte-string-equals/3

  local0 local0 5 + 6 copy-byte-string/3
  local0 write-line
  local0 10 assert-string-null-terminated 2 dropn
  local0 s" hellohello" assert-byte-string-equals/3

  local0 2 + local0 5 copy-byte-string/3
  local0 write-line
  local0 10 assert-string-null-terminated 2 dropn
  local0 s" llohehello" assert-byte-string-equals/3
end

def test-string-index-of
  s" hello world"
  2dup literal is-space? string-index-of
  assert
  5 assert-equals
  2dup literal whitespace? string-index-of
  assert
  5 assert-equals
  ( Todo
  2dup ' whitespace? string-index-of IF int32 5 equals? IF what ELSE crap THEN ELSE crap THEN
  2dup [ whitespace? not ] string-index-of IF int32 5 equals? IF what ELSE crap THEN ELSE crap THEN
  )
  literal newline? string-index-of assert-not
end

def test-string-contains?
  s" hello world. how are you?"
  2dup s" how" 0 string-contains?/5
  13 assert-equals

  2dup s" you?" 0 string-contains?/5
  21 assert-equals

  2dup s" h" 0 string-contains?/5
  0 assert-equals

  2dup s" " 0 string-contains?/5
  0 assert-equals

  2dup s" howdy" 0 string-contains?/5
  -1 assert-equals
  2dup s" bye" 0 string-contains?/5
  -1 assert-equals

  2dup s" hello" 2swap 0 string-contains?/5
  -1 assert-equals
end

def test-string-append
  0 0
  32 stack-allot-zero set-local0
  ( basic append )
  local0 32 s" hello " s" world" string-append/5
  dup set-local1
  2dup write-line/2
  assert-string-null-terminated
  2dup s" hello world" assert-byte-string-equals/4
  ( append to target )
  local0 32 local0 local1 s" !! " string-append/5
  dup set-local1
  2dup write-line/2
  assert-string-null-terminated
  2dup s" hello world!! " assert-byte-string-equals/4
  ( append target to target )
  local0 32 local0 local0 string-append/4
  dup set-local1
  2dup write-line/2
  assert-string-null-terminated
  2dup s" hello world!! hello world!! " assert-byte-string-equals/4
  ( overflowing the target )
  local0 32 local0 local0 string-append/4
  2dup write-line/2
  assert-string-null-terminated
  2dup s" hello world!! hello world!! he" assert-byte-string-equals/4
  ( prepend target )
  local0 32 s" You! " local0 local1 string-append/5
  dup set-local1
  2dup write-line/2
  assert-string-null-terminated
  2dup s" You! hello world!! hello world" assert-byte-string-equals/4
  ( more )
  local0 32 s" Hello" s"  " string-append/5
  2dup write-line/2
  local0 32 2swap s" World" string-append/5
  2dup write-line/2
  s" Hello World" assert-byte-string-equals/4
  ( more )
  local0 13 s" Hello" s"  " string-append/5
  2dup write-line/2
  local0 13 2swap s" World" string-append/5
  2dup write-line/2
  s" Hello World" assert-byte-string-equals/4
  ( more )
  local0 12 s" Hello" s"  " string-append/5
  2dup write-line/2
  local0 12 2swap s" World" string-append/5
  2dup write-line/2
  s" Hello Worl" assert-byte-string-equals/4
end
