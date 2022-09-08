( Sequences: )

def first arg0 cell-size + peek set-arg0 end
def rest arg0 cell-size + set-arg0 end

def seq-nth ( seq n -- addr )
  arg0 cell-size * arg1 +
  2 return1-n
end

def seq-peek ( seq n -- value )
  arg0 cell-size * arg1 peek-off
  2 return1-n
end

def seq-poke ( value base n -- )
  arg2 arg1 arg0 cell-size * poke-off
  3 return0-n
end

def make-seqn args return1 end
def seqn-size arg0 peek set-arg0 end
def seqn-byte-size arg0 seqn-size 1 + cell-size * set-arg0 end
def seqn-nth arg0 1 + cell-size * arg1 + return1 end

def seqn-peek ( seq n -- value )
  arg0 1 + cell-size * arg1 peek-off
  2 return1-n
end

def seqn-poke ( value base n -- )
  arg2 arg1 arg0 1 + cell-size * poke-off
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

( Filling: )

def fill-seq ( seq n value -- )
  arg1 0 int> UNLESS 3 return0-n THEN
  arg1 1 - set-arg1
  arg0 arg2 arg1 seq-poke
  repeat-frame
end

def fill ( ptr num-bytes value -- )
  arg1 0 int> UNLESS 3 return0-n THEN
  arg1 1 - set-arg1
  arg0 arg2 arg1 poke-off-byte
  repeat-frame
end

( Allocating: )

def stack-allot-zero
  arg0 stack-allot
  dup arg0 cell/ 0 fill-seq
  exit-frame
end

def stack-allot-zero-seq
  arg0 cell-size * stack-allot-zero
  exit-frame
end

( Copying: )

def copy-seq-n ( src dest -- )
  arg1 arg0 arg1 seqn-byte-size copy
  2 return0-n
end
