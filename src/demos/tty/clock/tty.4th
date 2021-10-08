def tty-print-segment-verticals
  arg3 arg2 arg0 + tty-cursor-to
  arg1 tty-print-segment-vertical-row
  arg0 1 + set-arg0
  arg0 tty-segment-bar-height @ int< IF repeat-frame THEN 2 return0-n
end

( todo when the sides are on, but the horizontal is off, fill in the respective corner. )
( todo when the sides are both on, but the center is off, fill in the middle hole. )
( todo TtyBuffer drawing )

def tty-print-segment-bits ( col row bits -- )
  arg2 arg1 tty-cursor-to
  arg0 SEGMENT-TOP logand IF
    arg0 tty-print-segment-horiz
  ELSE arg0 SEGMENT-TOP-ALL logand tty-print-segment-vertical-row
  THEN
  arg2 arg1 1 + arg0 SEGMENT-TOP-LEFT SEGMENT-TOP-RIGHT logior logand 0 tty-print-segment-verticals
  arg2 arg1 1 + tty-segment-bar-height @ + tty-cursor-to
  arg0 SEGMENT-CENTER logand IF
    arg0 tty-print-segment-horiz
  ELSE arg0 tty-print-segment-vertical-row
  THEN
  arg2 arg1 2 + tty-segment-bar-height @ + arg0 SEGMENT-BOT-LEFT SEGMENT-BOT-RIGHT logior logand 0 tty-print-segment-verticals
  arg2 arg1 2 + tty-segment-bar-height @ dup + + tty-cursor-to
  arg0 SEGMENT-BOT logand IF
    arg0 tty-print-segment-horiz
  ELSE arg0 SEGMENT-BOT-ALL logand tty-print-segment-vertical-row
  THEN
  nl
  3 return0-n
end

def tty-print-segment-digit ( col row n -- )
  arg2 arg1 arg0 int->segment-bits tty-print-segment-bits 3 return0-n
end

def tty-print-time ( col row h m s -- )
  ( hours )
  4 argn arg3 arg2 10 / tty-print-segment-digit
  4 argn tty-segment-width @ + tty-segment-digit-spacing @ + arg3 arg2 10 mod tty-print-segment-digit
  ( minutes )
  4 argn tty-segment-width @ 2 * + tty-segment-digit-spacing @ + tty-segment-field-spacing @ + arg3 arg1 10 / 10 mod tty-print-segment-digit
  4 argn tty-segment-width @ 3 * + tty-segment-digit-spacing @ 3 * + tty-segment-field-spacing @ 1 * + arg3 arg1 10 mod tty-print-segment-digit
  ( seconds )
  4 argn tty-segment-width @ 4 * + tty-segment-digit-spacing @ 4 * + tty-segment-field-spacing @ 2 * + arg3 arg0 10 / 10 mod tty-print-segment-digit
  4 argn tty-segment-width @ 5 * + tty-segment-digit-spacing @ 5 * + tty-segment-field-spacing @ 2 * + arg3 arg0 10 mod tty-print-segment-digit
end

def tty-raw-clock/3 ( col row time )
  arg2 arg1 arg0 time-stamp-hours arg0 time-stamp-minutes arg0 time-stamp-seconds tty-print-time
  3 return0-n
end

def tty-raw-date/3 ( col row time )
  arg0 time-stamp-date
  arg2 arg1 local1 local2 local0 tty-print-time
  3 return0-n
end
