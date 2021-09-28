( Pixel buffers for a TTY screen with drawing optimized to only change state and write characters when changes have been made. )

struct: TtyScreen
int<32> field: width
int<32> field: height
pointer<any> field: front
pointer<any> field: back

def tty-screen-draw
  1 1 tty-cursor-to
  arg0 TtyScreen -> front @ tty-buffer-draw
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
  arg3 TtyCell byte-size + set-arg3
  arg2 TtyCell byte-size + set-arg2
  arg1 TtyCell byte-size - set-arg1
  arg1 0 > IF repeat-frame THEN 4 return0-n
end

def tty-screen-update-cells ( front front-pitch back back-pitch counter )
  ( only move to and draw changed cells. )
  arg4 arg2 arg3 arg1 min 0 tty-screen-update-row nl
  arg4 arg3 + 4 set-argn
  arg2 arg1 + set-arg2
  arg0 1 - set-arg0 arg0 0 > IF repeat-frame THEN 5 return0-n
end

def tty-screen-update
  ( only move to and draw changed cells. )
  1 1 tty-cursor-to
  arg0 TtyScreen -> front @ TtyBuffer -> cells @
  arg0 TtyScreen -> front @ tty-buffer-pitch
  arg0 TtyScreen -> back @ TtyBuffer -> cells @
  arg0 TtyScreen -> back @ tty-buffer-pitch
  arg0 TtyScreen -> height @
  tty-screen-update-cells
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

def tty-screen-swap
  arg0 tty-screen-swap-buffers
  arg0 tty-screen-update
  1 return0-n
end

def tty-screen-cells
  arg0 TtyScreen -> back @ TtyBuffer -> cells @ return1-1
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
