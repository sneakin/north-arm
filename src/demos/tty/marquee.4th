' TtyScreen UNLESS
  s[ src/lib/structs.4th
     src/lib/time.4th
     src/lib/linux/clock.4th
     src/lib/tty.4th
  ] load-list
THEN

struct: TtyMarquee
pointer<any> field: text
int field: length
int<8> field: attr
int<8> field: color
int field: x
int field: y
int field: speed
int field: width

def make-tty-marquee ( str length width y speed ++ marquee )
  0 TtyMarquee make-instance set-local0
  4 argn local0 TtyMarquee -> text !
  arg3 local0 TtyMarquee -> length !
  arg2 local0 TtyMarquee -> width !
  arg1 local0 TtyMarquee -> y !
  0 local0 TtyMarquee -> x !
  arg0 local0 TtyMarquee -> speed !
  0x70 local0 TtyMarquee -> color poke-byte
  TTY-CELL-NORMAL local0 TtyMarquee -> attr poke-byte
  local0 exit-frame
end

def tty-marquee-draw ( marquee buffer )
  arg1 TtyMarquee -> text @ 
  arg1 TtyMarquee -> length @
  arg0
  arg1 TtyMarquee -> y @ 
  arg1 TtyMarquee -> x @ 
  arg1 TtyMarquee -> color peek-byte
  arg1 TtyMarquee -> attr peek-byte
  tty-buffer-draw-string
  2 return0-n
end

def tty-marquee-update
  ( move text )
  arg0 TtyMarquee -> x @ arg0 TtyMarquee -> speed @ + arg0 TtyMarquee -> x !
  ( wrap when right hand side is past zero )
  arg0 TtyMarquee -> x @ arg0 TtyMarquee -> length @ + 0 < IF
    arg0 TtyMarquee -> x @
    arg0 TtyMarquee -> width @ +
    arg0 TtyMarquee -> length @ +
    arg0 TtyMarquee -> x !
  ELSE
    ( or wrap when x is greater than the width )
    arg0 TtyMarquee -> x @ arg0 TtyMarquee -> width @ >= IF
      arg0 TtyMarquee -> x @
      arg0 TtyMarquee -> width @ -
      arg0 TtyMarquee -> length @ -
      arg0 TtyMarquee -> x !
    THEN
  THEN
  1 return0-n
end

def tty-attr-brightness-inc
  arg1 dup TTY-CELL-BRIGHTNESS logand arg0 + TTY-CELL-BRIGHTNESS logand
  swap TTY-CELL-BRIGHTNESS lognot logand logior 2 return1-n
end

def tty-marquee-brightness-inc!
  arg1 TtyMarquee -> attr peek-byte
  arg0 tty-attr-brightness-inc
  arg1 TtyMarquee -> attr poke-byte
  2 return0-n
end

def tty-marquee-ticker
  arg0 tty-marquee-update
  ( arg0 3 int< IF
    arg0 1 tty-marquee-brightness-inc!
  THEN )
  arg0 arg1 tty-marquee-draw
  arg1 2 return1-n
end

def test-tty-make-marquees ( h w seq length n ++ seq )
  arg0 arg1 int< UNLESS arg2 exit-frame THEN
  s" Hello world"
  arg3
  4 argn arg1 / arg0 *
  arg0 dup 1 logand IF negate THEN
  make-tty-marquee
  dup arg2 arg0 seq-poke    
  arg0 0x7 logand 4 bsl swap TtyMarquee -> color poke-byte
  arg0 1 + set-arg0 repeat-frame
end

def test-tty-marquee ( frames #marquees -- )
  0 0 0
  arg0 cell* stack-allot set-local2
  tty-getsize make-tty-screen set-local0
  local0 TtyScreen -> height @ local0 TtyScreen -> width @
  local2 arg0 0 test-tty-make-marquees
  tty-hide-cursor
  tty-alt-buffer
  get-time-secs set-local1
  local0 tty-screen-redraw
  local2 arg0 local0 arg1 DOTIMES[
    arg2 tty-screen-erase
    arg4 cell-size + arg3
    arg2 TtyScreen -> back @
    ' tty-marquee-ticker map-seq-n/4
    arg2 tty-screen-swap
  ]DOTIMES
  tty-normal-buffer
  tty-show-cursor
  get-time-secs local1 -
  arg1 int32->float32 over int32->float32 float32-div
  dup nl tty-normal s" FPS: " write-string/2 write-float32 nl
end
