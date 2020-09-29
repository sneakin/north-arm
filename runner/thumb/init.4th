( The first interpreted definition that is called: )
def boot
  hello main bye
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
  out' exec-r1 emit-op-call
  ( data: )
  out-dict dict-entry-size + 10 + ,uint32
  out-dict ,uint32
  out' boot ,uint32
endop

( todo pass eip as an argument to a top level eval. Likewise with the dictionaries and other state like registers. )
  ( todo set dict in colon def from const )
