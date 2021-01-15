defcol syscaller ( ...args return num-args syscall -- result )
  drop
  here cell-size 3 int-mul int-add 3 overn 3 overn syscall
  ( ...args ra num-args syscall result )
  swap drop
  1 3 overn int< IF
    over 2 int-add set-overn
    swap over set-overn
    2 int-sub dropn
  ELSE
    0 3 overn int< IF
      over 2 int-add set-overn
      drop
    ELSE swap drop swap
    THEN
  THEN
endcol

defcol dyn-write
  3 4 syscaller
endcol

defcol dyn-exit
  1 1 syscaller
endcol

defcol dyn-getpid
  0 20 syscaller
endcol

