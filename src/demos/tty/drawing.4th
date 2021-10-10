' alias [UNLESS] load-core [THEN]

' TtyScreen [UNLESS]
s[ src/lib/tty.4th
   src/lib/time.4th
] load-list
[THEN]

def demo-tty-drawing-draw-loop ( fn h w n context -- )
  0x77 rand-n arg0 TtyContext -> color poke-byte
  arg3 rand-n arg2 rand-n arg0 4 argn exec-abs
  arg1 1 - set-arg1
  arg1 0 int> IF repeat-frame ELSE 5 return0-n THEN
end

def demo-tty-drawing-loop
  arg0 tty-screen-resized? IF true 3 return1-n THEN
  0
  arg0 tty-screen-erase
  arg0 tty-screen-buffer make-tty-context set-local0
  0x77 rand-n local0 TtyContext -> color poke-byte
  26 rand-n 65 + local0 TtyContext -> char !
  arg1
  local0 tty-context-height 1 -
  local0 tty-context-width 1 -
  over rand-n over rand-n local0 tty-context-move-to
  arg2 local0 demo-tty-drawing-draw-loop
  arg0 tty-screen-swap ( -copy )
  ( 1 sleep )
  s" FPS: " error-string/2
  arg3 1 + dup set-arg3
  1000 * get-time-secs 4 argn - / error-int enl
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

def demo-tty-line
  tty-columns @ ' tty-context-line demo-tty-drawing/2
end

def demo-tty-ellipse
  tty-columns @ ' tty-context-ellipse demo-tty-drawing/2
end

def demo-tty-circle
  tty-columns @ ' tty-context-circle-rect demo-tty-drawing/2
end
