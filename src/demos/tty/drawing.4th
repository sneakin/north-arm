' alias [UNLESS] load-core [THEN]

' TtyScreen [UNLESS]
  s[ src/lib/time.4th
     src/lib/linux.4th
     src/lib/io.4th
     src/lib/tty.4th
     src/demos/tty/sprites/sprites.nth
  ] load-list
[THEN]

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
end

8 var> tty-demo-loops

def demo-tty-line
  tty-demo-loops @ ' tty-context-line demo-tty-drawing/2
end

def demo-tty-ellipse
  tty-demo-loops @ ' tty-context-ellipse demo-tty-drawing/2
end

def demo-tty-circle
  tty-demo-loops @ ' tty-context-circle-rect demo-tty-drawing/2
end

def demo-tty-blit
  ' tty-context-blit/2 guy 1 partial-after
  tty-demo-loops @ over demo-tty-drawing/2
end
