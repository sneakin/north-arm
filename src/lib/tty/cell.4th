struct: TtyCell
uint<32> field: char
uint<8> field: color ( bump to rgb? )
uint<8> field: attr
uint<16> field: padding

def tty-cell-equals? ( a b -- yes? )
  arg0 TtyCell . attr peek-byte arg1 TtyCell . attr peek-byte equals? UNLESS false 2 return1-n THEN
  arg0 TtyCell . char peek arg1 TtyCell . char peek equals? UNLESS false 2 return1-n THEN
  arg0 TtyCell . color peek-byte arg1 TtyCell . color peek-byte equals? UNLESS false 2 return1-n THEN
  true 2 return1-n
end

def tty-cell-draw ( cell )
  arg0 TtyCell . attr peek-byte tty-pen-write-attr
  arg0 TtyCell . color peek-byte tty-pen-write-color
  arg0 TtyCell . char peek
  dup -1 equals? UNLESS control-code? IF drop 32 THEN tty-pen-write-char THEN
  1 return0-n
end

def tty-cell-copy-string/3 ( cells string count -- )
  arg1 peek-byte arg2 TtyCell . char poke
  arg1 1 + set-arg1
  arg2 TtyCell struct -> byte-size @ + set-arg2
  arg0 1 - set-arg0
  arg0 0 > IF repeat-frame THEN 3 return0-n
end
