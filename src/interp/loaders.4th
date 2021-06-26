def load-core
  s" ./src/interp/boot/init.4th" load/2
  exit-frame
end

def load-debug
  s" ./src/interp/boot/debug.4th" load/2
  exit-frame
end

def load-thumb-asm
  s" ./src/include/thumb-asm.4th" load/2
  exit-frame
end

def load-runner
  s" ./src/include/runner.4th" load/2
  exit-frame
end

def load-interp
  s" ./src/include/interp.4th" load/2
  exit-frame
end
