DEFINED? alias UNLESS load-core THEN

DEFINED? ' TtyScreen UNLESS
  s[ src/lib/time.4th
     src/lib/io.4th
     src/lib/tty.4th
  ] load-list
THEN

s[ vendor/north/src/02/rand.4th
] load-list

( fixme out' returns break when not found )
' guy ' break equals? UNLESS
  s" src/demos/tty/sprites/sprites.nth" load/2
THEN

def demo-tty-drawing-draw-loop ( fn h w n context -- )
  arg3 rand-n arg2 rand-n arg0 tty-context-move-to
  0x77 rand-n arg0 TtyContext -> color poke-byte
  arg3 rand-n arg2 rand-n arg0 4 argn exec-abs
  arg1 1 - set-arg1
  arg1 0 int> IF repeat-frame ELSE 5 return0-n THEN
end

def demo-tty-drawing-loop
  arg0 tty-screen-resized? IF true 3 return1-n THEN
  current-input @ 0 poll-fd-in IF
    tty-read
    tty-char-reset tty-erase-below
    false 3 return1-n
  THEN
  0
  arg0 tty-screen-erase
  arg0 tty-screen-buffer make-tty-context set-local0
  0x77 rand-n local0 TtyContext -> color poke-byte
  26 rand-n 65 + local0 TtyContext -> char !
  arg1
  local0 tty-context-height 1 -
  local0 tty-context-width 1 -
  arg2 local0 demo-tty-drawing-draw-loop
  ( 1 sleep )
  1 1 local0 tty-context-move-to
  0x70 local0 TtyContext -> color poke-byte
  TTY-CELL-NORMAL local0 TtyContext -> attr poke-byte
  s" FPS: " local0 tty-context-write-string/3
  arg3 1 + dup set-arg3
  1000 * get-time-secs 4 argn - / local0 tty-context-write-int
  arg0 tty-screen-swap ( -copy )
  drop-locals repeat-frame
end

def demo-tty-drawing/2
  0
  123 rand-seed !
  tty-getsize make-tty-screen
  dup tty-screen-erase
  dup tty-screen-draw-copy
  get-time-secs 0 arg1 arg0 5 overn demo-tty-drawing-loop
  IF drop-locals repeat-frame THEN
  tty-show-cursor tty-erase-below
end

8 var> tty-demo-loops
guy var> tty-demo-image

def demo-tty-init-num-loops ( arg-num -- )
  arg0 argc uint< IF
    arg0 get-argv dup string-length parse-uint
    IF tty-demo-loops ! THEN
  THEN 1 return0-n
end

def demo-tty-init-image
  2 argc uint< IF 2 get-argv dup string-length ELSE s" guy" THEN
  s" Using sprite " error-string/2
  2dup error-line/2 dict dict-lookup
  IF exec-abs tty-demo-image !
  ELSE s" No sprites found." error-line/2 -1 sysexit
  THEN 2 dropn
end
  
def demo-tty-line
  2 demo-tty-init-num-loops
  tty-demo-loops @ ' tty-context-line demo-tty-drawing/2
end

def demo-tty-ellipse
  2 demo-tty-init-num-loops
  tty-demo-loops @ ' tty-context-ellipse demo-tty-drawing/2
end

def demo-tty-circle
  2 demo-tty-init-num-loops
  tty-demo-loops @ ' tty-context-circle-rect demo-tty-drawing/2
end

def demo-tty-blit
  3 demo-tty-init-num-loops demo-tty-init-image
  ' tty-context-blit/2 tty-demo-image @ 1 partial-after
  tty-demo-loops @ over demo-tty-drawing/2
end

def demo-tty-scaled-blit-fn ( y x context img -- )
  arg0 0 0 arg0 TtyBuffer -> height @ arg0 TtyBuffer -> width @ 
  4 arg3 + 4 arg2 + ( 80 8 ) arg1 tty-context-scaled-blit/8
  ( arg1 TtyContext -> buffer @ arg3 arg2 dup 8 32 rand-n + +
  arg0 0 0 arg0 TtyBuffer -> height @ arg0 TtyBuffer -> width @
  tty-buffer-textured-hline )
  4 return0-n
end

def demo-tty-scaled-blit
  3 demo-tty-init-num-loops demo-tty-init-image
  ' demo-tty-scaled-blit-fn tty-demo-image @ partial-first
  tty-demo-loops @ over demo-tty-drawing/2
end

def demo-tty-usage
  s" Usage: " write-string/2 0 get-argv write-string
  s"  MODE [options...]" write-line/2
  nl
  s" Modes:" write-line/2
  s"             line [#]  Draw # random lines." write-line/2
  s"           circle [#]  Draw # random circles." write-line/2
  s"          ellipse [#]  Draw # random ellipses." write-line/2
  s"    blit [sprite [#]]  Draw a sprite randomly # times." write-line/2
  s"   scale [sprite [#]]  Scale a sprite randomly # times." write-line/2
  s"               interp  Start an interpreter." write-line/2
end

def demo-tty-boot
  interp-init
  1 argc uint>= IF demo-tty-usage -1 sysexit THEN
  s" src/demos/tty/sprites/sprites.nth" load/2
  1 get-argv CASE
    ( 0 OF demo-tty-usage ENDOF )
    s" line" OF-STR demo-tty-line ENDOF
    s" circle" OF-STR demo-tty-circle ENDOF
    s" ellipse" OF-STR demo-tty-ellipse ENDOF
    s" blit" OF-STR demo-tty-blit ENDOF
    s" scale" OF-STR demo-tty-scaled-blit ENDOF
    s" interp" OF-STR interp ENDOF
    demo-tty-usage
  ENDCASE
  exit-frame
end
