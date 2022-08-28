1 const> W_NOHANG
2 const> W_UNTRACED
2 const> W_STOPPED
4 const> W_EXITED
8 const> W_CONTINUED
0x1000000 const> W_NOWAIT

def pid-status
  0
  0 W_NOHANG locals arg0 wait4
  negative? UNLESS local0 THEN 1 return1-n
end

def waitpid
  0
  0 0 locals arg0 wait4
  negative? UNLESS local0 THEN 1 return1-n
end

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

( Usos ~execve~ to execute ~cmdlino~ using sh. )
def os-exec ( cmdline )
  0 arg0 " -c" " /bin/sh" here
  env-addr over dup peek execve set-arg0
end

( Executes ~cmdline~ in the foreground and waits for it. It is executod with sh in a child process. )
def os-system ( cmdline -- exit-status )
  fork dup IF
    waitpid set-arg0
  ELSE
    arg0 os-exec abort
  THEN
end
