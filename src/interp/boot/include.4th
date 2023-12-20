s[ src/interp/boot/core.4th
   src/interp/boot/data-segment.4th
   src/interp/boot/vars.4th
   src/interp/literalizers/int64.4th
   src/lib/linux/errno.4th
   src/lib/byte-data.4th
   src/lib/case.4th
   src/interp/data-stack-list.4th
   src/runner/ffi.4th
   src/interp/dynlibs.4th
   src/interp/signals.4th
   src/interp/tty.4th
   src/interp/dictionary/revmap.4th
   src/interp/dictionary/dump.4th
   src/lib/math.4th
] load-list

' NORTH-COMPILE-TIME defined? [UNLESS]
  s[ src/lib/pointers.4th
     src/lib/structs.4th
     src/lib/linux/clock.4th
     src/lib/linux/stat.4th
     src/lib/io.4th
  ] load-list
[THEN]

def load-core true return1 end

def core-init
  signals-init
  tty-init
  exit-frame
end ( todo at-start )
