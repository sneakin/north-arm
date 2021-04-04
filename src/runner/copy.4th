( Sorts out which direction to copy bytes in memory and copies them. )
def copy ( src dest num-bytes -- )
  ( [src... ]
    [dest...] )
  arg2 arg1 equals? IF return THEN
  (        [ src... ]
        -->
      [ dest.. ] )
  arg2 arg1
  arg1 arg2 uint<= IF arg0 copy-up
  ( [ src... ]
       <---
       [ dest... ] )
  ELSE arg0 copy-down
  THEN 3 return0-n
end
