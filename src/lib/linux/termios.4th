" src/lib/linux/termios/constants.4th" load
( " src/lib/linux/termios/libc.4th" load )
" src/lib/linux/termios/ioctl.4th" load

44 const> termios-byte-size ( 4 ints, 1+19 bytes, 2 ints )

0 var> *termios*

def allot-termios
  termios-byte-size stack-allot exit-frame
end

def clone-termios
  0
  allot-termios set-local0
  arg0 local0 termios-byte-size copy
  local0 exit-frame ( todo more? )
end

allot-termios *termios* poke

def tty-termios
  ( *termios* @ null? UNLESS return1 THEN
  allot-termios dup *termios* !
  exit-frame )
  *termios* peek return1
end

def termios-lflag
    arg0 int32 3 cell+n return1-1
end

def termios-clear-lflag
    arg0 termios-lflag @
    arg1 lognot logand
    arg0 termios-lflag !
end

def termios-set-lflag
    arg0 termios-lflag @
    arg1 logior
    arg0 termios-lflag !
end

def termios-clear-lflags/2 ( fd termios ++ )
  ( Clear the terminal's lflags. )
    tty-termios dup arg1 tcgetattr
    int32 0 int<
    IF " failed to get attr" " input-dev-error" error
    ELSE arg0 local0 termios-clear-lflag
	 TCSANOW arg1 tcsetattr
	 int32 0 int< IF " failed to set attr" " input-dev-error" error THEN
    THEN
end

def termios-set-lflags/2 ( fd termios ++ )
    ( Set the terminal's lflags. )
    tty-termios dup arg1 tcgetattr
    int32 0 int<
    IF " failed to get attr" " input-dev-error" error
    ELSE arg0 local0 termios-set-lflag
	 TCSANOW arg1 tcsetattr
	 int32 0 int< IF " failed to set attr" " input-dev-error" error THEN
    THEN
end

def tty-enter-raw-mode/1 ( fd ++ )
  ( exit icanon|echo mode )
  arg0 ICANON ECHO logior termios-clear-lflags/2
end

def tty-exit-raw-mode/1 ( fd ++ )
  ( enter icanon|echo mode )
  arg0 ICANON ECHO logior termios-set-lflags/2
end

def tty-enter-raw-mode current-output @ tty-enter-raw-mode/1 int32 0 return1 end
def tty-exit-raw-mode current-output @ tty-exit-raw-mode/1 end

def tty-exit-echo-mode/1 ( fd ++ )
  ( exit echo mode )
  arg0 ECHO termios-clear-lflags/2
end

def tty-enter-echo-mode/1 ( fd ++ )
  ( enter echo mode )
  arg0 ECHO termios-set-lflags/2
end

( def tty-enter-echo-mode end
def tty-exit-echo-mode end
)

def tty-enter-echo-mode current-output @ tty-enter-echo-mode/1 int32 0 return1 end
def tty-exit-echo-mode current-output @ tty-exit-echo-mode/1 end
