def bound-dict-lookup-by-value ( value last-word current-word offset -- entry true || false )
  ( Search for ~value~ in the dictionary entries inclusively between ~last-word~ and ~current-word~. )
  arg1 0 equals? IF 0 4 return1-n THEN
  arg2 arg1 equals? IF 0 4 return1-n THEN
  arg1 dict-entry-data @ arg3 equals? IF arg1 true 4 return2-n THEN
  arg1 dict-entry-link @ dup IF arg0 + set-arg1 THEN repeat-frame
end
