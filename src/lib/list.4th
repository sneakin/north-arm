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

def revmap-cons/3 ( cons state fn )
  arg2 IF
    arg2 car
    arg2 cdr set-arg2 repeat-frame
  ELSE
    here here locals swap stack-delta
    dup 0 int> IF arg1 arg0 map-seq-n/4 exit-frame THEN
  THEN
end

( Lists as stacks: )

def push-onto ( value pointer ++ cons... value )
  arg0 peek arg1 cons dup arg0 poke ( fixme for bash: no poke )
  arg1 exit-frame
end

def pop-from ( pointer -- item )
  arg0 peek
  dup cdr arg0 poke
  car set-arg0
end