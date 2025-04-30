def make-proper-noname
  alloc-dict-entry
  " proper-noname" cs - over dict-entry-name poke
  pointer do-proper dict-entry-code peek over dict-entry-code poke
  0 over dict-entry-data poke
  exit-frame
end

def partial-first ( fn arg ++ proper[ arg fn ] )
  ( Returns a noname entry that pushes arg onto the stack before calling fn. )
  make-proper-noname
  literal proper-exit
  arg1 cs -
  arg0 literal literal
  here cs - int32 6 overn dict-entry-data poke
  int32 5 overn exit-frame
end

def partial-after ( fn arg n ++ proper[ arg n roll-back-n fn ] )
  ( Returns a noname entry that inserts arg N cells up the stack before calling fn. )
  make-proper-noname
  literal proper-exit
  arg2 cs -
  literal roll-back-n
  arg0 literal literal
  arg1 literal literal
  here cs - int32 9 overn dict-entry-data poke
  int32 8 overn exit-frame
end

def compose ( a b ++ proper[ a b ] )
  ( Returns a noname entry that calls A and B. )
  make-proper-noname
  literal proper-exit
  arg0 cs -
  arg1 cs -
  here cs - int32 5 overn dict-entry-data poke
  int32 4 overn exit-frame
end

DEFINED? jump-op-size IF
def compose-if ( test a ++ proper[ test IF a THEN ] )
  ( Returns a noname entry that calls A if TEST is true. )
  make-proper-noname
  literal proper-exit
  arg0 cs -
  literal unless-jump
  jump-op-size
  literal int32
  arg1 cs -
  literal dup
  here cs - int32 9 overn dict-entry-data poke
  int32 8 overn exit-frame
end

ELSE ( DEFINED? jump-op-size )

def compose-if ( test a ++ proper[ test IF a THEN ] )
  ( Returns a noname entry that calls A if TEST is true. )
  make-proper-noname
  literal proper-exit
  arg0 cs -
  literal unless-jump
  1
  literal int32
  arg1 cs -
  literal dup
  here cs - int32 9 overn dict-entry-data poke
  int32 8 overn exit-frame
end

THEN ( DEFINED? jump-op-size )

def fun-reduce/3 ( item-fn reducer init ++ data... accum )
  arg2 exec-abs
  IF arg0 swap arg1 exec-abs set-arg0 repeat-frame
  ELSE drop arg0 exit-frame
  THEN
end
