( Start up messenger: )
defcol hello
  int32 7
  offset32 24
  int32 1
  write
  drop
  exit
  " Hello!
"
endcol

( The first interpreted definition that is called: )
defcol boot
  hello
  hello
  bye
endcol

( OS entry point: )
defop init
  ( calculate CS: pc - dhere )
  26 r3 ldr-pc ,uint16
  pc r5 mov-hilo ,uint16
  r3 r5 cs sub ,uint16
  ( zero registers )
  sp r0 mov-hilo ,uint16
  0 r1 mov# ,uint16
  0 r2 mov# ,uint16
  0 r3 mov# ,uint16
  0 eip mov# ,uint16
  ( set the dictionary )
  16 dict-reg ldr-pc ,uint16
  cs dict-reg dict-reg add ,uint16
  ( exec boot )
  10 r1 ldr-pc ,uint16
  op-exec-r1 emit-op-call
  ( data: )
  4 align-data
  dict dict-entry-size + 10 + ,uint32
  op-boot ,uint32
  dict ,uint32
endop

  ( todo set dict in colon def from const )
