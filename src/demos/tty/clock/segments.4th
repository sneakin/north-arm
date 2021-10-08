0x0 const> SEGMENT-OFF
0x1 const> SEGMENT-TOP
0x2 const> SEGMENT-TOP-LEFT
0x4 const> SEGMENT-TOP-RIGHT
0x8 const> SEGMENT-CENTER
0x10 const> SEGMENT-BOT
0x20 const> SEGMENT-BOT-LEFT
0x40 const> SEGMENT-BOT-RIGHT
0xFF const> SEGMENT-ALL

SEGMENT-TOP-RIGHT SEGMENT-BOT-RIGHT logior const> SEGMENT-RIGHT
SEGMENT-TOP-LEFT SEGMENT-BOT-LEFT logior const> SEGMENT-LEFT
SEGMENT-TOP SEGMENT-TOP-LEFT SEGMENT-TOP-RIGHT logior logior const> SEGMENT-TOP-ALL
SEGMENT-BOT SEGMENT-BOT-LEFT SEGMENT-BOT-RIGHT logior logior const> SEGMENT-BOT-ALL

( F ) SEGMENT-LEFT SEGMENT-TOP SEGMENT-CENTER logior logior
( E ) SEGMENT-LEFT SEGMENT-TOP SEGMENT-CENTER SEGMENT-BOT logior logior logior
( d ) SEGMENT-RIGHT SEGMENT-CENTER SEGMENT-BOT SEGMENT-BOT-LEFT logior logior logior
( C ) SEGMENT-LEFT SEGMENT-TOP SEGMENT-BOT logior logior
( b ) SEGMENT-LEFT SEGMENT-CENTER SEGMENT-BOT SEGMENT-BOT-RIGHT logior logior logior
( A ) SEGMENT-TOP SEGMENT-LEFT SEGMENT-RIGHT SEGMENT-CENTER logior logior logior
( 9 ) SEGMENT-TOP SEGMENT-TOP-LEFT SEGMENT-CENTER SEGMENT-RIGHT logior logior logior
( 8 ) SEGMENT-ALL
( 7 ) SEGMENT-TOP SEGMENT-TOP-RIGHT SEGMENT-BOT-RIGHT logior logior
( 6 ) SEGMENT-TOP SEGMENT-LEFT SEGMENT-CENTER SEGMENT-BOT-RIGHT SEGMENT-BOT logior logior logior logior
( 5 ) SEGMENT-TOP SEGMENT-TOP-LEFT SEGMENT-CENTER SEGMENT-BOT-RIGHT SEGMENT-BOT logior logior logior logior
( 4 ) SEGMENT-TOP-LEFT SEGMENT-RIGHT SEGMENT-CENTER logior logior
( 3 ) SEGMENT-TOP SEGMENT-CENTER SEGMENT-BOT SEGMENT-RIGHT logior logior logior
( 2 ) SEGMENT-TOP SEGMENT-TOP-RIGHT SEGMENT-CENTER SEGMENT-BOT-LEFT SEGMENT-BOT logior logior logior logior
( 1 ) SEGMENT-RIGHT
( 0 ) SEGMENT-TOP SEGMENT-LEFT SEGMENT-RIGHT SEGMENT-BOT logior logior logior
here const> segment-digits

def int->segment-bits
  arg0 0xF logand cell-size int-mul segment-digits peek-off set-arg0
end

6 var> tty-segment-width
tty-segment-width @ 2 - var> tty-segment-bar-width
7 var> tty-segment-height
tty-segment-height @ 3 - 2 / var> tty-segment-bar-height

1 var> tty-segment-digit-spacing
4 var> tty-segment-field-spacing

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
