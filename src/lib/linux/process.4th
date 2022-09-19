( Process status deconstructuring: )

def wexitstatus arg0 8 bsr 0xFF logand set-arg0 end
def wcoredump arg0 0x80 logand set-arg0 end
def wtermsig arg0 0x7F logand set-arg0 end
def wifexited arg0 wtermsig 0 equals? set-arg0 end
def wifstopped arg0 wtermsig 0x7F equals? set-arg0 end
def wifsignaled arg0 wtermsig 1 + 2 int>= set-arg0 end
def wifcontinued arg0 0xFFFF equals? set-arg0 end

( Process exit code construction: )

def make-wexitcode ( signal-number exit-code -- status )
  arg0 8 bsl arg1 logior 2 return1-n
end

def make-wstopcode ( signal-number -- status )  arg0 8 bsl 0x7F logior set-arg0 end

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

( Uses ~execve~ to execute the sequence of strings ~cmdline~ as ~name~. )
def os-exec/2 ( cmdline name -- )
  env-addr arg1 arg0 execve 2 return1-n
end

( Uses ~execve~ to execute the sequence of strings: ~cmdline~. )
def os-exec ( cmdline -- )
  arg0 peek ' os-exec/2 tail+1
end

( Uses ~execve~ to execute the ~cmdline~ string using sh. )
def os-shell-exec ( cmdline )
  0 arg0 " -c" " /bin/sh" here os-exec set-arg0
end

( Forks the program and waits for the child to exit. )
def fg-fork ( ++ exit-status true || false )
  fork dup IF waitpid true return2 ELSE false return1 THEN
end

( Forks the program and waits for the child to exit. The child executes ~word~ with ~executor~. )
def fg-fork/2 ( word executor ++ exit-status )
  fg-fork IF 2 return1-n ELSE arg1 arg0 exec-abs abort THEN
end

( Forks the program and waits for the child to exit. The child executes ~word~. )
def fg-fork/1 ( word ++ exit-status )
  fg-fork IF set-arg0 ELSE arg0 exec-abs abort THEN
end

( Executes the sequence of strings ~cmdline~ in the foreground and waits for it. )
def os-system ( cmdline -- exit-status )
  ' os-exec ' fg-fork/2 tail+1
end

( Executes ~cmdline~ in the foreground and waits for it. It is executed with sh in a child process. )
def os-shell-command ( cmdline -- exit-status )
  ' os-shell-exec ' fg-fork/2 tail+1
end
