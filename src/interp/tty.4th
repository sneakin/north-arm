0x5413 const> TIOCGWINSZ
0x5414 const> TIOCSWINSZ

def tty-getsize
  0 0 here TIOCGWINSZ current-input peek ioctl 0 int>= IF
    here dup peek-short
    swap 2 + peek-short
  ELSE 0 0
  THEN return2
end

0 var> tty-columns
0 var> tty-lines

def tty-update-size
  tty-getsize
  tty-lines poke
  tty-columns poke
end

0 var> tty-winch-sigaction

defcol tty-winch-handler
  s" WINCH" error-line/2
  tty-update-size
  tty-columns peek error-hex-uint espace
  tty-lines peek error-hex-uint enl
  3 set-overn 2 dropn exit
endcol

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
