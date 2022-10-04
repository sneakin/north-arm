( OS threads: )

( todo cleanup thread before it exits? )
( todo thread-kill & thread-join: muscl uses TLS, wait4 doesn't consider the thread's pid a child. )

( todo howto keep Thread's SP in sync with the running thread? )

s[ src/lib/stack.4th
   src/lib/stack/mmap.4th
] load-list

0x00000100 const> CLONE_VM
0x00000200 const> CLONE_FS
0x00000400 const> CLONE_FILES
0x00000800 const> CLONE_SIGHAND
0x00001000 const> CLONE_PIDFD
0x00002000 const> CLONE_PTRACE
0x00004000 const> CLONE_VFORK
0x00008000 const> CLONE_PARENT
0x00010000 const> CLONE_THREAD
0x00020000 const> CLONE_NEWNS
0x00040000 const> CLONE_SYSVSEM
0x00080000 const> CLONE_SETTLS
0x00100000 const> CLONE_PARENT_SETTID
0x00200000 const> CLONE_CHILD_CLEARTID
0x00400000 const> CLONE_DETACHED
0x00800000 const> CLONE_UNTRACED
0x01000000 const> CLONE_CHILD_SETTID
0x02000000 const> CLONE_NEWCGROUP
0x04000000 const> CLONE_NEWUTS
0x08000000 const> CLONE_NEWIPC
0x10000000 const> CLONE_NEWUSER
0x20000000 const> CLONE_NEWPID
0x40000000 const> CLONE_NEWNET
0x80000000 const> CLONE_IO

defcol clone-init ( system-return fn-to-call ++ )
  0 set-current-frame
  drop ( to exit to fn-to-call )
endcol

def clone ( C order: init-fn, unsigned long flags, void *stack,
            int *parent_tid, unsigned long tls,
            int *child_tid )
  ( The clone's stack needs the state registers saved with EIP patched to exit the syscall. )
  arg2 state-byte-size - dup save-state-regs set-arg2
  ( patch eip )
  arg0 dict-entry-data-pointer arg2 cell-size 3 * + poke
  args cell-size + 5 0x78 syscall-clone
  dup IF 6 return1-n THEN
end

( Thread wrapper: )

( Errors: )
-1 const> THREAD-ERROR-INIT
-2 const> THREAD-ERROR-CLONE

0 const> THREAD-VIRGIN
1 const> THREAD-INITIATED
2 const> THREAD-STARTING
3 const> THREAD-RUNNING
4 const> THREAD-STOPPED
5 const> THREAD-EXITED
6 const> THREAD-KILLED
7 const> THREAD-DESTROYED
8 const> THREAD-FAILED

0x100000 var> THREAD-STACK-SIZE ( 1 MiB default stack )

128 cell-size * var> THREAD-RETURN-SIZE

struct: Thread
value field: state
value field: pid
value field: tid
value field: parent
pointer<any> field: stack
pointer<any> field: ds-base
value field: ds-size
pointer<any> field: return-stack

def make-thread
  0 Thread make-instance set-local0
  MmapStack make-instance local0 Thread -> stack !
  Stack make-instance local0 Thread -> return-stack !
  local0 exit-frame
end

def make-this-thread
  0 Thread make-instance set-local0
  THREAD-RUNNING local0 Thread -> state !
  getpid local0 Thread -> pid !
  gettid local0 Thread -> tid !
  ds local0 Thread -> ds-base !
  data-segment-size cell-size * local0 Thread -> ds-size !
  ( stack )
  Stack make-instance
  dup local0 Thread -> stack !
  args over Stack -> here !
  args over Stack -> base ! ( todo get real size )
  top-frame args - over Stack -> size !
  ( return stack )
  Stack make-instance
  dup local0 Thread -> return-stack !
  return-stack @ over Stack -> base !
  return-stack @ over Stack -> here !
  *return-stack-size* @ over Stack -> size !
  local0 exit-frame
end

def init-thread ( stack-size thread ++ thread true | false )
  arg1 arg0 Thread -> stack @ init-mmap-stack IF
    arg0 Thread -> stack @
    ( return stack )
    THREAD-RETURN-SIZE @ local0 stack-stack-allot
    THREAD-RETURN-SIZE @ arg0 Thread -> return-stack @ init-stack
    ( data vars )
    data-segment-size cell-size * 4096 pad-addr
    dup arg0 Thread -> ds-size !
    local0 stack-stack-allot
    dup arg0 Thread -> ds-base !
    ds swap data-segment-size cell-size * copy
    THREAD-INITIATED arg0 Thread -> state !
    arg0 true 2 return2-n
  THEN false 2 return1-n ( todo throw error )
end

def thread-reset ( thread -- thread )
  arg0 Thread -> stack @ stack-reset
  arg0 Thread -> return-stack @ stack-reset
  ds arg0 Thread -> ds-base @ data-segment-size cell-size * copy
  THREAD-INITIATED arg0 Thread -> state !
end

def destroy-thread
  arg0 Thread -> stack @
  dup MmapStack kind-of? IF destroy-mmap-stack ELSE drop THEN
  0 arg0 Thread -> ds-base !
  0 arg0 Thread -> ds-size !
  0 arg0 Thread -> return-stack !
  0 arg0 Thread -> stack !
  THREAD-DESTROYED arg0 Thread -> state !
  1 return0-n
end

( Flags passed to clone: )
( SIGCHLD )
CLONE_VM ( logior )
CLONE_FS logior
CLONE_FILES logior
CLONE_SIGHAND logior
CLONE_THREAD logior
CLONE_SYSVSEM logior
CLONE_CHILD_SETTID logior
CLONE_CHILD_CLEARTID logior
( CLONE_SETTLS logior
 CLONE_CHILD_CLEARTID logior
 CLONE_DETACHED logior )
const> THREAD-FLAGS

make-this-thread var> *current-thread*

def cached-gettid
  *current-thread* @ Thread -> tid @ return1
end

defcol thread-init ( thread fn-arg system-return fn-to-call ++ )
  0 set-current-frame
  5 overn Thread -> ds-base @ set-ds
  5 overn Thread -> return-stack @ Stack -> base @ return-stack !
  5 overn Thread -> return-stack @ Stack -> size @ *return-stack-size* !
  5 overn *current-thread* !
  THREAD-RUNNING *current-thread* @ Thread -> state !
  -1 *current-thread* @ Thread -> state futex-wake drop
  drop ( to exit with fn-to-call )
endcol

( Clone the process for use as a new thread. Stack must have a thread exit word and an interpreted function as the ToS. )
def thread-do-clone ( thread -- thread true | thread false )
  getpid arg0 Thread -> parent !
  arg0 Thread -> tid 0 0 arg0 Thread -> stack @ Stack -> here @ THREAD-FLAGS ' thread-init clone
  dup 0 int> IF
    arg0 Thread -> pid !
    arg0 true
  ELSE
    arg0 false
  THEN 1 return2-n
end

( Called when a thread returns from a top frame without calling sysexit. )
def thread-return
  THREAD-EXITED *current-thread* @ Thread -> state !
  abort
end

def thread-init-stack ( data fn thread -- thread )
  ( init stack: data sys-return fn )
  arg0 Thread -> stack @
  ( arguments to fn: thread data )
  arg0 local0 stack-push
  arg2 local0 stack-push
  ( sys-return )
  ' thread-return dict-entry-data-pointer local0 stack-push
  ( fn )
  arg1 dict-entry-data-pointer local0 stack-push
  arg0 3 return1-n
end

( Start ~fn~ on an initialized thread. The thread and ~data~ are pushed onto the new stack before ~clone~ is called. )
def thread-start/3 ( data fn thread -- thread true | error false )
  THREAD-STARTING arg0 Thread -> state !
  arg2 arg1 arg0 thread-init-stack
  arg0 thread-do-clone
  IF arg0 true
  ELSE
    THREAD-FAILED arg0 Thread -> state !
    THREAD-ERROR-CLONE false
  THEN 3 return2-n
end

( Start a new thread that calls ~fn~ using a newly allocated stack of the default size. )
def thread-start ( data fn ++ thread true | error false )
  0
  make-thread set-local0
  THREAD-STACK-SIZE @ local0 init-thread
  IF arg1 arg0 local0 thread-start/3 IF true exit-frame THEN
  ELSE THREAD-ERROR-INIT
  THEN local0 destroy-thread false 2 return2-n
end

def thread-alive? ( thread -- yes? )
  arg0 Thread -> tid @ 0 uint> 1 return1-n
end

def thread-wait-to-start/2 ( seconds thread -- started | error false )
  arg0 Thread -> state @ THREAD-RUNNING int>= IF true 2 return1-n THEN
  arg1 secs->timespec value-of THREAD-STARTING arg0 Thread -> state futex-wait/3
  dup 0 equals? IF
    arg0 Thread -> state @ THREAD-STARTING
    int<= IF drop-locals repeat-frame THEN
    true 2 return1-n
  ELSE
    ( futex will return EWOULDBLOCK when the value already changed.
      check the value one more time if it has. )
    arg0 Thread -> state @ THREAD-RUNNING int>=
    IF true 2 return1-n
    ELSE false 2 return2-n
    THEN
  THEN
end

def thread-wait-to-start
  arg0 -1 set-arg0 ' thread-wait-to-start/2 tail+1
end
  
def thread-join/2 ( timeout thread -- true | error false )
  arg0 Thread -> tid @
  dup 0 uint> IF
    ( watch for the tid getting zeroed )
    arg1 secs->timespec value-of local0 arg0 Thread -> tid futex-wait/3
    dup 0 equals? IF
      arg0 Thread -> tid @ IF drop-locals repeat-frame THEN
      true 2 return1-n
    THEN
  ELSE
    ( never started so wait for start )
    arg0 Thread -> state @ THREAD-RUNNING int< IF
      arg1 arg0 thread-wait-to-start/2 IF
	drop-locals repeat-frame
      THEN
    THEN
  THEN false 2 return2-n
end

def thread-join ( thread -- true | error false )
  arg0 -1 set-arg0 ' thread-join/2 tail+1
end

( todo what pid does wait and kill need? )

def thread-status
  arg0 Thread -> tid @ pid-status 1 return1-n
end

def thread-kill/2
  arg1 arg0 Thread -> tid @ arg0 Thread -> parent @ tgkill
  2 return1-n
end

def thread-kill
  SIGKILL arg0 thread-kill/2 1 return1-n
end

def thread-term
  SIGTERM arg0 thread-kill/2 1 return1-n
end
