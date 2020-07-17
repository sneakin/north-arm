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
