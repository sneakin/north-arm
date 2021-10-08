def write-char-rep ( c n )
  arg1 write-byte
  arg0 1 - set-arg0
  arg0 0 int> IF repeat-frame THEN 2 return0-n
end

def tty-print-segment-vertical-row
  arg0 SEGMENT-LEFT logand IF s" *" ELSE s"  " THEN write-string/2
  32 tty-segment-bar-width @ write-char-rep
  arg0 SEGMENT-RIGHT logand IF s" *" ELSE s"  " THEN write-string/2
  1 return0-n
end
  
def tty-print-segment-horiz
  space
  42 tty-segment-bar-width @ write-char-rep
  space
end

def print-segment-verticals
  arg1 tty-print-segment-vertical-row
  nl
  arg0 1 + set-arg0
  arg0 tty-segment-bar-height @ int< IF repeat-frame THEN 2 return0-n
end

def print-segment-bits ( buffer bits -- )
  arg0 SEGMENT-TOP logand IF
    tty-print-segment-horiz
  ELSE arg0 SEGMENT-TOP-ALL logand tty-print-segment-vertical-row
  THEN nl
  arg0 SEGMENT-TOP-LEFT SEGMENT-TOP-RIGHT logior logand 0 print-segment-verticals
  arg0 SEGMENT-CENTER logand IF
    tty-print-segment-horiz
  ELSE arg0 tty-print-segment-vertical-row
  THEN nl
  arg0 SEGMENT-BOT-LEFT SEGMENT-BOT-RIGHT logior logand 0 print-segment-verticals
  arg0 SEGMENT-BOT logand IF
    tty-print-segment-horiz
  ELSE arg0 SEGMENT-BOT-ALL logand tty-print-segment-vertical-row
  THEN nl
end

def print-segment-digit
  arg0 int->segment-bits print-segment-bits
end

def print-all-segment-bits
  arg0 1 - set-arg0
  arg0 write-int nl
  arg0 print-segment-bits
  arg0 0 int> IF repeat-frame THEN
end

def print-segment-digits
  arg0 1 - set-arg0
  arg0 write-int nl
  arg0 print-segment-digit
  arg0 0 int> IF repeat-frame THEN
end
