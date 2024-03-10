" src/lib/assert.4th" load

def test-string-peek
  0 0 string-peek 0 assert-equals
  " " 0 string-peek 0 assert-equals
  " a" 0 string-peek 97 assert-equals
  ( todo test negative, huge, indexes? )
end

def test-string-poke
  s" hey"
  11 41 0 0 string-poke 11 assert-equals
  11 72 local0 0 string-poke 11 assert-equals
  local0 0 string-peek 72 assert-equals
  11 69 local0 1 string-poke 11 assert-equals
  local0 1 string-peek 69 assert-equals
  ( todo test negative, huge, indexes? )
end

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
  2dup ' is-space? string-index-of 5 assert-equals
  2dup ' whitespace? string-index-of 5 assert-equals
  ( Todo
  2dup ' whitespace? string-index-of IF int32 5 equals? IF what ELSE crap THEN ELSE crap THEN
  2dup [ whitespace? not ] string-index-of IF int32 5 equals? IF what ELSE crap THEN ELSE crap THEN
  )
  2dup ' newline? string-index-of -1 assert-equals
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

def test-byte-string-compare/2
  0 0 byte-string-compare/2 0 assert-equals
  " " " " byte-string-compare/2 0 assert-equals
  " a" " " byte-string-compare/2 -1 assert-equals
  " " " a" byte-string-compare/2 1 assert-equals
  " abc" " def" byte-string-compare/2 1 assert-equals
  " def" " abc" byte-string-compare/2 -1 assert-equals
  " hello" " hello" byte-string-compare/2 0 assert-equals
  " hello" " hello?" byte-string-compare/2 1 assert-equals
  " hello?" " hello" byte-string-compare/2 -1 assert-equals
  " hello!" " hello?" byte-string-compare/2 1 assert-equals
end

def test-string-partition
  s" hello   there" ' is-space? string-partition/3
  s" hello" assert-byte-string-equals/4
  s"    " assert-byte-string-equals/4
  s" there" assert-byte-string-equals/4

  s"   hello there" ' is-space? string-partition/3
  s" " assert-byte-string-equals/4
  s"   " assert-byte-string-equals/4
  s" hello there" assert-byte-string-equals/4

  s" " ' is-space? string-partition/3
  s" " assert-byte-string-equals/4
  0 0 assert-byte-string-equals/4
  0 0 assert-byte-string-equals/4  

  s" hello" ' is-space? string-partition/3
  s" hello" assert-byte-string-equals/4
  0 0 assert-byte-string-equals/4
  0 0 assert-byte-string-equals/4

  s" hello    " ' is-space? string-partition/3
  s" hello" assert-byte-string-equals/4
  s"     " assert-byte-string-equals/4
  s" " assert-byte-string-equals/4
end

def test-string-split
  s" hello world. how are you?" ' is-space? string-split/3
  here cell-size + assert-equals
  5 assert-equals
  s" hello" assert-byte-string-equals/4
  s" world." assert-byte-string-equals/4
  s" how" assert-byte-string-equals/4
  s" are" assert-byte-string-equals/4
  s" you?" assert-byte-string-equals/4

  s" " ' is-space? string-split/3
  here cell-size + assert-equals
  0 assert-equals

  s"    " ' is-space? string-split/3
  here cell-size + assert-equals
  0 assert-equals
end

def test-strings
  test-string-peek
  test-string-poke
  test-copy-byte-string
  test-string-index-of
  test-string-contains?
  test-string-append
  test-byte-string-compare/2
  test-string-partition
  test-string-split
end
