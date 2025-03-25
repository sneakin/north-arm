( DEFINED? NORTH-COMPILE-TIME IF
  sys-alias> es" [s"] cross-immediate
THEN )

( todo color-reset write-crnl )

DEFINED? es" UNLESS
  " src/lib/escaped-strings.4th" load
THEN

alias> < int<
alias> > int>
alias> <= int<=
alias> >= int>=
alias> .\n nl
alias> doc( ( immediate ( bad emacs )
alias> args( ( immediate ( bad emacs )
alias> u->f uint32->float32
alias> .d .i
alias> float-div float32-div
alias> logi badlog2-int
alias> RECURSE repeat-frame immediate

0x53544f50 const> terminator
def terminator? arg0 terminator equals? return1 end

DEFINED? NORTH-COMPILED-TIME IF
  sys-def global-var 0 var> exit-frame end

  sys-def constant
    0 const> next-integer UNLESS 0 THEN dict dict-entry-data poke exit-frame
  end
ELSE
  def global-var 0 var> exit-frame end

  def constant
    0 const> next-integer UNLESS 0 THEN dict dict-entry-data poke exit-frame
  end
THEN

defcol arg4 4 argn swap endcol

def drop2 2 return0-n end
def swapdrop arg0 2 return1-n end
def rotdrop2 arg0 3 return1-n end

def cell*
  arg0 cell-size int-mul return1
end

def cell+
  arg0 cell-size int-add return1
end

def cell+n
  arg0 cell* arg1 int-add return1
end

defcol returnN
  ( copy N values over the frame's return and FP. Return from the frame. )
  ( stack: frame ... values num-values return-addr )
  drop ( the definition's call frame)
  current-frame return-address peek ( save the frame's return )
  swap 1 + cell-size * ( number bytes to copy including return address )
  current-frame frame-byte-size + over - ( destination address )
  ( end the caller's frame )
  end-frame
  ( copy the values up the stack to overwrite the frame's call state )
  here cell-size 2 * + over 4 overn copy
  ( and move stack before returning from caller )
  move exit
endcol

defcol return-locals
  drop here current-frame swap int-sub cell-size int-div returnN
endcol

( " src/lib/linux.4th" load )
( cached-gettid
futex-wait-for-equals/3
futex-wake
futex-wake-op )

def control-code? arg0 32 int< return1 end

def bslc ( a shift -- high low )
  arg1 32 arg0 - bsr
  arg1 arg0 bsl set-arg0 set-arg1
end

def bsrc ( a shift -- high low )
  arg1 32 arg0 - bsl
  arg1 arg0 bsr set-arg1 set-arg0
end

def tty-reset
  s" \ec" write-string/2
end

def tty-erase s" \e[2J" write-string/2 end
def tty-erase-below s" \e[0J" write-string/2 end
def bold s" \e[1m" write-string/2 end
def dim s" \e[2m" write-string/2 end
def inverse s" \e[7m" write-string/2 end
def invisible s" \e[8m" write-string/2 end
def italic s" \e[3m" write-string/2 end
def underline s" \e[4m" write-string/2 end
def strike s" \e[9m" write-string/2 end
def blink-fast s" \e[5m" write-string/2 end

def color/2 ( bg fg ++ )
  s" \e[30;40m"
  0x30 arg0 + 3 overn 3 poke-off-byte
  0x30 arg1 + 3 overn 6 poke-off-byte
  write-string/2
end

def black 0 0 color/2 end
def red 0 1 color/2 end
def green 0 2 color/2 end
def yellow 0 3 color/2 end
def blue 0 4 color/2 end
def magenta 0 5 color/2 end
def cyan 0 6 color/2 end
def white 0 7 color/2 end
def tty-default-fg 0 7 color/2 end

def write-heading
    doc( Print the argument out underlined, bold, and on its own line. )
    bold underline arg0 write-line color-reset write-crnl
end

def tty-box-drawing-off 15 write-byte end
def tty-box-drawing-on 14 write-byte end
def tty-char-reset s" \e[0m" write-string/2 end
def tty-cursor-restore s" \e[u" write-string/2 end
( todo needs an arg )
def tty-csi ( n code -- )
  s" \e[" write-string/2
  arg1 write-int
  arg0 write-byte
  2 return0-n
end

def tty-cursor-to-column arg0 char-code G tty-csi end
def tty-cursor-home 0 tty-cursor-to-column end
def tty-cursor-up arg0 char-code A tty-csi end
def tty-cursor-right arg0 char-code C tty-csi end
def tty-cursor-save s" \e[s" write-string/2 end
def tty-cursor-to ( col row )
  s" \e[" write-string/2
  arg0 write-int
  s" ;" write-string/2
  arg1 write-int
  char-code f write-byte
end

def tty-show-cursor s" \e[?25h" write-string/2 end
def tty-hide-cursor s" \e[?25l" write-string/2 end

def read-byte
  ( fixme needs to read fd directly? )
  ( the-reader peek reader-read-byte return1 )
  0
  1 locals current-input peek read IF local0 ELSE -1 THEN return1
end

def tty-read
  read-byte 1 return2
end

( DOTIMES[ ]DOTIMES )
def DOTIMES[
  literal uint32 int32 0
  literal eip
  literal uint32 terminator
  literal int-add
  literal begin-frame
  literal arg0 literal arg1 literal int< ( todo switch to uint< which needs tty-filled-box to check size )
  POSTPONE UNLESS literal return-locals POSTPONE THEN
  return-locals
end immediate

def find-terminator
  arg0 top-frame uint< UNLESS false return1-1 THEN
  arg0 peek terminator equals? IF true return1 THEN
  arg0 up-stack set-arg0 repeat-frame
end

def bytes-to-terminator
  arg0 find-terminator IF here int-sub ELSE 0 THEN return1-1
end

def patch-terminator/2
  arg1 find-terminator IF
    arg0 swap poke
  THEN
  2 return0-n
end

def ]DOTIMES
    ( inc the counter )
    literal arg0 literal uint32 int32 1 literal int-add literal set-arg0
    ( calculate jump offset )
    literal int32
    frame-byte-size 5 cell+n rotdrop2
    here bytes-to-terminator int-sub op-size int-div
    ( loop )
    literal jump-rel
    ( patch the terminator to here less call frame )
    here
    dup bytes-to-terminator frame-byte-size 3 cell+n rotdrop2 -
    patch-terminator/2
    return-locals
end immediate

( s" vendor/north/src/02/rand.4th" load/2 )

( shift is in the wrong direction, is a roll )
alias> old-roll roll
alias> roll shift
alias> shift old-roll

$10FFFF const> UNICODE-MAX

def utf8-encode-second
    arg0 int32 $3F logand int32 $80 logior
    arg0 int32 6 bsr
    return2
end

def utf32->utf8
    doc( Convert an integer into an UTF-8 byte sequence as cells on the stack. )
    args( int32 ++ bytes... number-bytes )
    arg0 int32 $7F <= IF arg0 int32 1 return2 THEN
    arg0 int32 $7FF <= IF
        arg0 utf8-encode-second
        int32 $C0 logior
        int32 2 int32 3 returnN
    THEN
    arg0 int32 $FFFF <= IF
        arg0
        utf8-encode-second shift drop
        utf8-encode-second shift drop
        int32 $E0 logior
        int32 3 int32 4 returnN
    THEN
    arg0 UNICODE-MAX <= IF
        arg0
        utf8-encode-second shift drop
        utf8-encode-second shift drop
        utf8-encode-second shift drop
        int32 $F0 logior
        int32 4 int32 5 returnN
    THEN
    arg0 .\n .h " invalid UTF-32 code" " argument-error" error
end

def write-utf32-char-fn ( n bytes -- )
  arg0 arg0 seqn-size 1 - arg1 - seqn-peek write-byte
  2 return0-n
end

def write-utf32-char
  doc( Write a UTF-32 character to the output device as UTF-8 bytes. )
  0
  arg0 utf32->utf8 here set-local0
  ' write-utf32-char-fn local0 partial-first local0 seqn-size dotimes
end
