( Cons cells: )
def cons args return1 end

def cons2 ( tail mid car ++ cons )
  arg2 arg1 cons arg0 cons exit-frame
end

def car arg0 dup IF peek set-arg0 THEN end
defcol set-car! rot swap poke endcol
def cdr arg0 dup IF cell-size + peek set-arg0 THEN end
defcol set-cdr! rot swap cell-size + poke endcol

def cons-count/2
  arg1 IF
    arg0 1 + set-arg0
    arg1 cdr set-arg1
    repeat-frame
  THEN
end

def cons-count arg0 0 cons-count/2 set-arg0 end

def cons-empty?
  arg0 IF false ELSE true THEN set-arg0
end

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

def map-car/3 ( cons state fn )
  arg2 UNLESS arg1 exit-frame THEN
  arg1 arg2 car arg0 exec-abs set-arg1
  arg2 cdr set-arg2 repeat-frame
end

def revmap-cons/3 ( cons state fn )
  arg2 IF
    arg2 car
    arg2 cdr set-arg2 repeat-frame
  ELSE
    here here locals swap stack-delta
    dup 0 int> IF arg1 arg0 map-seq-n/4 exit-frame
	       ELSE arg1 3 return1-n
	       THEN
  THEN
end

def find-first ( list fn -- result )
  arg1 IF
    arg1 car arg0 exec-abs
    IF arg1 car
    ELSE arg1 cdr set-arg1 repeat-frame
    THEN
  ELSE 0
  THEN 2 return1-n
end

def find-first-result ( list fn[item -- result yes?]  -- result yes? )
  arg1 IF
    arg1 car arg0 exec-abs
    IF true
    ELSE arg1 cdr set-arg1 repeat-frame
    THEN
  ELSE false
  THEN 2 return2-n
end

def skip-first ( n lst -- nth-item )
  arg0 IF
    arg1 0 uint> IF
      arg0 cdr set-arg0
      arg1 1 - set-arg1
      repeat-frame
    THEN
  THEN
  arg0 2 return1-n
end

def list->seq-fn ( count cell -- cell count+1 )
  arg0 arg1 1 + 2 return2-n
end

def list->seqn ( list ++ seqn )
  arg0 0 cons 0 ' list->seq-fn map-car/3 here exit-frame
end

def rev-list-into-seq/4 ( list seq length n -- seq length )
  arg3 arg0 0 int> and IF
    arg0 1 - set-arg0
    arg3 car arg2 arg0 seq-poke
    arg3 cdr set-arg3 repeat-frame
  ELSE
    arg2 arg1 4 return2-n
  THEN
end

def rev-list-into-seq ( list seq n -- seq length )
  arg2 cons-count arg0 min dup set-arg0 ' rev-list-into-seq/4 tail+1
end

def list-into-seq/4 ( list seq length n -- seq length )
  arg3 arg0 arg1 uint< and IF
    arg3 car arg2 arg0 seq-poke
    arg0 1 + set-arg0
    arg3 cdr set-arg3 repeat-frame
  ELSE
    arg2 arg0 4 return2-n
  THEN
end

def list-into-seq ( list seq n -- seq n ) 0 ' list-into-seq/4 tail+1 end

( Lists as stacks: )

def push-onto ( value pointer ++ cons... new-list )
  arg0 peek arg1 cons dup arg0 poke ( fixme for bash: no poke )
  exit-frame
end

def pop-from ( pointer -- item )
  arg0 peek
  dup cdr arg0 poke
  car set-arg0
end
