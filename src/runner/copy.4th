( Sorts out which direction to copy bytes in memory and copies them. )
def copy ( src dest num-bytes -- )
  ( [src... ]
    [dest...] )
  arg2 arg1 equals? IF 3 return0-n THEN
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

def reverse-cells! ( ptr length -- )
  arg1 arg0 1 int-sub cell-size int-mul int-add arg1 arg0 nreverse-cells
  2 return0-n
end

def reverse-bytes! ( ptr length -- )
  arg1 arg0 1 int-sub int-add arg1 arg0 nreverse-bytes
  2 return0-n
end

