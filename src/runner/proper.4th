def proper-init
  arg0 stack-allot return-stack poke
  exit-frame
end

def does-proper
  pointer do-proper dict-entry-code peek arg0 dict-entry-code poke
end

def does-proper>
  arg0 does-proper
  compiling-init compiling-read
  literal proper-exit swap
  int32 1 +
  int32 0 swap ( terminate with a zero )
  int32 1 +
  here cell-size + swap reverse
  int32 2 dropn
  here cs - arg0 dict-entry-data poke
  exit-frame
end

def defproper
  create> does-proper> exit-frame
end

defalias> : defproper
