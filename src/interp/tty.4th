0x5413 const> TIOCGWINSZ
0x5414 const> TIOCSWINSZ

def tty-read-size ( ++ lines columns )
  0 0 here TIOCGWINSZ current-output peek ioctl 0 int>= IF
    here dup peek-short
    swap 2 + peek-short
  ELSE 0 0
  THEN return2
end

0 var> tty-columns
0 var> tty-lines

def tty-getsize ( ++ lines columns )
  tty-lines peek tty-columns peek return2
end

def tty-update-size
  tty-read-size
  tty-columns poke
  tty-lines poke
end

0 var> tty-winch-sigaction

def tty-winch-handler
  s" WINCH " error-string/2
  tty-update-size
  tty-columns peek error-uint
  s" x" error-string/2
  tty-lines peek error-uint enl
  3 return0-n
end

def tty-install-winch
  make-sigaction tty-winch-sigaction poke
  ' tty-winch-handler 3 0 ffi-callback tty-winch-sigaction peek sa-handler poke
  SA-SIGINFO SA-RESTART logior tty-winch-sigaction peek sa-flags poke
  0 tty-winch-sigaction peek SIGWINCH sigaction
  exit-frame
end

def tty-init
  tty-install-winch
  tty-update-size
  exit-frame
end
