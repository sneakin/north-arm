s[ src/lib/linux/signals/constants.4th
   src/lib/linux/signals/types.4th
   src/lib/pointers.4th
] load-list

def signal->string ( signum -- name )
  arg0 ' SIGHUP ' SIGUNUSED cs bound-dict-lookup-by-value
  IF dict-entry-name peek cs int-add ELSE " Unknown" THEN set-arg0
end

def signal-state-registers  8 cell-size * arg0 + set-arg0 end

def print-op-name ( dict op -- )
  arg0 op-mask logand dup error-hex-uint espace
  cs + arg1 dict-contains?/2 IF
    drop
    dict-entry-name peek cs + error-string
  ELSE
    drop
    dict-entry-name peek cs + 
    dup string-length 16 min
    error-string/2
  THEN
  2 return0-n
end

8 var> stack-frame-depth

def print-stack-frame-args ( fp max n -- )
  arg1 arg0 int> IF
    arg2 frame-args arg0 seq-peek espace error-hex-uint
    arg0 1 + set-arg0 repeat-frame
  THEN 3 return0-n
end

def print-stack-frame
  arg0 error-hex-uint espace
  s" -> " error-string/2
  arg1 arg0 return-address peek op-size - peek print-op-name
  arg0 4 0 print-stack-frame-args
  enl 2 return0-n
end

def print-stack-trace ( fp dict n -- )
  arg2 stack-pointer? IF
    arg1 arg2 print-stack-frame
    arg2 parent-frame dup IF
      set-arg2
      arg0 0 int> IF arg0 1 - set-arg0 repeat-frame THEN
    THEN
  THEN 3 return0-n
end

def print-eip ( dict eip -- )
  arg0 error-hex-uint espace
  arg0 stack-pointer? arg0 code-pointer? or IF
    arg1 arg0 op-size - peek print-op-name espace
    arg1 arg0 peek print-op-name
  THEN enl 2 return0-n
end

def print-signal-state
  enl s" PID " error-string/2 getpid error-uint
  s"  caught signal " error-string/2
  arg0 error-uint ' signal->string IF space arg0 signal->string error-string THEN enl
  debug? IF
    s" Registers now:" error-string/2 enl
    print-regs
    s" Signal stack: " error-string/2
    current-frame 512 cmemdump
    s" Signal info: " error-string/2
    arg1 arg2 over - cmemdump
    s" Signal context: " error-string/2
    arg2 128 cmemdump
  THEN
  s" Signal context registers: " error-line/2
  arg2 signal-state-registers NORTH-BUILD-TIME 1634096442 int> IF print-regs/1 ELSE print-regs THEN
  ( fails if the signal happens in a syscall as FP and EIP are reused )
  NORTH-BUILD-TIME 1634096442 int> IF
    s" EIP: " error-string/2
    arg2 signal-state-registers dict-reg seq-peek
    arg2 signal-state-registers eip-reg seq-peek print-eip
    s" Stack: " error-line/2
    arg2 signal-state-registers 0 seq-peek error-hex-uint espace
    arg2 signal-state-registers sp-reg seq-peek 128 cmemdump
    arg2 signal-state-registers fp-reg seq-peek
    dup stack-pointer? IF
      s" Frames: " error-line/2
      arg2 signal-state-registers dict-reg seq-peek
      stack-frame-depth @ print-stack-trace
    THEN
    ( todo proper call trace )
  THEN
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
  0 signals-trace-sigaction peek SIGCHLD sigaction
  0 signals-quiet-sigaction peek SIGUSR2 sigaction
  0 signals-quiet-sigaction peek SIGALRM sigaction
  exit-frame
end
