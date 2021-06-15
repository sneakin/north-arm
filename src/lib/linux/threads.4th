( OS threads: )

( todo thread structure to hold stack ptr, size, pid, status flag )
( todo cleanup thread before it exits? )
( todo thread cleanup that unmaps stack )
( todo thread-kill & thread-join: muscl uses TLS, wait4 doesn't consider the thread's pid a child. )

( Errors: )
-1 const> THREAD-ERROR-ALLOT
-2 const> THREAD-ERROR-CLONE

( Flags passed to clone: )
SIGCHLD
CLONE_VM logior
CLONE_FS logior
CLONE_FILES logior
CLONE_SIGHAND logior
CLONE_THREAD logior
CLONE_SYSVSEM logior
( CLONE_SETTLS logior
 CLONE_PARENT_SETTID logior
 CLONE_CHILD_CLEARTID logior
 CLONE_DETACHED logior )
const> THREAD-FLAGS

0x100000 var> THREAD-STACK-SIZE ( 1 MiB default stack )

( Clone the process for use as a new thread. Stack must have an interpreted function's definition and interpreter state starting at the passed pointer. )
def thread-clone ( stack-ptr -- pid )
  0 0 0 arg0 THREAD-FLAGS clone
  1 return1-n
end

( Called when a thread returns without calling sysexit. )
def thread-return
  debug? IF s" thread exiting" error-line/2 .s THEN
  abort
end

def thread-init-stack ( stack-ptr fn -- final-stack-ptr )
  ( init stack: null-fp sys-return interp-state fn )
  ( null-fp )
  arg1 cell-size -
  0 over poke
  ( sys-return )
  cell-size -
  ' thread-return dict-entry-data-pointer over poke
  ( interp state )
  state-byte-size - dup save-state-regs
  ( fn )
  arg0 dict-entry-data-pointer over cell-size 3 * + poke
  2 return1-n
end

( Start a new thread with a custom stack. Interpreter state and fn's data pointer are pushed onto the new stack before clone. )
def thread-start/2 ( stack-ptr fn -- pid )
  arg1 arg0 thread-init-stack
  debug? IF dup state-byte-size cell-size 4 * + cmemdump THEN
  thread-clone negative? IF THREAD-ERROR-CLONE ( todo throw ) THEN
  2 return1-n
end

( Start a new thread that calls ~fn~ using a newly allocated stack of the default size. )
def thread-start ( fn -- pid )
  debug? IF getpid dup write-hex-int nl write-int nl THEN
  THREAD-STACK-SIZE peek mmap-stack
  dup IF over + arg0 thread-start/2
  ELSE THREAD-ERROR-CLONE ( todo throw error )
  THEN 1 return1-n
end
