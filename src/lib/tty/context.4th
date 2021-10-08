struct: TtyContext
pointer<any> field: buffer
int field: x
int field: y
uint<8> field: color
uint<8> field: attr

def make-tty-context
  TtyContext make-instance
  arg0 over TtyContext -> buffer !
  0 over TtyContext -> x !
  0 over TtyContext -> y !
  0x70 over TtyContext -> color poke-byte
  TTY-CELL-NORMAL over TtyContext -> attr poke-byte
  exit-frame
end

def tty-context-width
  arg0 TtyContext -> buffer @ TtyBuffer -> width @ set-arg0
end

def tty-context-height
  arg0 TtyContext -> buffer @ TtyBuffer -> height @ set-arg0
end

def tty-context-cursor-to ( row col context )
  arg2 arg0 TtyContext -> y !
  arg1 arg0 TtyContext -> x !
  3 return0-n
end

def wrapped-inc!/3 ( place max amount -- wrapped? )
  arg2 dup @ arg0 +
  local0 arg1 int>=
  IF drop 0 true
  ELSE false
  THEN rot ! 3 return1-n
end

def wrapped-inc! ( place max -- wrapped? )
  arg1 arg0 1 wrapped-inc!/3 2 return1-n
end

def tty-context-advance-cursor/2
  arg0 TtyContext -> x arg0 tty-context-width arg1 wrapped-inc!/3 IF
    arg0 TtyContext -> y arg0 tty-context-height arg1 wrapped-inc!/3
    IF ( todo scroll buffer? )
    THEN
  THEN
end

def tty-context-advance-cursor
  arg0 TtyContext -> x arg0 tty-context-width wrapped-inc! IF
    arg0 TtyContext -> y arg0 tty-context-height wrapped-inc!
    IF ( todo scroll buffer? )
    THEN
  THEN 1 return0-n
end

def tty-context-write-byte
  arg1
  arg0 TtyContext -> color peek-byte
  arg0 TtyContext -> attr peek-byte
  arg0 TtyContext -> y @
  arg0 TtyContext -> x @
  arg0 TtyContext -> buffer @
  tty-buffer-set-cell
  arg0 tty-context-advance-cursor
  2 return0-n
end

def tty-context-write-byte-rep ( c n context -- )
  arg2 arg0 tty-context-write-byte
  arg1 1 - set-arg1
  arg1 0 int> IF repeat-frame THEN 3 return0-n
end

def tty-context-write-string/3 ( str n context -- )
  arg2 arg1
  arg0 TtyContext -> buffer @
  arg0 TtyContext -> y @
  arg0 TtyContext -> x @  
  arg0 TtyContext -> color peek-byte
  arg0 TtyContext -> attr peek-byte
  tty-buffer-draw-string
  arg1 arg0 tty-context-advance-cursor/2
  3 return0-n
end

def tty-context-width
  arg0 TtyContext -> buffer @ TtyBuffer -> width @ set-arg0
end

def tty-context-height
  arg0 TtyContext -> buffer @ TtyBuffer -> height @ set-arg0
end

def tty-context-line ( y1 x1 y2 x2 fill-char context -- )
  arg1
  arg0 TtyContext -> color peek-byte
  arg0 TtyContext -> attr peek-byte
  5 argn 4 argn arg3 arg2 arg0 TtyContext -> buffer @ tty-buffer-line
  6 return0-n
end

def tty-context-circle ( cy cx r fill-char context -- )
  arg1
  arg0 TtyContext -> color peek-byte
  arg0 TtyContext -> attr peek-byte
  4 argn arg3 arg2 arg0 TtyContext -> buffer @ tty-buffer-circle
  5 return0-n
end

def tty-context-ellipse ( y1 x1 y2 x2 fill-char context -- )
  arg1
  arg0 TtyContext -> color peek-byte
  arg0 TtyContext -> attr peek-byte
  5 argn 4 argn arg3 arg2 arg0 TtyContext -> buffer @ tty-buffer-ellipse
  6 return0-n
end
