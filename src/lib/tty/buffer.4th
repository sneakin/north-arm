def tty-fill-cell-color ( cells color count -- )
  arg1 arg2 TtyCell . color poke-byte
  arg2 TtyCell struct -> byte-size @ + set-arg2
  arg0 1 - set-arg0
  arg0 0 > IF repeat-frame THEN 3 return0-n
end

def tty-fill-cell-attr ( cells attr count -- )
  arg1 arg2 TtyCell . attr poke-byte
  arg2 TtyCell struct -> byte-size @ + set-arg2
  arg0 1 - set-arg0
  arg0 0 > IF repeat-frame THEN 3 return0-n
end

struct: TtyBuffer
int field: width
int field: height
( todo mem width & height )
pointer<any> field: cells

def make-tty-buffer-mem ( rows cols buffer ++ TtyBuffer )
  arg2 arg1 * TtyCell struct -> byte-size @ * cell-size + stack-allot-zero arg0 TtyBuffer -> cells !
  arg1 arg0 TtyBuffer -> width !
  arg2 arg0 TtyBuffer -> height !
  arg0 exit-frame
end

def make-tty-buffer ( rows cols ++ TtyBuffer )
  TtyBuffer make-instance
  arg0 arg1 rot make-tty-buffer-mem
  exit-frame
end

def tty-buffer-pitch ( buffer -- pitch )
  arg0 TtyBuffer -> width @
  TtyCell struct -> byte-size @ * set-arg0
end

def tty-buffer-draw-row ( cells width pen-state -- )
  arg2 TtyCell . attr peek-byte arg2 TtyCell . color peek-byte arg0 tty-pen-update-write
  arg2 TtyCell . char peek
  dup -1 equals? UNLESS control-code? IF drop 32 THEN write-utf32-char THEN
  arg2 TtyCell struct -> byte-size @ + set-arg2
  arg1 1 - set-arg1
  arg1 0 > IF repeat-frame THEN 3 return0-n
end

def tty-buffer-draw/4 ( cells line-counter buffer pen-state -- )
  arg3 arg1 TtyBuffer -> width @ arg0 tty-buffer-draw-row
  arg3 arg1 tty-buffer-pitch + set-arg3
  arg2 1 - set-arg2
  arg2 0 > IF nl repeat-frame THEN 4 return0-n
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

def tty-buffer-size-for ( row cols -- bytes )
  arg1 arg0 * TtyCell struct -> byte-size @ * set-arg1 1 return0-n
end

def tty-buffer-size ( TtyBuffer -- bytes )
  arg0 TtyBuffer -> height @ arg0 TtyBuffer -> width @ tty-buffer-size-for set-arg0
end

def tty-buffer-erase ( TtyBuffer -- )
  arg0 TtyBuffer -> cells @
  arg0 tty-buffer-size cell/ 1 + ( fixme needs to be byte exact, adding padding on allot and going beyond here )
  0 fill-seq
  1 return0-n
end

def tty-buffer-clips? ( row col buffer -- yes? )
  0 arg2 int<= arg2 arg0 TtyBuffer -> height @ int< and UNLESS true 3 return1-n THEN
  0 arg1 int<= arg1 arg0 TtyBuffer -> width @ int< and UNLESS true 3 return1-n THEN
  false 3 return1-n
end

def tty-buffer-get-cell ( row col buffer ++ cell )
  arg2 arg1 arg0 tty-buffer-clips? UNLESS
    arg0 TtyBuffer -> cells @
    arg2 arg0 tty-buffer-pitch * + arg1 TtyCell struct -> byte-size @ * +
  ELSE
    0
  THEN 3 return1-n
end

def tty-buffer-set-cell ( char color attr row col buffer -- )
  arg2 arg1 arg0 tty-buffer-clips? UNLESS
    arg0 TtyBuffer -> cells @
    arg2 arg0 tty-buffer-pitch * + arg1 TtyCell struct -> byte-size @ * +
    5 argn over TtyCell . char poke
    4 argn over TtyCell . color poke-byte
    3 argn over TtyCell . attr poke-byte
  THEN 6 return0-n
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
  arg4 tty-buffer-pitch arg3 * + TtyCell struct -> byte-size @ arg2 * +
  dup 6 argn 5 argn tty-cell-copy-string/3    
  dup arg0 5 argn tty-fill-cell-attr
  arg1 5 argn tty-fill-cell-color

  7 return0-n
end

def tty-buffer-resize! ( rows cols buffer ++ buffer allot? )
  arg2 arg1 tty-buffer-size-for
  arg0 tty-buffer-size
  2dup int> IF
    arg2 arg1 arg0 make-tty-buffer-mem true exit-frame
  ELSE
    equals? UNLESS
      arg1 arg0 TtyBuffer -> width !
      arg2 arg0 TtyBuffer -> height !
    THEN
  THEN
  arg0 set-arg2
  false 2 return1-n
end

def tty-buffer-line-cell/6 ( char color attr buffer y x -- buffer )
  5 argn 4 argn arg3 arg1 arg0 arg2 tty-buffer-set-cell
  arg2 true 6 return2-n
end

def tty-buffer-line-cell ( buffer y x -- buffer )
  0x43 0x77 0 arg1 arg0 arg2 tty-buffer-set-cell true 2 return1-n
end

def tty-buffer-line ( char color attr y1 x1 y2 x2 buffer -- )
  ( debug? IF
    s" buffer-line" error-string/2 espace
    6 argn error-hex-int espace
    4 argn error-int espace
    arg3 error-int espace
    arg2 error-int espace
    arg1 error-int enl
  THEN )
  ( check for horizontal and vertical special cases )
  ( draw the line )
  ' tty-buffer-line-cell/6
  5 argn 3 partial-after
  6 argn 3 partial-after
  7 argn 3 partial-after
  arg0 4 argn arg3 arg2 arg1 line-fn
  8 return0-n
end

def tty-buffer-circle ( char color attr cy cx r buffer -- )
  ' tty-buffer-line-cell/6
  4 argn 3 partial-after
  5 argn 3 partial-after
  6 argn 3 partial-after
  arg0 arg3 arg2 arg1 circle-fn
  7 return0-n
end

def tty-buffer-ellipse ( char color attr y1 x1 y2 x2 buffer -- )
  ' tty-buffer-line-cell/6
  5 argn 3 partial-after
  6 argn 3 partial-after
  7 argn 3 partial-after
  arg0 4 argn arg3 arg2 arg1 ellipse-fn
  8 return0-n
end

def tty-buffer-hline-loop ( char color attr y x w buffer counter -- )
  7 argn 6 argn 5 argn
  4 argn arg3 arg0 + arg1 tty-buffer-set-cell
  arg0 1 + set-arg0
  arg0 arg2 int< IF repeat-frame ELSE 8 return0-n THEN
end

def tty-buffer-fill-rect-loop ( char color attr y x h w buffer counter -- )
  8 argn 7 argn 6 argn
  5 argn arg0 + 4 argn
  arg2 arg1 0 tty-buffer-hline-loop
  arg0 1 + set-arg0
  arg0 arg3 int< IF repeat-frame ELSE 9 return0-n THEN
end

def tty-buffer-fill-rect ( char color attr y x h w buffer -- )
  7 argn 6 argn 5 argn 4 argn arg3 arg2 arg1 arg0 0 tty-buffer-fill-rect-loop
  8 return0-n
end
