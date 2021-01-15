( System calls: arguments go into R1-R4 with the syscall number in R7. )

0 cs-reg bit-set fp bit-set dict-reg bit-set eip bit-set const> state-register-mask
4 cell-size mult const> state-byte-size

: syscall-gen-loaders ( num-args count-down -- )
  over 1 int<= IF swap drop return THEN
  swap 1 - swap
  ( load SP+[state + n] into Rn )
  over dup 1 - cell-size mult state-byte-size + swap ldr-sp ,uint16
  loop
;

: emit-syscaller-0
  ( save registers )
  state-register-mask r0 bit-set pushr ,uint16
  ( make syscall )
  r7 mov# ,uint16
  0 swi ,uint16
  ( restore registers, keep return value in R0 )
  state-register-mask r1 bit-set popr ,uint16
  ( save ToS )
  0 r1 bit-set pushr ,uint16
;

: emit-syscaller-n
  ( save registers )
  state-register-mask pushr ,uint16
  ( load args into registers )
  dup syscall-gen-loaders
  ( make syscall )
  swap r7 mov# ,uint16
  0 swi ,uint16
  ( restore registers, keep return value in R0 )
  state-register-mask popr ,uint16
  ( drop the arguments )
  1 - cell-size mult r1 mov# ,uint16
  r1 sp add-lohi ,uint16
;

: emit-syscaller ( syscall# num-args )
  dup IF emit-syscaller-n
  ELSE drop emit-syscaller-0
  THEN
;

defop syscall ( argn... arg0 num-args syscall -- result )
  ( save registers )
  state-register-mask pushr ,uint16
  ( load args into registers )
  0 r0 r7 mov-lsl ,uint16
  sp r0 mov-hilo ,uint16
  cell-size state-byte-size + r0 add# ,uint16
  r0 0x7F ldmia ,uint16 ( 4 cycles to blindly load )
  ( make syscall )
  0 swi ,uint16
  ( restore registers, keep return value in R0 )
  state-register-mask popr ,uint16
  ( drop the arguments )
  cell-size r1 ldr-sp ,uint16
  2 r1 r1 mov-lsl ,uint16
  r1 sp add-lohi ,uint16
  emit-next
endop

defop syscall ( args num-args syscall -- result )
  ( save registers )
  state-register-mask pushr ,uint16
  ( load args into registers )
  0 r0 r7 mov-lsl ,uint16
  cell-size state-byte-size + r0 ldr-sp ,uint16
  r0 0x7F ldmia ,uint16 ( 4 cycles to blindly load )
  ( make syscall )
  0 swi ,uint16
  ( restore registers, keep return value in R0 )
  state-register-mask popr ,uint16
  ( drop the arguments )
  2 cell-size mult inc-sp ,uint16
  emit-next
endop

def write ( len ptr fd -- bytes-or-error )
  args 3 4 syscall
  3 return1-n
end

def read ( len ptr fd -- bytes-or-error )
  args 3 3 syscall
  3 return1-n
end

def dyn-exit
  args 1 1 syscall
end

def getpid
  args 0 20 syscall return1
end

def test-dyn-write
  s" syscall called
" swap 1 write return1
end

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

defop open ( mode flags path -- result )
  5 3 emit-syscaller
  emit-next
endop

defop close ( fd -- result )
  6 1 emit-syscaller
  emit-next
endop

defop lseek ( whence offset fd -- result )
  19 3 emit-syscaller
  emit-next
endop

defop old-read ( len ptr fd -- result )
  3 3 emit-syscaller
  emit-next
endop

defop old-write ( len ptr fd -- result )
  4 3 emit-syscaller
  emit-next
endop

defop pread64 ( offset len ptr fd -- result )
  180 4 emit-syscaller
  emit-next
endop

defop pwrite64 ( offset len ptr fd -- result )
  181 4 emit-syscaller
  emit-next
endop

defop ioctl ( arg cmd fd -- result )
  54 3 emit-syscaller
  emit-next
endop

( Exit to system: )

defop sysexit
  1 r7 mov# ,uint16
  0 swi ,uint16
endop

defcol abort
  int32 255 sysexit
endcol

defcol bye
  int32 0 sysexit
endcol

( Memory: )

defop brk ( amount )
  0x2D 1 emit-syscaller
  emit-next
endop

defop mmap2 ( addr length prot flags fd pgoffset -- addr )
  0xC0 6 emit-syscaller
  emit-next
endop
