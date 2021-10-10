' alias [UNLESS] load-core [THEN]

' TtyScreen [UNLESS]
s[ src/lib/tty.4th
   src/lib/time.4th
   src/lib/linux/clock.4th
   src/lib/geometry/angles.4th
] load-list
[THEN]

s[ src/demos/tty/clock/segments.4th
   src/demos/tty/clock/stdio.4th
   src/demos/tty/clock/tty.4th
   src/demos/tty/clock/buffer.4th
] load-list

15 const> CLOCK-REDRAW-PERIOD

def tty-center-segment-clock ( rows cols -- row col )
  arg0 2 / tty-segment-width @ 2 * tty-segment-digit-spacing @ + tty-segment-field-spacing @ + 3 * 2 / -
  arg1 2 / tty-segment-height @ 2 / -
  set-arg1 set-arg0
end

def tty-raw-clock-loop ( tz )
  get-time-secs dup arg0 +
  tty-hide-cursor tty-erase
  ( tty-clock-resize )
  tty-getsize
  over 2 / over tty-center-segment-clock swap
  2dup local1 tty-raw-clock/3
  4 overn 2 / + local1 tty-raw-date/3
  1 1 tty-cursor-to tty-show-cursor
  local0 1 + sleep-until drop
  drop-locals repeat-frame
end

def tty-buffer-clock-check-size ( screen ++ resized? )
  tty-getsize arg0 tty-screen-resize!
  IF true exit-frame ELSE false set-arg0 THEN
end

def tty-buffer-clock-loop ( screen tz )
  arg1 tty-screen-resized? IF true 2 return1-n THEN
  get-time-secs 1 + dup arg0 +
  0 arg1 tty-screen-buffer make-tty-context set-local2
  arg1 tty-screen-erase
  ( arg1 tty-buffer-clock-check-size IF arg1 tty-screen-redraw THEN ) ( drop locals will cause problems )
  arg1 tty-screen-size
  over 2 / over tty-center-segment-clock ( swap )
  2dup local1 local2 tty-buffer-clock/4
  swap 4 overn 2 / + swap local1 local2 tty-buffer-date/4
  local0 sleep-until drop
  local1 CLOCK-REDRAW-PERIOD int-mod IF arg1 tty-screen-swap ELSE arg1 tty-screen-draw THEN
  drop-locals repeat-frame
end

def tty-buffer-clock ( tz )
  0 tty-getsize make-tty-screen set-local0
  local0 tty-screen-erase
  local0 tty-screen-draw
  ( repeat this frame on resize )
  local0 arg0 tty-buffer-clock-loop IF drop-locals repeat-frame THEN
end

def tty-analog-clock-hand ( height width length% degrees context -- )
  arg2 int32->float32 100 int32->float32 float32-div
  ( calc center )
  arg0 tty-context-height 2 /
  arg0 tty-context-width 2 /
  2dup arg0 tty-context-move-to
  ( translate angle and calc end point /| )
  arg1 180 + int32->float32 degrees->vec2d
  arg3 int32->float32 float32-mul local0 float32-mul float32->int32 local2 +
  swap 4 argn int32->float32 float32-mul local0 float32-mul float32->int32 local1 +
  swap
  ( draw line )
  arg0 tty-context-line
  5 return0-n
end

0 var> tty-analog-clock-height
0 var> tty-analog-clock-width

def tty-analog-clock-loop ( screen tz -- )
  arg1 tty-screen-resized? IF true 2 return1-n THEN
  0 0 0
  arg1 tty-screen-buffer make-tty-context set-local0
  42 local0 TtyContext -> char !
  get-time-secs 1 + set-local1
  local1 arg0 + set-local2
  arg1 tty-screen-erase
  ( center of clock )
  local0 tty-context-height 2 /
  local0 tty-context-width 2 /
  over 1 - tty-analog-clock-height @ dup IF min ELSE drop THEN
  over 1 - tty-analog-clock-width @ dup IF min ELSE drop THEN
  ( the face )
  TTY-CELL-DIM local0 TtyContext -> attr poke-byte
  0x70 local0 TtyContext -> color poke-byte
  ( 12 o'clock notch )
  4 overn 3 overn - 1 +
  4 overn 3 overn 20 / -
  2dup local0 tty-context-move-to
  swap 4 overn 10 / +
  swap 3 overn 10 / +
  local0 tty-context-ellipse
  ( face edge )
  4 overn 3 overn -
  4 overn 3 overn -
  2dup local0 tty-context-move-to
  swap 4 overn 2 * +
  swap 3 overn 2 * +
  local0 tty-context-ellipse
  ( the hands )
  TTY-CELL-NORMAL local0 TtyContext -> attr poke-byte
  0x33 local0 TtyContext -> color poke-byte
  2dup 65 local2 time-stamp-hours 5 * -6 * local0 tty-analog-clock-hand
  0x77 local0 TtyContext -> color poke-byte
  2dup 80 local2 time-stamp-minutes -6 * local0 tty-analog-clock-hand
  0x11 local0 TtyContext -> color poke-byte
  2dup 95 local2 time-stamp-seconds -6 * local0 tty-analog-clock-hand
  debug? IF
    0x22 local0 TtyContext -> color poke-byte
    2dup 50 local2 6 * local0 tty-analog-clock-hand
    0x44 local0 TtyContext -> color poke-byte
    2dup 50 local2 6 * 360 int-mod local0 tty-analog-clock-hand
  THEN
  local1 sleep-until drop
  local1 CLOCK-REDRAW-PERIOD int-mod IF arg1 tty-screen-swap ELSE arg1 tty-screen-draw THEN
  drop-locals repeat-frame
end

def tty-analog-clock ( tz )
  0 tty-getsize make-tty-screen set-local0
  local0 tty-screen-erase
  local0 tty-screen-draw
  ( repeat this frame on resize )
  local0 arg0 tty-analog-clock-loop IF drop-locals repeat-frame THEN
end
