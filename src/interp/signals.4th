" src/lib/linux/signals/constants.4th" load
" src/lib/linux/signals/types.4th" load

def signal->string ( signum -- name )
  arg0 ' SIGHUP ' SIGUNUSED cs bound-dict-lookup-by-value
  IF dict-entry-name peek cs int-add ELSE " Unknown" THEN set-arg0
end

def print-signal-state
  s" PID " error-string/2 getpid error-uint
  s"  caught signal " error-string/2
  arg0 error-uint ' signal->string IF space arg0 signal->string error-string THEN enl
  s" Registers now:" error-string/2 enl
  print-regs
  s" From frame: " error-string/2
  8 4 + cell-size * arg2 + @ dup error-hex-uint
  dup here uint>= IF 64 enl cmemdump ELSE s"  none" error-line/2 THEN
  s" Signal stack: " error-string/2
  current-frame 512 cmemdump
  s" Signal info: " error-string/2
  arg1 arg2 over - cmemdump
  s" Signal context: " error-string/2
  arg2 128 cmemdump
  s" Signal context registers: " error-line/2
  8 cell-size * arg2 + print-regs/1
end

def signals-abort-handler
  arg2 arg1 arg0 print-signal-state
  arg0 getpid kill ( want the parent process to see an unclean exit )
  abort ( todo drop to debugger before resignaling )
end

def signals-trace-handler
  arg2 arg1 arg0 print-signal-state
  3 return0-n
end

def signals-quiet-handler
  s" Caught signal " error-string/2 arg0 signal->string error-string enl
  3 return0-n
end

0 var> signals-abort-sigaction
0 var> signals-trace-sigaction
0 var> signals-quiet-sigaction

def signals-init
  make-sigaction signals-abort-sigaction poke
  ' signals-abort-handler 3 0 ffi-callback signals-abort-sigaction peek sa-handler poke
  SA-SIGINFO SA-RESETHAND logior signals-abort-sigaction peek sa-flags poke
  make-sigaction signals-trace-sigaction poke
  ' signals-trace-handler 3 0 ffi-callback signals-trace-sigaction peek sa-handler poke
  SA-SIGINFO SA-RESTART logior signals-trace-sigaction peek sa-flags poke
  make-sigaction signals-quiet-sigaction poke
  ' signals-quiet-handler 3 0 ffi-callback signals-quiet-sigaction peek sa-handler poke
  SA-SIGINFO SA-RESTART logior signals-quiet-sigaction peek sa-flags poke
  0 signals-abort-sigaction peek SIGILL sigaction
  0 signals-abort-sigaction peek SIGBUS sigaction
  0 signals-abort-sigaction peek SIGSEGV sigaction
  0 signals-abort-sigaction peek SIGSYS sigaction
  0 signals-trace-sigaction peek SIGUSR1 sigaction
  0 signals-quiet-sigaction peek SIGCHLD sigaction
  0 signals-quiet-sigaction peek SIGUSR2 sigaction
  0 signals-quiet-sigaction peek SIGALRM sigaction
  exit-frame
end
