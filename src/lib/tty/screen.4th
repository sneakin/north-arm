( Pixel buffers for a TTY screen with drawing optimized to only change state and write characters when changes have been made. )

struct: TtyScreen
int field: width
int field: height
pointer<any> field: front
pointer<any> field: back

def tty-screen-size ( screen -- rows cols )
  arg0 TtyScreen -> width @
  arg0 TtyScreen -> height @
  set-arg0 return1
end

def tty-screen-redraw
  tty-cursor-save
  1 1 tty-cursor-to
  tty-hide-cursor
  arg0 TtyScreen -> front @ tty-buffer-draw
  tty-cursor-restore
end

def tty-screen-update-row ( front back counter num-skipped )
  ( only move to and draw changed cells. )
  ( dump-stack arg3 16 memdump arg2 16 memdump )
  arg3 arg2 tty-cell-equals? IF
    arg0 1 + set-arg0
  ELSE ( move cursor, write cell )
    arg0 0 > IF arg0 tty-cursor-right 0 set-arg0 THEN
    arg3 tty-cell-draw
  THEN
  arg3 TtyCell struct -> byte-size @ + set-arg3
  arg2 TtyCell struct -> byte-size @ + set-arg2
  arg1 TtyCell struct -> byte-size @ - set-arg1
  arg1 0 > IF repeat-frame THEN 4 return0-n
end

def tty-screen-update-cells ( front front-pitch back back-pitch counter )
  ( only move to and draw changed cells. )
  arg4 arg2 arg3 arg1 min 0 tty-screen-update-row
  arg4 arg3 + 4 set-argn
  arg2 arg1 + set-arg2
  arg0 1 - set-arg0 arg0 0 > IF nl repeat-frame THEN 5 return0-n
end

def tty-screen-update
  ( only move to and draw changed cells. )
  tty-cursor-save
  1 1 tty-cursor-to
  arg0 TtyScreen -> front @ TtyBuffer -> cells @
  arg0 TtyScreen -> front @ tty-buffer-pitch
  arg0 TtyScreen -> back @ TtyBuffer -> cells @
  arg0 TtyScreen -> back @ tty-buffer-pitch
  arg0 TtyScreen -> height @
  tty-screen-update-cells
  tty-cursor-restore
  1 return0-n
end

def tty-screen-swap-buffers
  arg0 TtyScreen -> front @
  arg0 TtyScreen -> back @
  arg0 TtyScreen -> front !
  arg0 TtyScreen -> back !
  1 return0-n
end

def tty-screen-copy-up
  arg0 TtyScreen -> back @ TtyBuffer -> cells @
  arg0 TtyScreen -> front @ TtyBuffer -> cells @
  arg0 TtyScreen -> back @ tty-buffer-size
  copy
  1 return0-n
end

def tty-screen-copy-down
  arg0 TtyScreen -> front @ TtyBuffer -> cells @
  arg0 TtyScreen -> back @ TtyBuffer -> cells @
  arg0 TtyScreen -> front @ tty-buffer-size
  copy
  1 return0-n
end

def tty-screen-swap
  arg0 tty-screen-swap-buffers
  arg0 tty-screen-update
  1 return0-n
end

def tty-screen-swap-copy
  arg0 tty-screen-swap
  arg0 tty-screen-copy-down
  1 return0-n
end

def tty-screen-draw
  arg0 tty-screen-swap-buffers
  arg0 tty-screen-redraw
  1 return0-n
end

def tty-screen-draw-copy
  arg0 tty-screen-redraw
  arg0 tty-screen-copy-down
  1 return0-n
end

def tty-screen-cells
  arg0 TtyScreen -> back @ TtyBuffer -> cells @ set-arg0
end

def tty-screen-buffer
  arg0 TtyScreen -> back @ set-arg0
end

def tty-screen-context
  arg0 tty-screen-buffer make-tty-context exit-frame
end

def make-tty-screen ( rows cols ++ screen )
  0 TtyScreen make-instance set-local0
  arg0 local0 TtyScreen -> width !
  arg1 local0 TtyScreen -> height !
  arg1 arg0 make-tty-buffer local0 TtyScreen -> front !
  arg1 arg0 make-tty-buffer local0 TtyScreen -> back !
  local0 exit-frame
end

def tty-screen-erase
  arg0 TtyScreen -> back @ tty-buffer-erase
  1 return0-n
end

def tty-screen-erase-front
  arg0 TtyScreen -> front @ tty-buffer-erase
  1 return0-n
end

def tty-screen-resize! ( rows cols screen ++ screen allot? )
  arg0 TtyScreen -> width @ arg1 equals?
  arg0 TtyScreen -> height @ arg2 equals?
  logand UNLESS
    arg2 arg1 arg0 TtyScreen -> front @ tty-buffer-resize! 2 dropn
    arg2 arg1 arg0 TtyScreen -> back @ tty-buffer-resize! 2 dropn
    arg1 arg0 TtyScreen -> width !
    arg2 arg0 TtyScreen -> height !
    arg0 true exit-frame
  THEN
  arg0 set-arg2
  false 2 return1-n
end

def tty-screen-resized?
  tty-getsize
  arg0 TtyScreen -> width @ equals?
  swap arg0 TtyScreen -> height @ equals?
  logand not set-arg0
end
