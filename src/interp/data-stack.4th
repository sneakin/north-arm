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
defalias> dpeek-off peek-off
defalias> dpeek-byte peek-byte
defalias> dpeek-off-byte peek-off-byte
defalias> dpeek-short peek-short
defalias> dpeek-off-short peek-off-short

defalias> dpoke poke
defalias> dpoke-off poke-off
defalias> dpoke-byte poke-byte
defalias> dpoke-off-byte poke-off-byte
defalias> dpoke-short poke-short
defalias> dpoke-off-short poke-off-short

( todo bc & x86 runners move then poke )

defcol dpush
  swap dhere poke
  dhere cell-size + dmove
endcol

defcol dpush-byte
  swap dhere poke-byte
  dhere int32 1 + dmove
endcol

defcol dpush-short
  swap dhere poke-short
  dhere int32 2 + dmove
endcol

defcol dpop
  dhere cell-size - dup dmove
  peek swap
endcol

defcol dpop-byte
  dhere int32 1 - dup dmove
  peek-byte swap
endcol

defcol dpop-short
  dhere int32 2 - dup dmove
  peek-short swap
endcol

defcol ddrop
  swap cell-size * dhere swap - dmove  
endcol

defcol dallot
  dhere rot
  cell-size * 3 overn + dmove
endcol

defcol data-init ( ptr size )
  swap data-stack-size poke
  swap dup data-stack-base poke
  dmove
endcol

def data-init-stack
  arg0 stack-allot arg0 data-init exit-frame
end
