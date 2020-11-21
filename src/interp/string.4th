def string-index-of/4 ( ptr len predicate position )
  arg0 arg2 int<= UNLESS int32 0 return1 THEN
  arg3 arg0 string-peek arg1 exec IF int32 1 return1 THEN
  arg0 int32 1 + set-arg0
  drop-locals repeat-frame
end

defcol string-index-of ( ptr len predicate -- index )
  int32 4 overn int32 4 overn int32 4 overn
  int32 0
  string-index-of/4 ( ptr len pred ra ptr len pred index match )
  int32 7 set-overn
  int32 7 set-overn
  int32 3 dropn
  swap drop
endcol

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
