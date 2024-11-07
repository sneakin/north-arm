( System calls: arguments go into R0-R6 with the syscall number in R7. )

: emit-syscall
  ( save registers )
  state-register-mask pushr ,ins
  ( load args into registers )
  0 r0 r7 mov-lsl ,ins
  cell-size state-byte-size + r0 ldr-sp ,ins
  ( erasing state requires that interpreted handlers have state to load. )
  r0 0x3F ldmia ,ins ( # registers / 2 = # cycles to load )
  ( make syscall )
  0 swi ,ins
  ( restore registers, keep return value in R0 )
  state-register-mask popr ,ins
;

defop syscall ( args num-args syscall -- result )
  emit-syscall
  ( drop the arguments )
  2 cell-size mult inc-sp ,ins
  emit-next
endop

( Processes: )

defop syscall-clone ( args num-args syscall -- pid-or-error )
  emit-syscall
  ( skip the argument drop if in child process )
  0 r0 cmp# ,ins
  0 beq-ins ,ins
  ( drop the arguments )
  2 cell-size mult inc-sp ,ins
  ( drop 0 return value the child sees )
  ( 0 bne ,ins
  0 r0 bit-set popr ,ins )
  emit-next
endop

def fork
  args 0 2 syscall return1
end

def execve ( env argv program -- status )
  args 3 0xB syscall 3 return1-n
end

def getpid
  args 0 20 syscall return1
end

def gettid
  args 0 0xE0 syscall return1
end

def getppid
  args 0 0x40 syscall return1
end

def wait4 ( rusage opts status pid -- result )
  args 4 114 syscall 4 return1-n
end

def waitid ( opts sig-info pid which -- result )
  args 4 280 syscall 4 return1-n
end

def futex ( val3 uaddr2 utime val op uaddr -- result )
  args 6 0xf0 syscall 6 return1-n
end

def pause
  args 0 29 syscall return1
end

def kill ( signal pid -- result )
  args 2 37 syscall 2 return1-n
end

def tkill ( signal tid -- result )
  args 2 0xEE syscall 2 return1-n
end

def tgkill ( signal tid tgid -- result )
  args 3 0x10C syscall 3 return1-n
end

def getpriority ( who which -- result )
  args 2 0x60 syscall 2 return1-n
end

def setpriority ( niceval who which -- result )
  args 3 0x61 syscall 3 return1-n
end

def sched-setparam ( sched-param pid -- result )
  args 2 0x9a syscall 2 return1-n
end

def sched-getparam ( sched-param pid -- result )
  args 2 0x9b syscall 2 return1-n
end

def sched-setscheduler ( sched-param policy pid -- result )
  args 3 0x9c syscall 3 return1-n
end

def sched-getscheduler ( pid -- result )
  args 1 0x9d syscall 1 return1-n
end

def sched-yield ( ++ result )
  args 0 0x9e syscall return1
end

def sched-get-priority-max ( policy -- result )
  args 1 0x9f syscall 1 return1-n
end

def sched-get-priority-min ( policy -- result )
  args 1 0xa0 syscall 1 return1-n
end

def sched-rr-get-interval ( timespec pid -- result )
  args 2 0xa1 syscall 2 return1-n
end

def sched-setaffinity ( user-mask-ptr length pid -- result )
  args 3 0xf1 syscall 3 return1-n
end

def sched-getaffinity ( user-mask-ptr length pid -- result )
  args 3 0xf2 syscall 3 return1-n
end

( Input & output: )

0 defconst> standard-input
1 defconst> standard-output
2 defconst> standard-error

def open ( mode flags path -- result )
  args 3 5 syscall 3 return1-n
end

def close ( fd -- result )
  args 1 6 syscall 1 return1-n
end

0 defconst> SEEK-SET
1 defconst> SEEK-CUR
2 defconst> SEEK-END
3 defconst> SEEK-DATA
4 defconst> SEEK-HOLE
4 defconst> SEEK-MAX

def lseek ( whence offset fd -- result )
  args 3 19 syscall 3 return1-n
end

def read ( len ptr fd -- bytes-or-error )
  args 3 3 syscall 3 return1-n
end

def write ( len ptr fd -- bytes-or-error )
  args 3 4 syscall 3 return1-n
end

def pread64 ( offset len ptr fd -- result )
  args 4 180 syscall 4 return1-n
end

def pwrite64 ( offset len ptr fd -- result )
  args 4 181 syscall 4 return1-n
end

def sendfile ( count offset-ptr in-fd out-fd -- result )
  args 4 187 syscall 4 return1-n
end

def sendfile64 ( count offset64-ptr in-fd out-fd -- result )
  args 4 239 syscall 4 return1-n
end

def copy-file-range ( flags len out-offset64-ptr fd-out in-offset64-ptr fd-in -- result )
  args 6 391 syscall 6 return1-n
end

def ioctl ( arg cmd fd -- result )
  args 3 54 syscall 3 return1-n
end

def fnctl ( arg cmd fd -- result )
  args 3 55 syscall 3 return1-n
end

def stat ( stats-ptr path -- result )
  args 2 195 syscall 2 return1-n
end

def lstat ( stats-ptr path -- result )
  args 2 196 syscall 2 return1-n
end

def fstat ( stats-ptr fd -- result )
  args 2 197 syscall 2 return1-n
end

def pipe ( fds[2] -- result )
  args 1 0x2A syscall 1 return1-n
end

def pipe2 ( opts fds[2] -- result )
  args 2 0x167 syscall 2 return1-n
end

def fd-dup ( fd -- new-fd )
  args 1 41 syscall 1 return1-n
end

def fd-dup2 ( new-fd old-fd -- new-fd )
  args 2 63 syscall 2 return1-n
end

def poll ( opts n fds[] -- result )
  args 3 7 syscall 3 return1-n
end

def fsync ( fd -- result )
  args 1 0x76 syscall 1 return1-n
end

def getdents ( count dirent fd -- result )
  args 3 0x8d syscall 3 return1-n
end


( Exit to system: )

defop sysexit
  1 r7 mov# ,ins
  0 swi ,ins
endop

defcol abort
  int32 255 sysexit
endcol

defcol bye
  int32 0 sysexit
endcol

( Memory: )

def brk ( amount )
  args 1 0x2D syscall 1 return1-n
end

def mmap2 ( pgoffset fd flags prot length addr -- addr )
  args 6 0xC0 syscall 6 return1-n
end

def munmap ( length addr -- result )
  args 2 0x5B syscall 2 return1-n
end

def msync ( flags length addr -- result )
  args 3 0x90 syscall 3 return1-n
end

( Time: )

def sys-get-time-of-day
  args 2 78 syscall 2 return1-n
end

def nanosleep ( out-remaining timespec -- result )
  args 2 0xA2 syscall 2 return1-n
end

( Sockets: )

def socket ( protocol type domain -- result )
  args 3 0x119 syscall 3 return1-n
end

def bind ( addr-len addr fd -- result )
  args 3 0x11a syscall 3 return1-n
end

def connect ( addr-len addr fd -- result )
  args 3 0x11b syscall 3 return1-n
end

def listen ( backlog fd -- result )
  args 2 0x11c syscall 2 return1-n
end

def accept ( addr-len addr socket -- result )
  args 3 0x11d syscall 3 return1-n
end

def getsockname ( addr-len addr socket -- result )
  args 3 0x11e syscall 3 return1-n
end

def getpeername ( addr-len addr socket -- result )
  args 3 0x11f syscall 3 return1-n
end

def socketpair ( sv[2] protocol type domain -- result )
  args 4 0x120 syscall 4 return1-n
end

def send ( flags length buffer fd -- result )
  args 4 0x121 syscall 4 return1-n
end

def sendto ( addr-len dest-addr flags length buffer fd -- result )
  args 6 0x122 syscall 6 return1-n
end

def recv ( flags length buffer fd -- result )
  args 4 0x123 syscall 4 return1-n
end

def recvfrom ( addr-len src-addr flags length buffer fd -- result )
  args 6 0x124 syscall 6 return1-n
end

def shutdown ( how socket -- result )
  args 2 0x125 syscall 2 return1-n
end

def setsockopt ( optlen optval optname level fd -- result )
  args 5 0x126 syscall 5 return1-n
end

def getsockopt ( optlen optval optname level fd -- result )
  args 5 0x127 syscall 5 return1-n
end

( Message Queues: )

def sendmsg ( flags msg fd -s result )
  args 3 0x128 syscall 3 return1-n
end

def recvmsg ( fsags msg fd -- result )
  args 3 0x129 syscall 3 return1-n
end

( Semaphores: )

def semop ( nsops ops semid -- result )
  args 3 0x12a syscall 3 return1-n
end

def semget ( semflag nsems key -- result )
  args 3 0x12b syscall 3 return1-n
end

def semctl ( arg cmd semnum semid -- result)
  args 4 0x12c syscall 4 return1-n
end
