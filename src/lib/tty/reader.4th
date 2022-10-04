def tty-img-terminal-pair?
  arg1 whitespace? arg0 0x5D equals? and 2 return1-n
end

def read-tty-img ( ptr size reader n -- ptr size )
  arg1 reader-read-byte
  negative? UNLESS
    arg1 reader-peek-byte
    negative? UNLESS
      2dup tty-img-terminal-pair? IF
        arg1 reader-read-byte
        arg0 3 return1-n
      THEN
    THEN
    drop
    arg2 arg0 int> IF arg3 arg0 poke-off-byte ELSE drop THEN
    arg0 1 + set-arg0 repeat-frame
  THEN arg0 3 return1-n
end

def tty-img[
  0
  arg1 arg0 make-tty-buffer set-local0
  the-reader @ reader-read-byte
  negative? IF 0 2 return1-n ELSE drop THEN
  local0 TtyBuffer -> cells @
  arg1 arg0 * TtyCell sizeof *
  the-reader @ 0 read-tty-img 2 dropn
  local0 exit-frame
end
