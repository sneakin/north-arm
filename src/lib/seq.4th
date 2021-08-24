( Sequences: )

def first arg0 cell-size + peek set-arg0 end
def rest arg0 cell-size + set-arg0 end

def seq-nth ( seq n -- addr )
  arg0 cell-size * arg1 +
  2 return1-n
end

def seq-peek ( seq n -- value )
  arg1 cell-size * arg0 peek-off
  2 return1-n
end

def seq-poke ( value base n -- )
  arg2 arg1 arg0 cell-size * poke-off
  3 return0-n
end

def make-seqn args return1 end
def seqn-size arg0 peek set-arg0 end
def seqn-nth arg0 1 + cell-size * arg1 + return1 end

def seqn-peek ( seq n -- value )
  arg1 arg0 1 + cell-size * peek-off
  2 return1-n
end

def seqn-poke ( value base n -- )
  arg2 arg1 arg0 1 + cell-size poke-off
  3 return0-n
end

def generate-seq/3 ( fn seq size ++ seq )
  arg0 1 - set-arg0
  arg0 arg2 exec-abs arg1 arg0 seq-poke
  arg0 0 uint> IF repeat-frame ELSE arg1 exit-frame THEN
end

( Iteration: )

def map-seq-n/4 ( ptr n state fn )
  arg2 0 int> IF
    arg1 arg3 peek arg0 exec-abs set-arg1
    arg3 rest set-arg3
    arg2 1 - set-arg2 repeat-frame
  ELSE arg1 exit-frame
  THEN
end

