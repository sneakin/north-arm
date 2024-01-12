( OS entry point: sets initial state and calls main. )
( todo save lr, mark data )

( Linux calls with number of args, an array of string pointers of the args, an array of shrings for the env, and an auxvec on the stack [and in registers?]. 
The dynamic linker is supposed to pass a finalization function in r0 that appears to reinitialize and restart.
The arguments are argc, argv as a sequence of pointers, and env as a sequence of pointers.
Having the program's entry call the finalizer or the value in LR results in program restart.
)

defcol runner-thumb-init
  drop
  0 set-current-frame
  *ds-offset* cs + set-ds
  ( todo copy the data )
  *init-dict* cs + set-dict
  _start sysexit
endcol

( todo? inits with: aux env argv argc fp cs dict ds _start )

defop init
  ( stack env, argv[], argc )
  ( init cs )
  0 r0 bit-set popr ,ins ( calc-cs will push argc back )
  out' calc-cs emit-op-call
  0 r0 cs-reg mov-lsl ,ins
  ( call the init word )
  dhere 0 r0 ldr-pc ,ins
  out' exec emit-op-jump
  ( without main calling bye, exit restores eip to the initial value above. LR gets lost in ~next~ so this does not get reached: )
  out' bye emit-op-jump
  4 pad-data
  0 r0 patch-ldr-pc!
  out' runner-thumb-init to-out-addr ,uint32
endop

( todo pass eip as an argument to a top level eval. Likewise with the dictionaries and other state like registers. )
  ( todo set dict in colon def from const )
