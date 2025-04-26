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

( Reversal: )

OUT:DEFINED? nreverse-cells IF
  def reverse-cells! ( ptr length -- )
    arg1 arg0 1 - cell-size * + arg1 arg0 nreverse-cells
    2 return0-n
  end

  ( todo move to string.4th? )
  def reverse-bytes! ( ptr length -- )
    arg1 arg0 1 - + arg1 arg0 nreverse-bytes
    2 return0-n
  end

  def reverse ( ptr num-cells ++ )
    arg1 arg0 1 - cell-size * + arg1 arg0 nreverse-cells
  end

  def reverse-into ( src dest num-cells -- )
    arg2 arg0 1 - cell-size * + arg1 arg0 reverse-cells
    3 return0-n
  end
ELSE
  def reverse-loop ( start ending )
    arg1 arg0 uint>= IF return0 THEN
    ( swap values )
    arg1 peek arg0 peek
    arg1 poke arg0 poke
    ( loop towards the middle )
    arg1 cell-size + set-arg1
    arg0 cell-size - set-arg0
    repeat-frame
  end

  def reverse ( ptr length )
    arg1 arg1 arg0 1 - cell-size * + reverse-loop
  end
THEN

( Iteration: )

def map-seq-n/4 ( ptr n state fn ++ state )
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

( Basic search: )

def seq-index-of/4 ( seq n element i -- idx true | false )
  arg0 arg2 uint< UNLESS false 4 return1-n THEN
  arg3 arg0 seq-peek arg1 equals? IF arg0 true 4 return2-n THEN
  arg0 1 + set-arg0 repeat-frame
end

def seq-index-of ( seq n element -- idx true | false )
  0 ' seq-index-of/4 tail+1
end

def seq-include? ( seq n element -- yes? )
  arg2 arg1 arg0 seq-index-of 3 return1-n
end

def seq-index-of-string/5 ( seq n string length counter -- index true | false )
  arg0 arg3 uint< UNLESS false 5 return1-n THEN
  4 argn arg0 seq-peek arg2 arg1 string-equals?/3 IF arg0 true 5 return2-n THEN
  arg0 1 + set-arg0 drop-locals repeat-frame
end

def seq-index-of-string/4 ( seq n string length -- index true | false )
  0 ' seq-index-of-string/5 tail+1
end

def seq-include-string?/4 ( seq n string length -- yes? )
  arg3 arg2 arg1 arg0 0 seq-index-of-string/5 4 return1-n
end

( Uniqueness: )

def uniq-seq ( seq n ++ uniques num-uniqs )
  arg0 0 uint> UNLESS here locals cell-size + over - cell/ exit-frame THEN
  arg0 1 - set-arg0
  here
  arg1 arg0 seq-peek
  swap locals cell-size + over - cell/ 3 overn seq-include? IF drop THEN
  repeat-frame
end
