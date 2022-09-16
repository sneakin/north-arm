struct: TtyCell
uint<32> field: char ( todo needs to hold unicode characters )
uint<8> field: color ( bump to rgb? )
uint<8> field: attr

def tty-cell-equals? ( a b -- yes? )
  arg1 TtyCell . char peek-byte
  arg0 TtyCell . char peek-byte equals?
  arg1 TtyCell . attr peek-byte
  arg0 TtyCell . attr peek-byte equals? logand
  arg1 TtyCell . color peek-byte
  arg0 TtyCell . color peek-byte equals? logand
  2 return1-n
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
