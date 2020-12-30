def test-string-index-of
  s" hello world"
  2dup literal is-space? string-index-of IF int32 5 equals? IF what ELSE crap THEN ELSE crap THEN
  2dup literal whitespace? string-index-of IF int32 5 equals? IF what ELSE crap THEN ELSE crap THEN
  ( Todo
  2dup ' whitespace? string-index-of IF int32 5 equals? IF what ELSE crap THEN ELSE crap THEN
  2dup [ whitespace? not ] string-index-of IF int32 5 equals? IF what ELSE crap THEN ELSE crap THEN
  )
  literal newline? string-index-of IF crap ELSE what THEN  
end
