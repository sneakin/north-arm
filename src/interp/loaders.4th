def load-core
  s" ./src/interp/boot/init.4th" drop load
  exit-frame
end

def load-debug
  s" ./src/interp/boot/debug.4th" drop load
  exit-frame
end

def load-thumb-asm
  s" ./src/interp/boot/load/thumb-asm.4th" drop load
  exit-frame
end

def load-runner
  s" ./src/interp/boot/load/runner.4th" drop load
  exit-frame
end

def load-interp
  s" ./src/interp/boot/load/interp.4th" drop load
  exit-frame
end
