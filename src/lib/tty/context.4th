struct: TtyContext
pointer<any> field: buffer
int field: x
int field: y
int field: char
uint<8> field: color
uint<8> field: attr

def make-tty-context
  TtyContext make-instance
  arg0 over TtyContext -> buffer !
  0 over TtyContext -> x !
  0 over TtyContext -> y !
  32 over TtyContext -> char !
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

def tty-context-get-pos
  arg0 TtyContext -> y @
  arg0 TtyContext -> x @ 1 return2-n
end

def tty-context-move-to ( row col context )
  arg2 arg0 TtyContext -> y !
  arg1 arg0 TtyContext -> x !
  3 return0-n
end

def tty-context-move-by ( row col context )
  arg0 TtyContext -> y arg2 inc!/2
  arg0 TtyContext -> x arg1 inc!/2
  3 return0-n
end

def tty-context-advance-cursor/2 ( amount context -- )
  arg0 TtyContext -> x arg0 tty-context-width arg1 wrapped-inc!/3 IF
    arg0 TtyContext -> y arg0 tty-context-height arg1 wrapped-inc!/3
    IF ( todo scroll buffer? )
    THEN
  THEN
end

def tty-context-advance-cursor
  1 arg0 tty-context-advance-cursor/2 1 return0-n
end

def tty-context-set-cell ( char color attr y x context -- )
  5 argn 4 argn arg3 arg2 arg1
  arg0 TtyContext -> buffer @
  tty-buffer-set-cell
  6 return0-n
end

def tty-context-write-byte ( byte context -- )
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

def tty-context-fill-rect ( h w context -- )
  arg0 TtyContext -> char @
  arg0 TtyContext -> color peek-byte
  arg0 TtyContext -> attr peek-byte
  arg0 tty-context-get-pos
  arg2 arg1
  arg0 TtyContext -> buffer @ tty-buffer-fill-rect
  arg2 arg1 arg0 tty-context-move-by
  3 return0-n  
end

def tty-context-line ( y1 x1 context -- )
  arg0 TtyContext -> char @
  arg0 TtyContext -> color peek-byte
  arg0 TtyContext -> attr peek-byte
  arg2 arg1 arg0 tty-context-get-pos arg0 TtyContext -> buffer @ tty-buffer-line
  arg2 arg1 arg0 tty-context-move-to
  3 return0-n
end

def tty-context-circle ( r context -- )
  arg0 TtyContext -> char @
  arg0 TtyContext -> color peek-byte
  arg0 TtyContext -> attr peek-byte
  arg0 tty-context-get-pos arg1 arg0 TtyContext -> buffer @ tty-buffer-circle
  2 return0-n
end

def tty-context-circle-rect ( y x context -- )
  arg0 TtyContext -> char @
  arg0 TtyContext -> color peek-byte
  arg0 TtyContext -> attr peek-byte
  arg0 tty-context-get-pos
  arg1 over - 2 / +
  swap arg2 over - 2 / + swap
  arg1 arg0 TtyContext -> x @ - abs-int 2 / ( here 64 ememdump enl )
  arg0 TtyContext -> buffer @ tty-buffer-circle
  arg2 arg1 arg0 tty-context-move-to
  3 return0-n
end

def tty-context-ellipse ( y1 x1 context -- )
  arg0 TtyContext -> char @
  arg0 TtyContext -> color peek-byte
  arg0 TtyContext -> attr peek-byte
  arg0 tty-context-get-pos arg2 arg1 arg0 TtyContext -> buffer @ tty-buffer-ellipse
  arg2 arg1 arg0 tty-context-move-to
  3 return0-n
end
