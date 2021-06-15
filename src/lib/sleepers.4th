( Condition waiting: )

( Sleep in 1 second intervals until the value becomes true or the timeout is surpassed. Wait forever if ~timeout~ is negative. )
def sleep-until-true/2 ( value-ptr timeout -- value )
  arg1 peek dup IF 2 return1-n ELSE drop THEN
  arg0 negative? IF drop ELSE 1 - set-arg0 THEN
  arg0 0 equals? IF false 2 return1-n THEN
  1 sleep repeat-frame
end
