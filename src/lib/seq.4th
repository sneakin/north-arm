( Sequences: )

def first arg0 cell-size + peek set-arg0 end
def rest arg0 cell-size + set-arg0 end

def seq-nth ( seq n -- addr )
  arg0 cell-size * arg1 +
  2 return1-n
end
  
def seq-peek ( seq n -- value )
  arg1 arg0 seq-nth peek
  2 return1-n
end

def seq-poke ( value base n -- )
  arg1 arg0 seq-nth
  arg2 swap poke
  3 return0-n
end

def make-seqn args return1 end
def seqn-size arg0 peek set-arg0 end
def seqn-nth arg0 1 + cell-size * arg1 + return1 end

( Iteration: )

def map-seq-n/4 ( ptr n state fn )
  arg2 0 int> IF
    arg1 arg3 peek arg0 exec-abs set-arg1
    arg3 rest set-arg3
    arg2 1 - set-arg2 repeat-frame
  ELSE arg1 exit-frame
  THEN
end

