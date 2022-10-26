return-stack peek [UNLESS]
  256 proper-init
  tmp" Initialized return stack" error-line/2
[THEN]

dhere [UNLESS]
  128 1024 * data-init-stack
  tmp" Initialized data stack" error-line/2
[THEN]

" src/interp/boot/include.4th" load

core-init
