( OS entry point: sets initial state and calls main. )
( todo save lr, mark data )

( Linux calls with args on the stack and in registers. 
The dynamic linker passes a finalization function in r0 that appears to reinitialize and restart.
The arguments are argc, argv as a sequence of pointers, and env as a sequence of pointers.
Having the program's entry call the finalizer or the value in LR results in program restart.
)

defcol init-return
  ( stack is the top-frame: ... argc system-LR finalizer )
  ( s" Goodbye." error-line/2
  current-frame error-hex-uint enl
  dump-stack )
  0 sysexit
  ( drop set-pc )
endcol

: emit-init-data-padding
  thumb2? IF 0 ,uint32 THEN
  4 pad-data
;

defop init
  ( stack env, argv[], argc, LR, fini )
  0 pushr .pclr ,ins
  ( init registers )
  out' calc-cs emit-op-call
  0 r0 cs-reg mov-lsl ,ins
  0 fp mov# ,ins
  0 r0 bit-set popr ,ins
  ( init-return )
  44 eip ldr-pc ,ins ( data[2] )
  eip eip emit-get-reg-word-data
  ( set the dictionary )
  28 dict-reg ldr-pc ,ins ( data[0] )
  dict-reg dict-reg emit-get-reg-word-data
  ( exec main[fini, system-LR, argc, argv, env] -> init-return )
  24 r1 ldr-pc ,ins ( data[1] )
  out' exec-r1 emit-op-call
  ( without main calling bye, exit restores eip to the initial value above. LR gets lost in ~next~ so this does not get reached: )
  out' bye emit-op-jump
  ( data: dictionary main return-fn )
  emit-init-data-padding
  out' *init-dict* to-out-addr ,uint32
  out' _start to-out-addr ,uint32
  out' init-return to-out-addr ,uint32
endop

( todo pass eip as an argument to a top level eval. Likewise with the dictionaries and other state like registers. )
  ( todo set dict in colon def from const )
