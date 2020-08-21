( System calls: )

0 cs bit-set fp bit-set dict-reg bit-set eip bit-set const> state-register-mask
4 cell-size mult const> state-byte-size

: emit-push-state
  state-register-mask pushr ,uint16
;

: emit-pop-state
  state-register-mask popr ,uint16
;

: syscall-gen-loaders
  over 1 equals IF swap drop return THEN
  swap 1 - swap
  over dup 1 - cell-size mult state-byte-size + swap ldr-sp ,uint16
  loop
;

: emit-syscaller ( syscall# num-args )
  ( save registers )
  ( 0 r0 bit-set pushr ,uint16 )
  emit-push-state
  ( load args into registers )
  dup syscall-gen-loaders
  ( make syscall )
  swap r7 mov# ,uint16
  0 swi ,uint16
  ( restore registers, keep return value in R0 )
  emit-pop-state
  1 - cell-size mult r1 mov# ,uint16
  r1 sp add-lohi ,uint16
;

( Input & output: )

0 defconst> standard-input
1 defconst> standard-output
2 defconst> standard-error

0 defvar> current-input
1 defvar> current-output
2 defvar> current-error

3 defconst> O_ACCMODE
0 defconst> O_RDONLY
1 defconst> O_WRONLY
2 defconst> O_RDWR
64 defconst> O_CREAT
128 defconst> O_EXCL
256 defconst> O_NOCTTY
512 defconst> O_TRUNC
1024 defconst> O_APPEND
2048 defconst> O_NONBLOCK
alias> O_NDELAY	O_NONBLOCK
4096 defconst> O_SYNC
alias> O_FSYNC O_SYNC
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

defop read ( len ptr fd -- result )
  3 3 emit-syscaller
  emit-next
endop

defop write ( len ptr fd -- result )
  4 3 emit-syscaller
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
