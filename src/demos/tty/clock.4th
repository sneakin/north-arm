' alias UNLESS load-core THEN

' TtyScreen UNLESS
  s[ src/lib/time.4th
     src/lib/linux.4th
     src/lib/tty.4th
  ] load-list
THEN

s[ src/lib/geometry/angles.4th
   src/demos/tty/clock/segments.4th
   src/demos/tty/clock/stdio.4th
   src/demos/tty/clock/tty.4th
   src/demos/tty/clock/buffer.4th
] load-list

' getopt defined? UNLESS
  s[ src/lib/getopt.4th ] load-list
THEN

15 const> CLOCK-REDRAW-PERIOD

def tty-center-segment-clock ( rows cols -- row col )
  arg0 2 / tty-segment-width @ 2 * tty-segment-digit-spacing @ + tty-segment-field-spacing @ + 3 * 2 / -
  arg1 2 / tty-segment-height @ 2 / -
  set-arg1 set-arg0
end

def tty-raw-clock-loop ( tz )
  CLOCK-REALTIME clock-get-secs dup arg0 +
  tty-hide-cursor tty-erase
  ( tty-clock-resize )
  tty-getsize
  over 2 / over tty-center-segment-clock swap
  2dup local1 tty-raw-clock/3
  4 overn 2 / + local1 tty-raw-date/3
  1 1 tty-cursor-to tty-show-cursor
  ( exit the loop when 'q' is entered )
  0 0 here cell-size current-input @ 0 polled-read-fd 0 int> IF
    " q" contains? IF 1 return0-n THEN
  ELSE
    local0 1 + sleep-until drop
  THEN
  drop-locals repeat-frame
end

def tty-buffer-clock-check-size ( screen ++ resized? )
  tty-getsize arg0 tty-screen-resize!
  IF true exit-frame ELSE false set-arg0 THEN
end

def tty-buffer-clock-loop ( screen tz )
  arg1 tty-screen-resized? IF true 2 return1-n THEN
  CLOCK-REALTIME clock-get-secs 1 + dup arg0 +
  0 arg1 tty-screen-buffer make-tty-context set-local2
  arg1 tty-screen-erase
  ( arg1 tty-buffer-clock-check-size IF arg1 tty-screen-redraw THEN ) ( drop locals will cause problems )
  arg1 tty-screen-size
  over 2 / over tty-center-segment-clock ( swap )
  2dup local1 local2 tty-buffer-clock/4
  swap 4 overn 2 / + swap local1 local2 tty-buffer-date/4
  ( exit the loop when 'q' is entered )
  0 0 here cell-size current-input @ 0 polled-read-fd 0 int> IF
    " q" contains? IF false 2 return1-n THEN
    arg1 tty-screen-draw
  ELSE
    local0 sleep-until drop
    local1 CLOCK-REDRAW-PERIOD int-mod IF arg1 tty-screen-swap ELSE arg1 tty-screen-draw THEN
    2 tty-cursor-up
  THEN
  drop-locals repeat-frame
end

def tty-buffer-clock ( tz )
  0 tty-getsize make-tty-screen set-local0
  local0 tty-screen-erase
  local0 tty-screen-draw
  ( repeat this frame on resize )
  local0 arg0 tty-buffer-clock-loop IF drop-locals repeat-frame ELSE tty-show-cursor THEN
end

def tty-analog-clock-hand ( height width length% degrees context -- )
  arg2 int32->float32 100 int32->float32 float32-div
  ( calc center )
  arg0 tty-context-height 2 /
  arg0 tty-context-width 2 /
  2dup arg0 tty-context-move-to
  ( translate angle and calc end point /| )
  arg1 -90 + int32->float32 degrees->vec2d
  arg3 int32->float32 float32-mul local0 float32-mul float32->int32 local2 +
  swap
  4 argn int32->float32 float32-mul local0 float32-mul float32->int32 local1 +
  swap
  ( draw line )
  arg0 tty-context-line
  5 return0-n
end

0 var> tty-analog-clock-height
0 var> tty-analog-clock-width

60 60 * 48 * const> time-stamp-overflow-limiter

def tty-analog-clock-draw ( context timestamp -- )
  arg0 time-stamp-overflow-limiter floored-mod
  42 arg1 TtyContext -> char !
  ( center of clock )
  arg1 tty-context-height 2 /
  arg1 tty-context-width 2 /
  over 1 - tty-analog-clock-height @ dup IF min ELSE drop THEN
  over 1 - tty-analog-clock-width @ dup IF min ELSE drop THEN
  ( the face )
  TTY-CELL-DIM arg1 TtyContext -> attr poke-byte
  0x70 arg1 TtyContext -> color poke-byte
  ( 12 o'clock notch )
  4 overn 3 overn - 1 +
  4 overn 3 overn 20 / - 1 -
  2dup arg1 tty-context-move-to
  swap 4 overn 10 / +
  swap 3 overn 10 / + 1 +
  arg1 tty-context-ellipse
  ( face edge )
  4 overn 3 overn -
  4 overn 3 overn -
  2dup arg1 tty-context-move-to
  swap 4 overn 2 * +
  swap 3 overn 2 * +
  arg1 tty-context-ellipse
  ( the hands )
  TTY-CELL-NORMAL arg1 TtyContext -> attr poke-byte
  ( hours )
  0x33 arg1 TtyContext -> color poke-byte
  2dup 65 local0 30 * 3600 floored-div arg1 tty-analog-clock-hand
  ( minutes )
  0x77 arg1 TtyContext -> color poke-byte
  2dup 80 local0 6 * 60 floored-div arg1 tty-analog-clock-hand
  ( seconds )
  0x11 arg1 TtyContext -> color poke-byte
  2dup 95 local0 6 * arg1 tty-analog-clock-hand
  debug? IF
    0x22 arg1 TtyContext -> color poke-byte
    2dup 50 local0 6 * arg1 tty-analog-clock-hand
    0x44 arg1 TtyContext -> color poke-byte
    2dup 50 local0 6 * 360 int-mod arg1 tty-analog-clock-hand
  THEN
  2 return0-n
end

def tty-analog-clock-loop ( screen tz -- )
  0 0 0
  arg1 tty-screen-resized? IF true 2 return1-n THEN
  arg1 tty-screen-erase
  arg1 tty-screen-buffer make-tty-context set-local0
  42 local0 TtyContext -> char !
  CLOCK-REALTIME clock-get-secs 1 + set-local1
  local0 local1 arg0 + tty-analog-clock-draw
  ( exit the loop when 'q' is entered )
  0 0 here cell-size current-input @ 0 polled-read-fd 0 int> IF
    " q" contains? IF false 2 return1-n THEN
    arg1 tty-screen-draw
  ELSE
    local1 sleep-until drop
    local1 CLOCK-REDRAW-PERIOD int-mod IF arg1 tty-screen-swap ELSE arg1 tty-screen-draw THEN
    2 tty-cursor-up
  THEN
  drop-locals repeat-frame
end

def tty-analog-clock ( tz )
  0 tty-getsize make-tty-screen set-local0
  tty-hide-cursor
  local0 tty-screen-erase
  local0 tty-screen-draw
  ( repeat this frame on resize )
  local0 arg0 tty-analog-clock-loop IF drop-locals repeat-frame ELSE tty-show-cursor THEN
end

0 var> tty-clock-tz-offset
0 var> tty-clock-mode
0 var> tty-clock-interp

def tty-clock-opts-processor
  arg0 CASE
    s" h" OF-STR false 2 return1-n ENDOF
    s" i" OF-STR true tty-clock-interp ! true 2 return1-n ENDOF
    s" Z" OF-STR arg1 dup string-length parse-int
		 IF tty-clock-tz-offset !
		 ELSE s" Invalid time zone." error-line/2
		 THEN true 2 return1-n
	  ENDOF
    s" z" OF-STR arg1 dup string-length parse-int
		 IF hours->secs tty-clock-tz-offset !
		 ELSE s" Invalid time zone." error-line/2
		 THEN true 2 return1-n
	  ENDOF
    s" m" OF-STR arg1 tty-clock-mode ! true 2 return1-n ENDOF
    drop false 2 return1-n
  ENDCASE
end

" hiz:Z:m:" string-const> TTY-CLOCK-OPTS

def tty-clock-boot
  interp-init
  ' tty-clock-opts-processor TTY-CLOCK-OPTS getopt UNLESS
    s" Usage: clock [-z tz-offset-hours] [-z tz-offset-secs] [-m mode]" error-line/2
    s" Mode: a - analog, d - digital, r - raw terminal" error-line/2
  ELSE
    tty-clock-mode @ CASE
      s" a" OF-STR tty-clock-tz-offset @ tty-analog-clock ENDOF
      s" d" OF-STR tty-clock-tz-offset @ tty-buffer-clock ENDOF
      s" r" OF-STR tty-clock-tz-offset @ tty-raw-clock-loop ENDOF
      s" Unknown mode: " error-string/2 dup IF error-line THEN
    ENDCASE
  THEN
  tty-clock-interp @ IF interp THEN
  exit-frame
end
