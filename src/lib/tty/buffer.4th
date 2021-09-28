def tty-fill-cell-color ( cells color count -- )
  arg1 arg2 TtyCell . color poke-byte
  arg2 TtyCell byte-size + set-arg2
  arg0 1 - set-arg0
  arg0 0 > IF repeat-frame THEN 3 return0-n
end

def tty-fill-cell-attr ( cells attr count -- )
  arg1 arg2 TtyCell . attr poke-byte
  arg2 TtyCell byte-size + set-arg2
  arg0 1 - set-arg0
  arg0 0 > IF repeat-frame THEN 3 return0-n
end

struct: TtyBuffer
int<32> field: width
int<32> field: height
pointer<any> field: cells

def make-tty-buffer ( rows cols ++ TtyBuffer )
  0 TtyBuffer make-instance set-local0
  arg0 local0 TtyBuffer -> width !
  arg1 local0 TtyBuffer -> height !
  arg1 arg0 * TtyCell byte-size * stack-allot-zero local0 TtyBuffer -> cells !
  local0 exit-frame
end

def tty-buffer-pitch ( buffer -- pitch )
  arg0 TtyBuffer -> width @
  TtyCell byte-size * return1-1
end

def tty-buffer-draw-row ( cells width pen-state -- )
  arg2 dup TtyCell . attr peek-byte swap TtyCell . color peek-byte arg0 tty-pen-update-write
  arg2 TtyCell . char peek-byte control-code? IF drop 32 THEN write-byte
  arg2 TtyCell byte-size + set-arg2
  arg1 1 - set-arg1
  arg1 0 > IF repeat-frame THEN 3 return0-n
end

def tty-buffer-draw/4 ( cells line-counter buffer pen-state -- )
  arg3 arg1 TtyBuffer -> width @ arg0 tty-buffer-draw-row
  nl
  arg3 arg1 tty-buffer-pitch + set-arg3
  arg2 1 - set-arg2
  arg2 0 > IF repeat-frame THEN 4 return0-n
end

def tty-buffer-draw ( TtyBuffer -- )
  0
  TtyPenState make-instance set-local0
  local0 tty-pen-write-reset
  arg0 TtyBuffer -> cells @
  arg0 TtyBuffer -> height @
  arg0 local0 tty-buffer-draw/4
  1 return0-n
end

def tty-buffer-size ( TtyBuffer -- bytes )
  arg0 TtyBuffer -> height @ arg0 tty-buffer-pitch * return1-1
end

def tty-buffer-erase ( TtyBuffer -- )
  arg0 TtyBuffer -> cells @
  arg0 tty-buffer-size cell-size /
  0 fill-seq
  1 return0-n
end

def tty-buffer-draw-string ( str length buffer row col color attr -- )
  ( if col is negative: inc str, shorten length, zero col )
  arg2 0 < IF
    6 argn arg2 - 6 set-argn
    5 argn arg2 + 5 set-argn
    0 set-arg2
  THEN
  ( if col+length >= width, shorten length )
  arg2 5 argn +
  arg4 TtyBuffer -> width @ -
  dup 0 > IF
    5 argn swap - 5 set-argn
  ELSE drop
  THEN
  arg4 TtyBuffer -> cells @
  arg4 tty-buffer-pitch arg3 * + TtyCell byte-size arg2 * +
  dup 6 argn 5 argn tty-cell-copy-string/3    
  dup arg0 5 argn tty-fill-cell-attr
  arg1 5 argn tty-fill-cell-color

  7 return0-n
end
