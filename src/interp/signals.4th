def print-signal-state
  s" Caught signal " error-string/2
  arg0 error-hex-uint enl
  s" From frame: " error-string/2
  current-frame parent-frame cell-size 4 * - 64 ememdump
  s" Signal stack: " error-string/2
  args args 64 ememdump drop
  s" Registers:" error-string/2 enl
  print-regs
end
