s[ src/lib/tty.4th
   src/lib/time.4th
   src/lib/clock.4th
] load-list

def test-tty-screen ( rows cols ++ screen )
  0 0
  arg1 arg0 make-tty-screen set-local0
  local0 TtyScreen -> front @ set-local1
  s" top left" local1 0 0 0x30 TTY-CELL-BRIGHT tty-buffer-draw-string
  s" bottom right" local1 arg1 2 - arg0 12 - 0x60 TTY-CELL-NORMAL tty-buffer-draw-string
  s" center" local1 arg1 2 / arg0 3 / 3 - 0x70 TTY-CELL-NORMAL tty-buffer-draw-string
  local0 tty-screen-redraw
  ( local0 tty-screen-swap-buffers )
  local0 TtyScreen -> back @ set-local1
  s" top left" local1 0 0 0x50 TTY-CELL-NORMAL tty-buffer-draw-string
  s" BOTTOM RIGHT" local1 arg1 2 - arg0 12 - 0x60 TTY-CELL-BRIGHT tty-buffer-draw-string
  ( fixme invert needs a pen's state tracking )
  s" center" local1 arg1 2 / arg0 arg0 3 / - 3 - 0x70 TTY-CELL-INVERT TTY-CELL-ATTR-UNDERLINE logior tty-buffer-draw-string
   ( local0 tty-screen-swap-buffers )

  local0 exit-frame
end

def test-tty-screen-speed
  0 0
  tty-getsize swap 1 - swap test-tty-screen set-local0
  get-time-secs set-local1
  local0 arg0 DOTIMES[ arg2 tty-screen-swap ]DOTIMES
  get-time-secs local1 -
  arg0 int32->float32 over int32->float32 float32-div
  dup nl s" FPS: " write-string/2 write-float32 nl
  return2
end
