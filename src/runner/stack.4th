defcol down-stack/2 rot swap cell-size int-mul int-sub swap endcol
defcol down-stack swap int32 1 down-stack/2 swap endcol

defcol up-stack/2 rot swap cell-size int-mul int-add swap endcol
defcol up-stack swap int32 1 up-stack/2 swap endcol

defcol stack-delta
  rot swap
  int-sub cell/
  swap
endcol

def shift ( a b c -- c a b )
  arg0
  arg1 set-arg0
  arg2 set-arg1
  set-arg2
  return
end

def roll ( a b c -- b c a )
  arg0
  arg2 set-arg0
  arg1 set-arg2
  set-arg1
  return
end

def roll-back-n ( nth ... item n -- item nth ... )
  ( Moves N cells down by one and stores item at the end. )
  ( stash the item )
  arg1
  ( move items down )
  args up-stack
  dup up-stack over arg0 cell-size * copy
  ( store the item )
  arg0 up-stack/2 poke
  1 return0-n
end
