( The first interpreted definition that is called: )
def boot
  hello
  int32 128 stack-allot int32 128 make-prompt-reader
  int32 128 stack-allot
  int32 128 int32 35 overn interp
  boo
  bye
end

( OS entry point: )
defop init
  ( calculate CS: pc - dhere )
  24 r3 ldr-pc ,uint16
  pc r5 mov-hilo ,uint16
  r3 r5 cs sub ,uint16
  ( zero registers )
  sp r0 mov-hilo ,uint16
  0 r1 mov# ,uint16
  0 r2 mov# ,uint16
  0 r3 mov# ,uint16
  0 fp mov# ,uint16
  0 eip mov# ,uint16
  ( set the dictionary )
  12 dict-reg ldr-pc ,uint16
  cs dict-reg dict-reg add ,uint16
  ( exec boot )
  12 r1 ldr-pc ,uint16
  op-exec-r1 emit-op-call
  ( data: )
  dict dict-entry-size + 10 + ,uint32
  dict ,uint32
  op-boot ,uint32
endop

( todo pass eip as an argument to a top level eval. Likewise with the dictionaries and other state like registers. )
  ( todo set dict in colon def from const )
