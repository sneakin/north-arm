defcol hello
  s" Hello there.\n" swap 1 4 syscall/4 drop
  s" Hello\n" swap 1 4 syscall/4 drop
  s" It works\n" 1 write-string/3
endcol

defop init ( env argv argc -- status )
  fp-reg push
  0 fp-reg mov#
  ( init code-origin )
  0 call ( todo make this the cs word w/o register? )
  eax pop
  dhere to-out-addr 1 - eax 0 modrr sub#
  eax cs-reg modrr movr
  ( write a string )
  BUILD-COPYRIGHT @ string-length eax mov#
  eax push
  52 eax mov#
  cs-reg eax modrr addr
  eax push
  1 eax mov#
  eax push
  4 eax mov#
  eax push
  out' syscall/4 to-out-addr eax mov#
  out' exec emit-op-call
  ( call an op )
  out' hello to-out-addr eax mov#
  out' exec emit-op-call
  out' hello to-out-addr eax mov#
  out' exec emit-op-call
  out' _start to-out-addr eax mov#
  out' exec emit-op-call
  ( out' bye to-out-addr eax mov#
  out' exec emit-op-call )
  ( clean exit with ToS )
  0 eax mov#
  eax emit-sysexit
endop
