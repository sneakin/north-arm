0 defvar> *top-frame*
0 defvar> *auxvec*

def top-frame-loop
  arg0 parent-frame dup IF set-arg0 repeat-frame THEN
  return
end

def top-frame
  *top-frame* peek
  dup UNLESS
    drop current-frame top-frame-loop
    dup *top-frame* poke
  THEN return1
end

def argc
  top-frame farg2 peek return1
end

def argv
  top-frame farg3 return1
end

def get-argv
  argv cell-size arg0 * +
  dup IF peek ELSE 0 THEN return1
end

def env-addr
  top-frame frame-args cell-size 4 argc + * +
  return1
end

def env
  env-addr arg0 cell-size * +
  dup IF peek ELSE 0 THEN return1
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
  IF arg0 cell-size + peek return1
  ELSE
    0 equals?
    IF -1 return1
    ELSE arg0 cell-size 2 * + set-arg0 repeat-frame
    THEN
  THEN
end

def get-auxvec
  arg0 auxvec get-auxvec/2 set-arg0
end
