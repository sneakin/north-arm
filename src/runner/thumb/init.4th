( OS entry point: sets initial state and calls main. )
( todo save lr, mark data )

( Linux calls with args on the stack and in registers.
The arguments are argc, argv as a sequence of pointers, and env as a sequence of pointers.
The dynamic linker passes a function in r0.
)

defop init
  ( calculate CS: pc - dhere; in r10? )
  16 r3 ldr-pc ,ins
  pc r5 mov-hilo ,ins
  r3 r5 cs-reg sub ,ins
  dhere
  ( init registers )
  0 fp mov# ,ins
  0 eip mov# ,ins
  ( set the dictionary )
  12 dict-reg ldr-pc ,ins
  cs-reg dict-reg dict-reg add ,ins
  ( exec main[fini, argc, argv, env] )
  12 r1 ldr-pc ,ins
  out' exec-r1 emit-op-call
  ( data: )
  to-out-addr ,uint32
  out-dict to-out-addr ,uint32
  out' main to-out-addr ,uint32
endop

( todo pass eip as an argument to a top level eval. Likewise with the dictionaries and other state like registers. )
  ( todo set dict in colon def from const )
