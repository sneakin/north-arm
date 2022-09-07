def seq-peek ( seq n -- value )
  arg1 arg0 peek-off 2 return1-n
end

def seq-poke ( value base n -- )
  arg2 arg1 arg0 poke-off
  3 return0-n
end

def seqn-size arg0 peek set-arg0 end

def seqn-peek ( seq n -- value )
  arg0 1 + arg1 peek-off
  2 return1-n
end

( Filling: )

def fill-seq ( seq n value -- )
  arg1 0 int> UNLESS 3 return0-n THEN
  arg1 1 - set-arg1
  arg0 arg2 arg1 seq-poke
  repeat-frame
end
