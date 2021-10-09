def draw-segment-vertical-row
  arg1 SEGMENT-LEFT logand IF s" *" ELSE s"  " THEN arg0 tty-context-write-string/3
  32 tty-segment-bar-width @ arg0 tty-context-write-byte-rep
  arg1 SEGMENT-RIGHT logand IF s" *" ELSE s"  " THEN arg0 tty-context-write-string/3
  1 return0-n
end

def draw-segment-verticals
  4 argn arg1 + arg3 arg0 tty-context-move-to
  arg2 arg0 draw-segment-vertical-row
  arg1 1 + set-arg1
  arg1 tty-segment-bar-height @ int< IF repeat-frame THEN 4 return0-n
end

def draw-segment-horiz
  32 arg0 tty-context-write-byte
  42 tty-segment-bar-width @ arg0 tty-context-write-byte-rep
  32 arg0 tty-context-write-byte
  1 return0-n
end

def draw-segment-bits ( row col context bits -- )
  arg3 arg2 arg1 tty-context-move-to
  arg0 SEGMENT-TOP logand IF
    arg1 draw-segment-horiz
  ELSE arg0 SEGMENT-TOP-ALL logand arg1 draw-segment-vertical-row
  THEN
  arg3 1 + arg2 arg0 SEGMENT-TOP-LEFT SEGMENT-TOP-RIGHT logior logand 0 arg1 draw-segment-verticals
  arg3 1 + tty-segment-bar-height @ + arg2 arg1 tty-context-move-to
  arg0 SEGMENT-CENTER logand IF
    arg1 draw-segment-horiz
  ELSE arg0 arg1 draw-segment-vertical-row
  THEN
  arg3 2 + tty-segment-bar-height @ + arg2 arg0 SEGMENT-BOT-LEFT SEGMENT-BOT-RIGHT logior logand 0 arg1 draw-segment-verticals
  arg3 2 + tty-segment-bar-height @ dup + + arg2 arg1 tty-context-move-to
  arg0 SEGMENT-BOT logand IF
    arg1 draw-segment-horiz
  ELSE arg0 SEGMENT-BOT-ALL logand arg1 draw-segment-vertical-row
  THEN
  4 return0-n
end

def draw-segment-digit ( row col context n -- )
  arg3 arg2 arg1 arg0 int->segment-bits draw-segment-bits 4 return0-n
end

( todo needs to make the context )
def draw-segment-time ( row col h m s context -- )
  ( hours )
  5 argn 4 argn arg0 arg3 10 / draw-segment-digit
  5 argn
  4 argn tty-segment-width @ + tty-segment-digit-spacing @ +
  arg0
  arg3 10 mod
  draw-segment-digit
  ( minutes )
  5 argn 4 argn tty-segment-width @ 2 * + tty-segment-digit-spacing @ + tty-segment-field-spacing @ + arg0 arg2 10 / 10 mod draw-segment-digit
  5 argn 4 argn tty-segment-width @ 3 * + tty-segment-digit-spacing @ 3 * + tty-segment-field-spacing @ 1 * + arg0 arg2 10 mod draw-segment-digit
  ( seconds )
  5 argn 4 argn tty-segment-width @ 4 * + tty-segment-digit-spacing @ 4 * + tty-segment-field-spacing @ 2 * + arg0 arg1 10 / 10 mod draw-segment-digit
  5 argn 4 argn tty-segment-width @ 5 * + tty-segment-digit-spacing @ 5 * + tty-segment-field-spacing @ 2 * + arg0 arg1 10 mod draw-segment-digit
end

def tty-buffer-clock/4 ( col row time buffer )
  arg3 arg2
  arg1 time-stamp-hours
  arg1 time-stamp-minutes
  arg1 time-stamp-seconds
  arg0 draw-segment-time
  4 return0-n
end

def tty-buffer-date/4 ( col row time buffer )
  arg1 time-stamp-date
  arg3 arg2 local1 local2 local0 arg0 draw-segment-time
  4 return0-n
end
