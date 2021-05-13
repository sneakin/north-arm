( System calls: arguments go into R0-R6 with the syscall number in R7. )

0 cs-reg bit-set fp bit-set dict-reg bit-set eip bit-set const> state-register-mask
4 cell-size mult const> state-byte-size

defop syscall ( args num-args syscall -- result )
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
  ( drop the arguments )
  2 cell-size mult inc-sp ,ins
  emit-next
endop

( Input & output: )

0 defconst> standard-input
1 defconst> standard-output
2 defconst> standard-error

0 defconst> O_RDONLY
1 defconst> O_WRONLY
2 defconst> O_RDWR
3 defconst> O_ACCMODE
64 defconst> O_CREAT
128 defconst> O_EXCL
256 defconst> O_NOCTTY
512 defconst> O_TRUNC
1024 defconst> O_APPEND
2048 defconst> O_NONBLOCK
defalias> O_NDELAY O_NONBLOCK
4096 defconst> O_SYNC
defalias> O_FSYNC O_SYNC
8192 defconst> O_ASYNC
0x20000 defconst> O_LARGEFILE

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
  args 2 197 syscall 3 return1-n
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

def mmap2 ( addr length prot flags fd pgoffset -- addr )
  args 6 0xC0 syscall 6 return1-n
end

( Time: )

def sys-get-time-of-day
  args 2 78 syscall 2 return1-n
end
