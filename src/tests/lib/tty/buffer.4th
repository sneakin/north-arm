' TtyBuffer [UNLESS]
s[ src/lib/tty.4th
   src/lib/time.4th
] load-list
[THEN]

def test-tty-buffer
  0
  arg1 arg0 make-tty-buffer set-local0

  s" top left" local0 0 0 0x30 TTY-CELL-BRIGHT tty-buffer-draw-string
  s" left off" local0 1 -4 0x40 TTY-CELL-BRIGHT tty-buffer-draw-string
  s" right" local0 0 15 0x03 TTY-CELL-NORMAL tty-buffer-draw-string
  s" bot left" local0 6 0 0x54 TTY-CELL-INVERT tty-buffer-draw-string
  s" right" local0 5 15 0x60 TTY-CELL-ATTR-UNDERLINE tty-buffer-draw-string
  s" right" local0 6 15 0x60 TTY-CELL-ATTR-UNDERLINE tty-buffer-draw-string
  s" off right" local0 4 35 0x50 TTY-CELL-ATTR-UNDERLINE tty-buffer-draw-string

  local0 TtyBuffer -> cells @ local0 tty-buffer-pitch 0 * + TtyCell byte-size 0 * + TTY-CELL-ATTR-UNDERLINE 2 tty-fill-cell-attr
  local0 TtyBuffer -> cells @ local0 tty-buffer-pitch 6 * + TtyCell byte-size 15 * + TTY-CELL-ATTR-BOLD 2 tty-fill-cell-attr
  local0 TtyBuffer -> cells @ local0 tty-buffer-pitch 6 * + TtyCell byte-size 17 * + TTY-CELL-NORMAL 2 tty-fill-cell-attr
  local0 TtyBuffer -> cells @ local0 tty-buffer-pitch 6 * + TtyCell byte-size 19 * + TTY-CELL-DIM 1 tty-fill-cell-attr

  local0 TtyBuffer -> cells @ local0 tty-buffer-pitch 2 * + TtyCell byte-size 0 * + 0x31 20 tty-fill-cell-color

  nl local0 tty-buffer-draw
  local0 exit-frame
end
