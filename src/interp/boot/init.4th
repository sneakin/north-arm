return-stack peek [UNLESS]
  256 proper-init
  tmp" Initialized return stack" error-line/2
[THEN]

dhere [UNLESS]
  128 1024 * data-init-stack
  tmp" Initialized data stack" error-line/2
[THEN]

s[ src/interp/boot/core.4th
   src/lib/byte-data.4th
   src/lib/case.4th
   src/interp/data-stack-list.4th
   src/runner/ffi.4th
   src/interp/dynlibs.4th
   src/interp/signals.4th
   src/interp/tty.4th
   src/interp/dictionary/revmap.4th
   src/interp/dictionary/dump.4th
   src/lib/structs.4th
   src/lib/math.4th
] load-list

signals-init
tty-init
