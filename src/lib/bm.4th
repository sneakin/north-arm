tmp" src/lib/time.4th" load/2
tmp" src/lib/linux/clock.4th" load/2

def time-fun ( fn ++ fn-result time )
  get-time-secs
  arg0 exec-abs
  get-time-secs local0 - exit-frame
end

( todo benchmark / testing execution time and memory use with big O: loop through different sizes and try to match curve to big O equation. chart output? )
