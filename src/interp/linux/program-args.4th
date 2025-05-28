0 defvar> *top-frame*
0 defvar> *auxvec*
0 defvar> *argv-offset*

def top-frame-loop
  arg0 parent-frame dup IF set-arg0 repeat-frame THEN
  return0
end

def top-frame
  *top-frame* peek
  dup UNLESS
    drop current-frame top-frame-loop
    dup *top-frame* poke
  THEN return1
end

def sys-argc
  top-frame farg0 peek return1
end

def argc
  sys-argc *argv-offset* @ - 0 max return1
end

def argv
  top-frame farg1 return1
end

def get-argv ( index -- value )
  arg0 argc int< IF
    *argv-offset* @ arg0 + cell-size * argv +
    dup IF peek ELSE 0 THEN
  ELSE 0
  THEN set-arg0
end

def env-addr ( ++ pointer )
  top-frame frame-args cell-size 2 sys-argc + * + return1
end

def env ( index ++ value-string )
  env-addr arg0 cell-size * +
  dup IF peek ELSE 0 THEN 1 return1-n
end

def get-env/3 ( str len index -- value )
  arg0 env dup UNLESS 0 3 return1-n THEN
  dup arg2 arg1 byte-string-equals?/3 IF 3 dropn arg1 + 1 + 3 return1-n THEN
  4 dropn
  arg0 1 + set-arg0 repeat-frame
end

def get-env/2 ( str len -- value )
  arg1 arg0 0 get-env/3 2 return1-n  
end

def get-env ( str -- value )
  arg0 dup string-length 0 get-env/3 1 return1-n  
end

def move-up-to-zero
  arg0 peek IF arg0 cell-size + set-arg0 repeat-frame THEN
end

def auxvec
  *auxvec* peek dup UNLESS
    env-addr move-up-to-zero cell-size +
    dup *auxvec* poke
  THEN return1
end

def get-auxvec/2
  arg0 peek dup arg1 equals?
  IF arg0 cell-size + peek 1 return1-n
  ELSE
    0 equals?
    IF -1 1 return1-n
    ELSE arg0 cell-size 2 * + set-arg0 repeat-frame
    THEN
  THEN
end

def get-auxvec
  arg0 auxvec get-auxvec/2 set-arg0
end
