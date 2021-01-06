" src/runner/thumb/linux/signals/constants.4th" load
" src/runner/thumb/linux/signals/types.4th" load

def print-signal-state
  s" Caught signal " error-string/2
  arg0 error-hex-uint enl
  s" Registers:" error-string/2 enl
  print-regs
  s" From frame: " error-string/2
  current-frame parent-frame 64 ememdump
  s" Signal stack: " error-string/2
  current-frame 512 ememdump
  s" Signal info: " error-string/2
  arg1 arg2 over - ememdump
  s" Signal context: " error-string/2
  arg2 128 ememdump
end

def signals-abort-handler
  arg2 arg1 arg0 print-signal-state
  arg0 getpid kill
  -1 sysexit
end

defcol signals-trace-handler
  4 overn 4 overn 4 overn print-signal-state 3 dropn
  3 set-overn 2 dropn
endcol

0 var> signals-abort-sigaction
0 var> signals-trace-sigaction

def signals-init
  make-sigaction signals-abort-sigaction poke
  ' signals-abort-handler 3 0 ffi-callback signals-abort-sigaction peek sa-handler poke
  SA-SIGINFO SA-RESETHAND logior signals-abort-sigaction peek sa-flags poke
  make-sigaction signals-trace-sigaction poke
  ' signals-trace-handler 3 0 ffi-callback signals-trace-sigaction peek sa-handler poke
  SA-SIGINFO SA-RESTART logior signals-trace-sigaction peek sa-flags poke
  0 signals-abort-sigaction peek SIGILL sigaction
  0 signals-abort-sigaction peek SIGBUS sigaction
  0 signals-abort-sigaction peek SIGSEGV sigaction
  0 signals-abort-sigaction peek SIGSYS sigaction
  0 signals-trace-sigaction peek SIGUSR1 sigaction
  exit-frame
end
