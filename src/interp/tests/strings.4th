" src/lib/assert.4th" load

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
