defcol down-stack/2 rot swap cell-size * - swap endcol
defcol down-stack swap int32 1 down-stack/2 swap endcol

defcol up-stack/2 rot swap cell-size * + swap endcol
defcol up-stack swap int32 1 up-stack/2 swap endcol

defcol stack-delta
  rot swap
  - cell-size /
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
