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
