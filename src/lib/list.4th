( Cons cells: )
def cons args return1 end

def car arg0 peek set-arg0 end
defcol set-car! rot swap poke endcol
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

def map-seq-n/4 ( ptr n state fn )
  arg2 0 int> IF
    arg1 arg3 peek arg0 exec-abs set-arg1
    arg3 rest set-arg3
    arg2 1 - set-arg2 repeat-frame
  ELSE arg1 exit-frame
  THEN
end

def revmap-cons/3 ( cons state fn )
  arg2 IF
    arg2 car
    arg2 cdr set-arg2 repeat-frame
  ELSE
    here here locals swap stack-delta
    dup 0 int> IF arg1 arg0 map-seq-n/4 exit-frame THEN
  THEN
end

( List reading: )

def read-list ( last-token result ++ result )
  next-token negative? IF 2 dropn arg0 exit-frame THEN
  arg1 3 overn 3 overn string-equals?/3 IF 5 dropn arg0 exit-frame THEN
  3 dropn allot-byte-string/2 drop
  arg0 swap cons set-arg0
  repeat-frame
end

( Reads tokens to the stack and returns a list stored on the stack. )
def s[
  s" ]" drop 0 read-list exit-frame
end

( todo switch to defs gets these included when cross compiling. )

( Reads a list of tokens to the stack, placing ' literal before each so the list is stack allocated at runtime. )
: read-literal-stack-list
  next-token negative? IF 2 dropn proper-exit THEN
  over s" ]" byte-string-equals?/3
  IF 5 dropn proper-exit ELSE 3 dropn THEN
  dhere rot swap 0 ,byte-string/3 3 dropn ( fixme drop the drop )
  literal literal rot ( to-out-addr )
  literal cons swap
  1 + loop
;

( fixme "literal int32 0" caused problems. )

: old-'s[
  literal int32 int32 0
  0 read-literal-stack-list drop
; immediate-as old-s[

( Operations: )

def print-cons
  s" (" write-string/2
  arg0 car write-hex-uint
  s"  . " write-string/2
  arg0 cdr write-hex-uint
  s" )" write-string/2
end

def push-onto ( value pointer ++ cons... value )
  arg0 peek arg1 cons dup arg0 poke ( fixme for bash: no poke )
  arg1 exit-frame
end

def load-1
  arg0 load
  1 exit-frame
end
  
def load-list ( pair ++ )
  arg0 0 ' load-1 revmap-cons/3 exit-frame
end