" src/runner/thumb/linux/signals/constants.4th" load
" src/runner/thumb/linux/signals/types.4th" load

def print-signal-state
  s" Caught signal " error-string/2
  arg0 error-hex-uint enl
  s" From frame: " error-string/2
  current-frame parent-frame cell-size 4 * - 64 ememdump
  s" Signal stack: " error-string/2
  args args 512 ememdump drop
  s" Registers:" error-string/2 enl
  print-regs
end

def signals-handler
  arg0 print-signal-state
  bye
end

0 var> signals-old-handler

def signals-init
  0 0
  make-sigaction set-local0
  make-sigaction set-local1
  local1 signals-old-handler poke
  ' signals-handler 3 0 ffi-callback local0 sa-handler poke
  SA-SIGINFO local0 sa-flags poke
  local1 local0 SIGILL sigaction
  0 local0 SIGBUS sigaction
  0 local0 SIGSEGV sigaction
  exit-frame
end
