( todo relative data stack? )

0 defvar> data-stack-base
0 defvar> data-stack-size
0 defvar> data-stack-here

defcol dhere
  data-stack-here peek
  swap
endcol

defcol dmove
  swap data-stack-here poke
endcol

defalias> dpeek peek
defalias> dpeek-byte peek-byte
defalias> dpoke poke
defalias> dpoke-byte poke-byte

defcol dpush
  swap dhere poke
  dhere cell-size + dmove
endcol

defcol dpush-byte
  swap dhere poke-byte
  dhere int32 1 + dmove
endcol

defcol dpop
  dhere cell-size - dup dmove
  peek swap
endcol

defcol dpop-byte
  dhere int32 1 - dup dmove
  peek-byte swap
endcol

defcol ddrop
  swap cell-size * dhere swap - dmove  
endcol

defcol dallot
  dhere rot
  over cell-size * + dmove
endcol

defcol data-init ( ptr size )
  swap data-stack-size poke
  swap dup data-stack-base poke
  dmove
endcol

def data-init-stack
  arg0 stack-allot arg0 data-init exit-frame
end
