def cons args return1 end
def car arg0 peek set-arg0 end
def cdr arg0 cell-size + peek set-arg0 end
defcol set-cdr! rot swap cell-size + poke endcol

def cons-count/2
  arg1 IF
    arg0 1 + set-arg0
    arg1 cdr set-arg1
    repeat-frame
  THEN
end

def cons-count arg0 0 cons-count/2 set-arg0 end

def push-onto ( value pointer ++ cons... value )
  arg0 peek arg1 cons dup arg0 poke ( fixme for bash )
  arg1 exit-frame
end

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

def map-cons ( cons fn )
  arg1 UNLESS exit-frame THEN
  arg1 arg0 exec-abs
  arg1 cdr set-arg1 repeat-frame
end

def map-car ( cons fn )
  arg1 UNLESS exit-frame THEN
  arg1 car arg0 exec-abs
  arg1 cdr set-arg1 repeat-frame
end

def print-cons
  s" (" write-string/2
  arg0 car write-hex-uint
  s"  . " write-string/2
  arg0 cdr write-hex-uint
  s" )" write-string/2
end

def find-by-string-2 ( ptr length list -- ptr length result result )
  arg0 UNLESS arg0 return1 THEN
  arg0 car arg2 arg1 string-equals?/3 IF arg0 return1 THEN
  arg0 cdr set-arg0
  repeat-frame
end

def assoc-string-2 ( ptr length list -- ptr length result result )
  arg0 UNLESS arg0 return1 THEN
  arg0 car car arg2 arg1 string-equals?/3 IF arg0 car cdr dup set-arg0 return1 THEN
  arg0 cdr set-arg0
  repeat-frame
end
