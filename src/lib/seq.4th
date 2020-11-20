( Sequences: )

def first arg0 cell-size + peek set-arg0 end
def rest arg0 cell-size + set-arg0 end

defcol seq-peek
  swap cell-size *
  swap rot + peek
  swap
endcol

defcol seq-poke ( value base n -- )
  swap cell-size * ( value base -- offset )
  swap rot + ( value -- addr )
  swap rot swap poke
endcol

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

