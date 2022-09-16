struct: TtyPenState
uint<8> field: color
uint<8> field: attr

def tty-pen-write-byte
  arg0 write-byte
end

def tty-pen-write-char
  arg0 -1 equals? UNLESS arg0 write-utf32-char THEN
end

def tty-pen-write-attr-diff ( new-attr old-attr -- )
  arg1 TTY-CELL-BRIGHTNESS logand
  arg0 TTY-CELL-BRIGHTNESS logand 2dup equals? UNLESS
    tty-char-reset
    local0 CASE
      TTY-CELL-DIM WHEN dim ;;
      TTY-CELL-BRIGHT WHEN bold ;;
      TTY-CELL-OFF WHEN invisible ;;
    ESAC
  THEN
  arg1 TTY-CELL-INVERT logand IF inverse THEN
  arg1 TTY-CELL-ATTR-UNDERLINE logand IF underline THEN
  arg1 TTY-CELL-ATTR-ITALIC logand IF italic THEN
  arg1 TTY-CELL-ATTR-BLINK logand IF blink-fast THEN
  arg1 TTY-CELL-ATTR-STRIKE logand IF strike THEN

  arg1 TTY-CELL-ATTR-BOX logand
  arg0 TTY-CELL-ATTR-BOX logand > IF tty-box-drawing-on ELSE tty-box-drawing-off THEN

  2 return0-n
end

def tty-pen-write-attr ( new-attr -- )
  ( arg0 TTY-CELL-NORMAL tty-pen-write-attr-diff )
  tty-char-reset
  arg0 CASE
    TTY-CELL-DIM WHEN dim ;;
    TTY-CELL-BRIGHT WHEN bold ;;
    TTY-CELL-OFF WHEN invisible ;;
  ESAC

  arg0 TTY-CELL-INVERT logand IF inverse THEN
  arg0 TTY-CELL-ATTR-UNDERLINE logand IF underline THEN
  arg0 TTY-CELL-ATTR-ITALIC logand IF italic THEN
  arg0 TTY-CELL-ATTR-BLINK logand IF blink-fast THEN
  arg0 TTY-CELL-ATTR-STRIKE logand IF strike THEN

  arg0 TTY-CELL-ATTR-BOX logand IF tty-box-drawing-on ELSE tty-box-drawing-off THEN

  1 return0-n
end

def tty-pen-write-color ( color -- )
  arg0 TTY-CELL-BG logand
  arg0 TTY-CELL-FG logand 4 bsr
  color/2
  1 return0-n
end

def tty-pen-update-attr ( attr pen -- updated? )
  arg1 arg0 TtyPenState -> attr peek-byte equals? UNLESS
    arg1 arg0 TtyPenState -> attr poke-byte
    true
  ELSE false
  THEN 2 return1-n
end

def tty-pen-update-color ( color pen -- updated? )
  arg1 arg0 TtyPenState -> color peek-byte equals? UNLESS
    arg1 arg0 TtyPenState -> color poke-byte
    true
  ELSE false
  THEN 2 return1-n
end

def tty-pen-update-write ( attr color pen -- )
  arg0 TtyPenState -> attr peek-byte
  arg2 arg0 tty-pen-update-attr dup IF
    arg2 local0 tty-pen-write-attr-diff
  THEN
  arg1 arg0 tty-pen-update-color
  logior IF arg1 tty-pen-write-color THEN
  3 return0-n
end

def tty-pen-reset
  TTY-CELL-NORMAL arg0 TtyPenState -> attr poke-byte
  0x70 arg0 TtyPenState -> color poke-byte
  1 return0-n
end

def tty-pen-write-reset
  arg0 tty-pen-reset tty-char-reset 1 return0-n
end
