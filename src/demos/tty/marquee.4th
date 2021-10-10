' TtyScreen [UNLESS]
s[ src/lib/tty.4th
   src/lib/time.4th
   src/lib/linux/clock.4th
] load-list
[THEN]

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
    
def test-tty-marquee
  0 0 0 0
  tty-getsize make-tty-screen set-local0
  s" Hello world" local0 TtyScreen -> width @ local0 TtyScreen -> height @ 3 / arg0 make-tty-marquee set-local2
  0x10 local2 TtyMarquee -> color poke-byte
  s" Hello world" local0 TtyScreen -> width @ local0 TtyScreen -> height @ 3 / 2 * arg0 negate make-tty-marquee set-local3
  0x20 local3 TtyMarquee -> color poke-byte
  tty-hide-cursor
  tty-alt-buffer
  get-time-secs set-local1
  local0 tty-screen-redraw
  local3 local2 local0 arg1 DOTIMES[
    arg2 tty-screen-erase
    arg3 tty-marquee-update
    arg3 1 tty-marquee-brightness-inc!
    arg4 tty-marquee-update
    arg4 -1 tty-marquee-brightness-inc!
    arg3 arg2 TtyScreen -> back @ tty-marquee-draw
    arg4 arg2 TtyScreen -> back @ tty-marquee-draw
    arg2 tty-screen-swap
  ]DOTIMES
  tty-normal-buffer
  tty-show-cursor
  get-time-secs local1 -
  arg1 int32->float32 over int32->float32 float32-div
  dup nl tty-normal s" FPS: " write-string/2 write-float32 nl
  return2
end
