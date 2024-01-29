s" src/demos/tty/clock/segment-constants.4th" load/2

def int->segment-bits
  arg0 0xF logand cell-size int-mul segment-digits peek-off set-arg0
end

def tty-segment-size! ( height width )
  arg0 2 int> arg1 4 int> logand IF
    arg0 tty-segment-width !
    tty-segment-width @ 2 - tty-segment-bar-width !
    arg1 tty-segment-height !
    tty-segment-height @ 3 - 2 / tty-segment-bar-height !
  ELSE s" invalid size" error-line/2
  THEN 2 return0-n
end

def tty-segment-reset-size!
  7 6 tty-segment-size!
end

def tty-clock-resize
  tty-getsize
  6 / swap
  6 / swap
  tty-segment-size!
end
