( Start up messenger: )
defcol hello
  op-int32 ,uint32 6 ,uint32
  op-offset32 ,uint32 24 ,uint32
  op-int32 ,uint32 1 ,uint32
  op-write ,uint32
  op-drop ,uint32
  op-exit ,uint32
  " Hello
" ,byte-string
endcol

( The first interpreted definition that is called: )
defcol boot
  op-hello ,uint32
  op-hello ,uint32
  op-bye ,uint32
endcol

( OS entry point: )
defop init
  ( calculate CS: pc - dhere )
  22 r3 ldr-pc ,uint16
  pc r5 mov-hilo ,uint16
  r3 r5 cs sub ,uint16
  ( zero registers )
  sp r0 mov-hilo ,uint16
  0 r1 mov# ,uint16
  0 r2 mov# ,uint16
  0 r3 mov# ,uint16
  0 eip mov# ,uint16
  ( set the dictionary )
  12 dict-reg ldr-pc ,uint16
  cs dict-reg dict-reg add ,uint16
  ( exec boot )
  6 r1 ldr-pc ,uint16
  op-exec-r1 emit-op-call
  ( data: )
  4 align-data
  dict dict-entry-size + 6 + ,uint32
  op-boot ,uint32
  dict ,uint32
endop

  ( todo set dict in colon def from const )
