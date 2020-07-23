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
defalias> dpoke poke

defcol dpush
  swap dhere poke
  dhere cell-size + dmove
endcol

defcol dpop
  cell-size dhere - dmove
  dhere peek swap
endcol

defcol ddrop
  swap cell-size * dhere - dmove  
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
