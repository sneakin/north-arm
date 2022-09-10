( todo swap the word order to watch native byte order? )

: ,uint64 ( low high -- )
  ( low, high on stack )
  swap ,uint32 ,uint32
;

: uint64! ( low high place -- )
  ( low bytes )
  rot 3 overn uint32!
  swap 4 + uint32!
;

: uint64@ ( place -- low high )
  dup uint32@
  swap 4 + uint32@
;

alias> ,cell ,uint32
alias> cell! uint32!
alias> cell@ uint32@
alias> cell! uint32!
