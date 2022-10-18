( Sorts out which direction to copy bytes in memory and copies them. )
def copy ( src dest num-bytes -- )
  ( [src... ]
    [dest...] )
  arg2 arg1 equals? IF return0 THEN
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

def roll-back-n ( nth ... item n -- item nth ... )
  ( Moves N cells down by one and stores item at the end. )
  ( stash the item )
  arg1
  ( move items down )
  args up-stack
  dup up-stack over arg0 cell-size int-mul copy
  ( store the item )
  arg0 up-stack/2 poke
  1 return0-n
end
