defop getpid ( ++ pid )
  20 0 emit-syscaller
  emit-next
endop

defop kill ( signal pid -- result )
  37 2 emit-syscaller
  emit-next
endop

defop sigaction ( old-ptr sigaction signal -- result )
  67 3 emit-syscaller
  emit-next
endop

defop sigreturn
  119 0 emit-syscaller
  emit-next
endop

defop sigprocmask
  126 3 emit-syscaller
  emit-next
endop
