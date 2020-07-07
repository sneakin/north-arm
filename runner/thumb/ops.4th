( Emits the assembly to jump to an op. )
: emit-op-call
  dict-entry-size + rel-addr 4 - branch ,uint32
;

( Core execution: )

defop exec-r1
  ( load and jump to the word's code field, leaving word in r0 )
  cs r1 r1 add ,uint16
  0 dict-entry-code r1 r2 ldr-offset ,uint16
  ( dict-entries are offset from the .text segment. )
  ( add the base address )
  cs r2 r2 add ,uint16
  ( jump to the code )
  r2 pc mov-lohi ,uint16
endop

defop exec
  ( Move the ToS to r1, lower stack, and exec the word. )
  0 r0 r1 mov-lsl ,uint16
  0 r0 bit-set popr ,uint16
  op-exec-r1 emit-op-call
endop

defop next
  ( load word eip points at )
  0 eip r1 ldr-offset ,uint16
  ( increase eip )
  cell-size eip add# ,uint16
  op-exec-r1 emit-op-call
endop

: emit-next
  op-next emit-op-call
;

( Calling words: )

defop enter-r1
  ( Save eip and interpret the list of words pointed by r1. )
  ( save eip to ToS )
  0 r0 bit-set pushr ,uint16
  0 eip r0 mov-lsl ,uint16
  ( load r1 into eip )
  0 r1 eip mov-lsl ,uint16
  emit-next
endop

defop enter-r0
  ( Call the ToS. )
  0 r0 r1 mov-lsl ,uint16
  0 r0 bit-set popr ,uint16
  op-enter-r1 emit-op-call
endop

defop do-col
  ( Enter the definition from word's data field. )
  ( load r1's data+cs into r1 )
  0 dict-entry-data r1 r1 ldr-offset ,uint16
  cs r1 r1 add ,uint16
  op-enter-r1 emit-op-call
endop

defop exit
  ( Return from a list of words. Return address must be the ToS. )
  ( pop eip )
  0 r0 eip mov-lsl ,uint16
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop quit
  ( todo reset stack & state )
  emit-next
endop

( Stack manipulations: )

defop drop
  0 r0 bit-set popr ,uint16
  emit-next
endop

defop dup
  0 r0 bit-set pushr ,uint16
  emit-next
endop

defop over
  0 r0 bit-set pushr ,uint16
  cell-size 2 mult r1 ldr-sp ,uint16
endop

defop overn
  2 r0 r0 mov-lsl ,uint16
  r0 r0 add-sp ,uint16
  0 r0 r0 ldr-offset ,uint16
endop

defop here
  0 r0 bit-set pushr ,uint16
  0 eip r0 mov-lsl ,uint16
  emit-next
endop

defop move
  r0 sp mov-lohi ,uint16
  emit-next
endop

( Memory ops: )

defop peek
  0 r0 r0 ldr-offset ,uint16
  emit-next
endop

defop poke
  0 r1 bit-set popr ,uint16
  0 r1 r0 str-offset ,uint16
  emit-next
endop

( Data loaders: )

defop int32
  ( store ToS )
  0 r0 bit-set pushr ,uint16  
  ( load cell at eip )
  0 eip r0 ldr-offset ,uint16
  ( advance eip )
  cell-size eip add# ,uint16
  emit-next
endop

defop offset32
  ( store ToS )
  0 r0 bit-set pushr ,uint16  
  ( load cell at eip & add eip )
  0 eip r0 ldr-offset ,uint16
  r0 eip r0 add ,uint16
  ( advance eip )
  cell-size eip add# ,uint16
  emit-next
endop

( System calls: )

defop read ( len ptr fd -- result )
  0 r1 bit-set r2 bit-set popr ,uint16
  0 eip bit-set pushr ,uint16
  3 r7 mov# ,uint16
  0 swi ,uint16
  0 eip bit-set popr ,uint16
  emit-next
endop

defop write ( len ptr fd -- result )
  0 r1 bit-set r2 bit-set popr ,uint16
  0 eip bit-set pushr ,uint16
  4 r7 mov# ,uint16
  0 swi ,uint16
  0 eip bit-set popr ,uint16
  emit-next
endop

defop sysexit
  1 r7 mov# ,uint16
  0 swi ,uint16
endop

defcol abort
  op-int32 ,uint32 255 ,uint32
  op-sysexit ,uint32
  op-exit ,uint32
endcol

defcol bye
  op-int32 ,uint32 0 ,uint32
  op-sysexit ,uint32
  op-exit ,uint32
endcol
