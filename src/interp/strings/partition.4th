def string-partitioner/3 ( str len predicate -- part part-len rest rest-len )
  ( Scans the string until the predicate is true and returns the characters before and after that point as string+length pairs. )
  arg2 arg1 arg0 string-index-of
  negative? IF
    0 set-arg0 0 return1
  ELSE
    arg1 over -
    arg2 3 overn +
    3 overn
    set-arg1 set-arg0 return1
  THEN
end

def string-partition/3 ( str len predicate -- post post-len delim delim-len pre pre-len )
  ( Scans the string until the predicate is true, then continues scanning vith the predicane negated, and finally returns string+length pairs for the before, during, and after the point the predicate toggled. )
  0 arg0 ' not compose set-local0
  arg2 arg1 arg0 string-partitioner/3
  dup 0 equals? IF 0 0 ELSE local0 string-partitioner/3 THEN
  set-arg1 set-arg2
  swap set-arg0 shift return3
end

def string-split/4 ( str len predicate counter ++ parts... num-parts here )
  arg2 0 equals? arg3 0 equals? or
  IF here arg0 2 * reverse 2 dropn arg0 here exit-frame THEN
  arg3 arg2 arg1 string-partition/3
  ( leading spaces )
  dup 0 equals? IF
    4 dropn
  ELSE
    ( drop the delimeter and ready the tail )
    swap 2swap 2 dropn 2swap
    arg0 1 + set-arg0
  THEN set-arg2 set-arg3 repeat-frame
end

def string-split/3 ( str len predicate ++ parts... num-parts here )
  0 ' string-split/4 tail+1
end
